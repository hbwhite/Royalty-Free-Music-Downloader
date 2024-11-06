//
//  DataManager.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/30/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "RemoveAdsNavigationController.h"
#import "MBProgressHUD.h"
#import "FilePaths.h"
#import "TagReader.h"
#import "Directory+Path.h"
#import "Archive+Path.h"
#import "Archive.h"
#import "File.h"
#import "File+Extensions.h"
#import "Album.h"
#import "Artist.h"
#import "Genre.h"
#import "GenreArtist.h"
#import "GenreAlbum.h"
#import "Playlist.h"
#import "PlaylistItem.h"
#import "Downloader.h"
#import "Download.h"
#import "DownloadRequest.h"
#import "Player.h"
#import "PlayerState.h"
#import "BookmarkItem.h"
#import "Bookmark.h"
#import "BookmarkFolder.h"
#import "ArtworkCache.h"
#import "ThumbnailCache.h"
#import "UIImage+AspectFit.h"
#import "UIViewController+SafeModal.h"

static DataManager *sharedDataManager   = nil;

#define THUMBNAIL_SIDE_LENGTH_IN_PIXELS 88

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";
static NSString *kiPodMusicLibraryKey   = @"iPod Music Library";

static NSString *kShuffleKey            = @"Shuffle";

@interface DataManager ()

@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundManagedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMutableArray *backgroundContextPendingMergeNotifications;
@property (nonatomic) NSInteger currentItemIndex;
@property (nonatomic) NSInteger currentSingleItemIndex;
@property (readwrite) BOOL libraryDidChangeAlertShown;

- (void)contextDidSave:(NSNotification *)notification;
- (void)iPodMusicLibraryDidChange:(NSNotification *)notification;
- (void)_updateLibraryWithUpdateType:(kLibraryUpdateType)updateType hud:(MBProgressHUD *)hud;
- (void)_removeiPodMusicLibrarySongsWithHUD:(MBProgressHUD *)hud;
- (void)addPathToFilePathsArrayIfApplicable:(NSString *)path filePathsArray:(NSMutableArray *)filePathsArray;
- (File *)importCurrentItemIfApplicableWithFilePaths:(NSArray *)filePaths existingFilePaths:(NSArray *)existingFilePaths parentDirectory:(Directory *)parentDirectory currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext completionCallback:(void (^)(void))completionCallback;
- (Directory *)createFolderWithoutSavingWithName:(NSString *)folderName creationDate:(NSDate *)creationDate parentDirectory:(Directory *)parentDirectory currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (File *)createFileObjectWithoutSavingWithAlbumArtistName:(NSString *)albumArtistName
                                                 albumName:(NSString *)albumName
                                                artistName:(NSString *)artistName
                                                   bitRate:(NSNumber *)bitRate
                                                  duration:(NSNumber *)duration
                                                     genre:(NSString *)genre
                                      iPodMusicLibraryFile:(BOOL)iPodMusicLibraryFile
                                            lastPlayedDate:(NSDate *)lastPlayedDate
                                                    lyrics:(NSString *)lyrics
                                              persistentID:(NSNumber *)persistentID
                                                 playCount:(NSNumber *)playCount
                                                    rating:(NSNumber *)rating
                                                     title:(NSString *)title
                                                     track:(NSNumber *)track
                                                       url:(NSString *)url
                                                      year:(NSNumber *)year
                                              creationDate:(NSDate *)creationDate
                                           parentDirectory:(Directory *)parentDirectory
                               currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (void)updateThumbnailForFile:(File *)file artworkData:(NSData *)artworkData newFile:(BOOL)newFile;
- (void)setRefsForFile:(File *)file currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (void)deleteDirectoryWithoutSaving:(Directory *)directory shouldRemoveFromDisk:(BOOL)shouldRemoveFromDisk currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (void)deleteFileWithoutSaving:(File *)file shouldRemoveFromDisk:(BOOL)shouldRemoveFromDisk currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (void)deleteRefsForFile:(File *)file currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (void)clearPlaylistWithoutSaving:(Playlist *)playlist;
- (void)deletePlaylistItemWithoutSaving:(PlaylistItem *)playlistItem;
- (void)deleteDownloadWithoutSaving:(Download *)download;
- (void)deleteBookmarkItemWithoutSaving:(BookmarkItem *)bookmarkItem;
- (NSArray *)fetchedObjectsForEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (void)saveBackgroundContext;
- (NSURL *)applicationDataStorageDirectory;

@end

@implementation DataManager

// Public
@synthesize managedObjectContext;
@synthesize backgroundOperationIsActive;

// Private
@synthesize backgroundManagedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize backgroundContextPendingMergeNotifications;
@synthesize currentItemIndex;
@synthesize currentSingleItemIndex;
@synthesize libraryDidChangeAlertShown;

// EXTEREMELY IMPORTANT: File names MUST be checked to ensure they are not blank (zero characters in length).
// Example: if ((fileName) && ([fileName length] > 0)) { ... }
// If a file name is blank, the app will append its file name to the path of its parent directory and delete the resultant path.
// Because the file name is blank, the app will, in turn, delete the parent directory and all of the files within it.

+ (DataManager *)sharedDataManager {
    @synchronized(sharedDataManager) {
        if (!sharedDataManager) {
            sharedDataManager = [[DataManager alloc]init];
        }
        return sharedDataManager;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(iPodMusicLibraryDidChange:) name:MPMediaLibraryDidChangeNotification object:nil];
        [[MPMediaLibrary defaultMediaLibrary]beginGeneratingLibraryChangeNotifications];
        
        backgroundContextPendingMergeNotifications = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)contextDidSave:(NSNotification *)notification {
    [[self managedObjectContext]performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
    
    if (backgroundOperationIsActive) {
        [backgroundContextPendingMergeNotifications addObject:notification];
    }
    else {
        [[self backgroundManagedObjectContext]mergeChangesFromContextDidSaveNotification:notification];
    }
}

- (NSInteger)fileCount {
    return [[self managedObjectContext]countForFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"File"] error:nil];
}

- (void)runInitialLibraryUpdate {
    UIView *view = [[(AppDelegate *)[[UIApplication sharedApplication]delegate]hudViewController]view];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:view];
    hud.dimBackground = YES;
    hud.labelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_MESSAGE", @"");
    hud.detailsLabelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_SUBTITLE", @"");
    [view addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        @autoreleasepool {
            // This will force the background managed object context to be created on the thread created by dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) below.
            // This is absolutely necessary and solves a major concurrency problem that can otherwise occur with the error "statement is still active."
            backgroundManagedObjectContext = nil;
            
            backgroundOperationIsActive = YES;
            [self _updateLibraryWithUpdateType:kLibraryUpdateTypeComplete hud:hud];
            backgroundOperationIsActive = NO;
            
            // Don't forget to save the context.
            [self saveBackgroundContext];
            
            // This must by called on the main thread.
            [(AppDelegate *)[[UIApplication sharedApplication]delegate]performSelectorOnMainThread:@selector(runPostLibraryUpdateSetup) withObject:nil waitUntilDone:NO];
        }
    } onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)iPodMusicLibraryDidChange:(NSNotification *)notification {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kiPodMusicLibraryKey]) {
        if (!backgroundOperationIsActive) {
            // Library change notifications can be posted when signing into a new iTunes account, which can occur when making an in-app purchase.
            // To help prevent false positives, this prevents the library change alert from being shown when the RemoveAdsNavigationController is presented.
            TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
            if ((![tabBarController safeModalViewController]) || (([tabBarController safeModalViewController]) && (![[tabBarController safeModalViewController]isKindOfClass:[RemoveAdsNavigationController class]]))) {
                if (!libraryDidChangeAlertShown) {
                    libraryDidChangeAlertShown = YES;
                    
                    UIAlertView *libraryDidChangeAlert = [[UIAlertView alloc]
                                                          initWithTitle:@"iPod Music Library Changed"
                                                          message:@"Your iPod music library has been modified. Would you like to update the songs in this app?"
                                                          delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                          otherButtonTitles:@"Update", nil];
                    [libraryDidChangeAlert show];
                }
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self updateLibraryWithUpdateType:kLibraryUpdateTypeiPodMusicLibrary];
    }
    
    libraryDidChangeAlertShown = NO;
}

- (void)updateLibraryWithUpdateType:(kLibraryUpdateType)updateType {
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:window];
    hud.dimBackground = YES;
    hud.labelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_MESSAGE", @"");
    hud.detailsLabelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_SUBTITLE", @"");
    [window addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        @autoreleasepool {
            // This will force the background managed object context to be created on the thread created by dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) below.
            // This is absolutely necessary and solves a major concurrency problem that can otherwise occur with the error "statement is still active."
            backgroundManagedObjectContext = nil;
            
            backgroundOperationIsActive = YES;
            [self _updateLibraryWithUpdateType:updateType hud:hud];
            backgroundOperationIsActive = NO;
            
            // Don't forget to save the context.
            [self saveBackgroundContext];
        }
    } onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)_updateLibraryWithUpdateType:(kLibraryUpdateType)updateType hud:(MBProgressHUD *)hud {
    @autoreleasepool {
        NSManagedObjectContext *currentManagedObjectContext = [self backgroundManagedObjectContext];
        
        NSMutableArray *filePathsArray = [NSMutableArray arrayWithObjects:nil];
        NSMutableArray *existingFilePathsArray = [NSMutableArray arrayWithObjects:nil];
        
        // All file paths are standardized, so it is safe to delete files whose paths are not contained within an array of the paths of the files currently on the disk.
        
        if (updateType != kLibraryUpdateTypeiPodMusicLibrary) {
            NSArray *fileNamesArray = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:kMusicDirectoryPathStr error:nil];
            for (int i = 0; i < [fileNamesArray count]; i++) {
                NSString *fileName = [fileNamesArray objectAtIndex:i];
                if ([fileName length] > 0) {
                    if (![[fileName substringToIndex:1]isEqualToString:@"."]) {
                        NSString *filePath = [[kMusicDirectoryPathStr stringByAppendingPathComponent:fileName]stringByStandardizingPath];
                        [self addPathToFilePathsArrayIfApplicable:filePath filePathsArray:filePathsArray];
                    }
                }
            }
            
            NSArray *directoriesArray = [self fetchedObjectsForEntityName:@"Directory" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:nil currentManagedObjectContext:currentManagedObjectContext];
            for (int i = 0; i < [directoriesArray count]; i++) {
                Directory *directory = [directoriesArray objectAtIndex:i];
                NSString *standardizedPath = [[directory path]stringByStandardizingPath];
                if ([filePathsArray containsObject:standardizedPath]) {
                    [existingFilePathsArray addObject:standardizedPath];
                }
                else {
                    [self deleteDirectoryWithoutSaving:directory shouldRemoveFromDisk:NO currentManagedObjectContext:currentManagedObjectContext];
                }
            }
            
            NSArray *archivesArray = [self fetchedObjectsForEntityName:@"Archive" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:nil currentManagedObjectContext:currentManagedObjectContext];
            for (int i = 0; i < [archivesArray count]; i++) {
                Archive *archive = [archivesArray objectAtIndex:i];
                NSString *standardizedPath = [[archive path]stringByStandardizingPath];
                if ([filePathsArray containsObject:standardizedPath]) {
                    [existingFilePathsArray addObject:standardizedPath];
                }
                else {
                    [self deleteArchiveWithoutSaving:archive shouldRemoveFromDisk:NO currentManagedObjectContext:currentManagedObjectContext];
                }
            }
            
            NSArray *filesArray = [self fetchedObjectsForEntityName:@"File" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:nil currentManagedObjectContext:currentManagedObjectContext];
            for (int i = 0; i < [filesArray count]; i++) {
                File *file = [filesArray objectAtIndex:i];
                if (![file.iPodMusicLibraryFile boolValue]) {
                    NSString *filePath = [file filePath];
                    if (filePath) {
                        NSString *standardizedPath = [filePath stringByStandardizingPath];
                        if ([filePathsArray containsObject:standardizedPath]) {
                            [existingFilePathsArray addObject:standardizedPath];
                        }
                        else {
                            [self deleteFileWithoutSaving:file shouldRemoveFromDisk:NO currentManagedObjectContext:currentManagedObjectContext];
                        }
                    }
                    else {
                        [self deleteFileWithoutSaving:file shouldRemoveFromDisk:NO currentManagedObjectContext:currentManagedObjectContext];
                    }
                }
            }
        }
        
        NSMutableArray *existingSongsArray = [NSMutableArray arrayWithObjects:nil];
        NSMutableArray *existingSongURLsArray = [NSMutableArray arrayWithObjects:nil];
        NSMutableArray *existingFileURLsArray = [NSMutableArray arrayWithObjects:nil];
        
        BOOL shouldUpdateiPodMusicLibrary = ((updateType != kLibraryUpdateTypeFiles) && ([[NSUserDefaults standardUserDefaults]boolForKey:kiPodMusicLibraryKey]));
        
        if (shouldUpdateiPodMusicLibrary) {
            MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType];
            MPMediaQuery *mediaQuery = [[MPMediaQuery alloc]initWithFilterPredicates:[NSSet setWithObject:predicate]];
            NSArray *songs = [mediaQuery items];
            
            for (int i = 0; i < [songs count]; i++) {
                MPMediaItem *song = [songs objectAtIndex:i];
                NSURL *url = [song valueForProperty:MPMediaItemPropertyAssetURL];
                if (url) {
                    NSURL *standardizedURL = [url standardizedURL];
                    if (standardizedURL) {
                        [existingSongsArray addObject:song];
                        [existingSongURLsArray addObject:standardizedURL];
                    }
                }
            }
            
            NSArray *filesArray = [self fetchedObjectsForEntityName:@"File" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"iPodMusicLibraryFile == YES"] currentManagedObjectContext:currentManagedObjectContext];
            for (int i = 0; i < [filesArray count]; i++) {
                File *file = [filesArray objectAtIndex:i];
                NSURL *fileURL = [file fileURL];
                if (fileURL) {
                    NSURL *standardizedURL = [fileURL standardizedURL];
                    if ([existingSongURLsArray containsObject:standardizedURL]) {
                        [existingFileURLsArray addObject:standardizedURL];
                    }
                    else {
                        [self deleteFileWithoutSaving:file shouldRemoveFromDisk:NO currentManagedObjectContext:currentManagedObjectContext];
                    }
                }
                else {
                    [self deleteFileWithoutSaving:file shouldRemoveFromDisk:NO currentManagedObjectContext:currentManagedObjectContext];
                }
            }
        }
        
        __block dispatch_queue_t mainQueue = dispatch_get_main_queue();
        
        NSInteger filePathCount = [filePathsArray count];
        NSInteger totalOperationCount = (filePathCount + [existingSongsArray count]);
        
        // This prevents dividing by zero or changing the HUD mode to determinate if there are no operations to perform.
        if (totalOperationCount > 0) {
            dispatch_async(mainQueue, ^{
                hud.mode = MBProgressHUDModeDeterminate;
            });
            
            currentItemIndex = 0;
            [self importCurrentItemIfApplicableWithFilePaths:filePathsArray existingFilePaths:existingFilePathsArray parentDirectory:nil currentManagedObjectContext:currentManagedObjectContext completionCallback:^{
                dispatch_async(mainQueue, ^{
                    hud.progress = ((CGFloat)(currentItemIndex + 1) / (CGFloat)totalOperationCount);
                });
            }];
        }
        
        if (shouldUpdateiPodMusicLibrary) {
            for (int i = 0; i < [existingSongsArray count]; i++) {
                MPMediaItem *song = [existingSongsArray objectAtIndex:i];
                NSURL *url = [existingSongURLsArray objectAtIndex:i];
                
                if (![existingFileURLsArray containsObject:url]) {
                    NSString *albumArtistName = [song valueForProperty:MPMediaItemPropertyAlbumArtist];
                    NSString *albumName = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
                    NSString *artistName = [song valueForProperty:MPMediaItemPropertyArtist];
                    NSNumber *duration = [song valueForProperty:MPMediaItemPropertyPlaybackDuration];
                    NSString *genre = [song valueForProperty:MPMediaItemPropertyGenre];
                    NSDate *lastPlayedDate = [song valueForProperty:MPMediaItemPropertyLastPlayedDate];
                    NSString *lyrics = [song valueForProperty:MPMediaItemPropertyLyrics];
                    NSNumber *persistentID = [song valueForProperty:MPMediaItemPropertyPersistentID];
                    NSNumber *playCount = [song valueForProperty:MPMediaItemPropertyPlayCount];
                    NSNumber *rating = [song valueForProperty:MPMediaItemPropertyRating];
                    NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
                    NSNumber *track = [song valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
                    NSString *urlString = [url absoluteString];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy"];
                    NSNumber *year = [NSNumber numberWithInteger:[[dateFormatter stringFromDate:[song valueForProperty:MPMediaItemPropertyReleaseDate]]integerValue]];
                    
                    [self createFileObjectWithoutSavingWithAlbumArtistName:albumArtistName
                                                                 albumName:albumName
                                                                artistName:artistName
                                                                   bitRate:nil
                                                                  duration:duration
                                                                     genre:genre
                                                      iPodMusicLibraryFile:YES
                                                            lastPlayedDate:lastPlayedDate
                                                                    lyrics:lyrics
                                                              persistentID:persistentID
                                                                 playCount:playCount
                                                                    rating:rating
                                                                     title:title
                                                                     track:track
                                                                       url:urlString
                                                                      year:year
                                                              creationDate:[NSDate date]
                                                           parentDirectory:nil
                                               currentManagedObjectContext:currentManagedObjectContext];
                }
                
                dispatch_async(mainQueue, ^{
                    hud.progress = ((CGFloat)(filePathCount + (i + 1)) / (CGFloat)totalOperationCount);
                });
            }
        }
        
        dispatch_async(mainQueue, ^{
            hud.mode = MBProgressHUDModeIndeterminate;
        });
    }
}

- (void)removeiPodMusicLibrarySongs {
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:window];
    hud.dimBackground = YES;
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_MESSAGE", @"");
    hud.detailsLabelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_SUBTITLE", @"");
    [window addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        @autoreleasepool {
            // This will force the background managed object context to be created on the thread created by dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) below.
            // This is absolutely necessary and solves a major concurrency problem that can otherwise occur with the error "statement is still active."
            backgroundManagedObjectContext = nil;
            
            backgroundOperationIsActive = YES;
            [self _removeiPodMusicLibrarySongsWithHUD:hud];
            backgroundOperationIsActive = NO;
            
            // Don't forget to save the context.
            [self saveBackgroundContext];
        }
    } onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)_removeiPodMusicLibrarySongsWithHUD:(MBProgressHUD *)hud {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    NSManagedObjectContext *currentManagedObjectContext = [self backgroundManagedObjectContext];
    
    NSArray *filesArray = [self fetchedObjectsForEntityName:@"File" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES  selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"iPodMusicLibraryFile == %@", [NSNumber numberWithBool:YES]] currentManagedObjectContext:currentManagedObjectContext];
    NSInteger fileCount = [filesArray count];
    for (int i = 0; i < fileCount; i++) {
        File *file = [filesArray objectAtIndex:i];
        [self deleteFileWithoutSaving:file shouldRemoveFromDisk:NO currentManagedObjectContext:currentManagedObjectContext];
        
        dispatch_async(mainQueue, ^{
            hud.progress = ((CGFloat)(i + 1) / (CGFloat)fileCount);
        });
    }
    
    dispatch_async(mainQueue, ^{
        hud.mode = MBProgressHUDModeIndeterminate;
    });
}

- (void)addPathToFilePathsArrayIfApplicable:(NSString *)path filePathsArray:(NSMutableArray *)filePathsArray {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        // Do nothing if the file no longer exists.
        return;
    }
    
    [filePathsArray addObject:path];
    
    if (isDirectory) {
        NSArray *fileNamesArray = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:nil];
        for (int i = 0; i < [fileNamesArray count]; i++) {
            NSString *fileName = [fileNamesArray objectAtIndex:i];
            if ([fileName length] > 0) {
                if (![[fileName substringToIndex:1]isEqualToString:@"."]) {
                    NSString *filePath = [[path stringByAppendingPathComponent:fileName]stringByStandardizingPath];
                    [self addPathToFilePathsArrayIfApplicable:filePath filePathsArray:filePathsArray];
                }
            }
        }
    }
}

- (File *)importCurrentItemIfApplicableWithFilePaths:(NSArray *)filePaths existingFilePaths:(NSArray *)existingFilePaths parentDirectory:(Directory *)parentDirectory currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext completionCallback:(void (^)(void))completionCallback {
    
    @autoreleasepool {
        NSInteger filePathCount = [filePaths count];
        
        // This prevents single item imports from conflicting with library updates as they would otherwise use the same variable to keep track of the current index.
        NSInteger index = 0;
        if (existingFilePaths) {
            // Library update
            index = currentItemIndex;
        }
        else {
            // Single item import
            index = currentSingleItemIndex;
        }
        
        if (filePathCount <= index) {
            // Do nothing if there are no file paths remaining.
            return nil;
        }
        
        NSString *path = [filePaths objectAtIndex:index];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL isDirectory = NO;
        if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            // Do nothing if the file no longer exists.
            return nil;
        }
        
        File *file = nil;
        
        if (isDirectory) {
            Directory *currentDirectory = nil;
            
            NSString *directoryName = [path lastPathComponent];
            NSPredicate *predicate = nil;
            if (parentDirectory) {
                predicate = [NSPredicate predicateWithFormat:@"(parentDirectoryRef == %@) AND (name == %@)", parentDirectory, directoryName];
            }
            else {
                predicate = [NSPredicate predicateWithFormat:@"(parentDirectoryRef == nil) AND (name == %@)", directoryName];
            }
            NSArray *currentDirectoryArray = [self fetchedObjectsForEntityName:@"Directory" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:predicate currentManagedObjectContext:currentManagedObjectContext];
            if ([currentDirectoryArray count] > 0) {
                currentDirectory = [currentDirectoryArray objectAtIndex:0];
            }
            else {
                NSDate *creationDate = [[[NSFileManager defaultManager]attributesOfItemAtPath:path error:nil]fileCreationDate];
                currentDirectory = [self createFolderWithoutSavingWithName:directoryName creationDate:creationDate parentDirectory:parentDirectory currentManagedObjectContext:currentManagedObjectContext];
            }
            
            if (completionCallback) {
                completionCallback();
            }
            
            NSInteger index = 0;
            if (existingFilePaths) {
                // Library update
                currentItemIndex += 1;
                index = currentItemIndex;
            }
            else {
                // Single item import
                currentSingleItemIndex += 1;
                index = currentSingleItemIndex;
            }
            
            if (filePathCount > index) {
                // Ensure the next item in the tree is a subdirectory of the current directory before running the recursive function as a subroutine with currentDirectory as the parent directory.
                if ([[[filePaths objectAtIndex:index]pathComponents]count] > [[path pathComponents]count]) {
                    file = [self importCurrentItemIfApplicableWithFilePaths:filePaths existingFilePaths:existingFilePaths parentDirectory:currentDirectory currentManagedObjectContext:currentManagedObjectContext completionCallback:completionCallback];
                }
            }
        }
        else {
            NSString *fileName = [path lastPathComponent];
            if ([fileName length] > 0) {
                if (![[fileName substringToIndex:1]isEqualToString:@"."]) {
                    BOOL fileExists = NO;
                    
                    // This allows this function to be used for both a full library update and a single file import, while maximizing efficiency for each.
                    // If this function is being used for a single file import, a file path tree will not be generated and existingFilePaths will be nil.
                    if (existingFilePaths) {
                        fileExists = [existingFilePaths containsObject:path];
                    }
                    else {
                        NSString *fileName = [path lastPathComponent];
                        NSPredicate *predicate = nil;
                        
                        // Both File and Archive objects use the variable names parentDirectoryRef and fileName, so the same predicate can be used for either.
                        if (parentDirectory) {
                            predicate = [NSPredicate predicateWithFormat:@"(parentDirectoryRef == %@) AND (fileName == %@)", parentDirectory, fileName];
                        }
                        else {
                            predicate = [NSPredicate predicateWithFormat:@"(parentDirectoryRef == nil) AND (fileName == %@)", fileName];
                        }
                        
                        fileExists = (([[self fetchedObjectsForEntityName:@"File" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:predicate currentManagedObjectContext:currentManagedObjectContext]count] > 0) ||
                                      ([[self fetchedObjectsForEntityName:@"Archive" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:predicate currentManagedObjectContext:currentManagedObjectContext]count] > 0));
                    }
                    
                    if (!fileExists) {
                        NSDate *creationDate = [[[NSFileManager defaultManager]attributesOfItemAtPath:path error:nil]fileCreationDate];
                        
                        NSArray *audioExtensionsArray = [NSArray arrayWithObjects:@"m4a", @"m4r", @"m4b", @"m4p", @"mp4", @"3g2", @"aac", @"wav", @"aif", @"aifc", @"aiff", @"mp3", nil];
                        NSArray *archiveExtensionsArray = [NSArray arrayWithObjects:@"rar", @"cbr", @"zip", nil];
                        
                        NSString *extension = [[path pathExtension]lowercaseString];
                        
                        if ([audioExtensionsArray containsObject:extension]) {
                            TagReader *tagReader = [[TagReader alloc]initWithFileAtPath:path];
                            
                            NSString *title = tagReader.title;
                            if (!title) {
                                title = [fileName stringByDeletingPathExtension];
                            }
                            
                            file = [self createFileObjectWithoutSavingWithAlbumArtistName:tagReader.albumArtist
                                                                                albumName:tagReader.album
                                                                               artistName:tagReader.artist
                                                                                  bitRate:[NSNumber numberWithInt:tagReader.bitrate]
                                                                                 duration:[NSNumber numberWithInt:tagReader.duration]
                                                                                    genre:tagReader.genre
                                                                     iPodMusicLibraryFile:NO
                                                                           lastPlayedDate:nil
                                                                                   lyrics:tagReader.lyrics
                                                                             persistentID:nil
                                                                                playCount:nil
                                                                                   rating:nil
                                                                                    title:title
                                                                                    track:tagReader.track
                                                                                      url:[[NSURL fileURLWithPath:path]absoluteString]
                                                                                     year:tagReader.year
                                                                             creationDate:creationDate
                                                                          parentDirectory:parentDirectory
                                                              currentManagedObjectContext:currentManagedObjectContext];
                        }
                        else if ([archiveExtensionsArray containsObject:extension]) {
                            Archive *archive = [[Archive alloc]initWithEntity:[NSEntityDescription entityForName:@"Archive" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
                            archive.bytes = [NSNumber numberWithUnsignedLongLong:[[[NSFileManager defaultManager]attributesOfItemAtPath:path error:nil]fileSize]];
                            archive.creationDate = creationDate;
                            archive.fileName = [path lastPathComponent];
                            archive.parentDirectoryRef = parentDirectory;
                        }
                    }
                }
            }
            
            if (completionCallback) {
                completionCallback();
            }
            if (existingFilePaths) {
                // Library update
                currentItemIndex += 1;
            }
            else {
                // Single item import
                currentSingleItemIndex += 1;
            }
        }
        
        if (existingFilePaths) {
            // Library update
            index = currentItemIndex;
        }
        else {
            // Single item import
            index = currentSingleItemIndex;
        }
        
        if (filePathCount > index) {
            // Import the next item in the current directory if applicable.
            if ([[[filePaths objectAtIndex:index]pathComponents]count] == [[path pathComponents]count]) {
                [self importCurrentItemIfApplicableWithFilePaths:filePaths existingFilePaths:existingFilePaths parentDirectory:parentDirectory currentManagedObjectContext:currentManagedObjectContext completionCallback:completionCallback];
            }
        }
        
        return file;
    }
}

- (File *)importItemAtPathIfApplicable:(NSString *)path {
    NSInteger currentRelativePathComponentBeginningIndex = 0;
    
    // It is necessary to resolve symbolic links in the path because the path components are going to be directly compared.
    NSArray *pathComponents = [[path stringByResolvingSymlinksInPath]pathComponents];
    NSInteger pathComponentsCount = [pathComponents count];
    
    NSArray *musicDirectoryPathComponents = [kMusicDirectoryPathStr pathComponents];
    NSInteger musicDirectoryPathComponentsCount = [musicDirectoryPathComponents count];
    
    while ((pathComponentsCount > currentRelativePathComponentBeginningIndex) &&
           (musicDirectoryPathComponentsCount > currentRelativePathComponentBeginningIndex) &&
           ([[pathComponents objectAtIndex:currentRelativePathComponentBeginningIndex]isEqualToString:[musicDirectoryPathComponents objectAtIndex:currentRelativePathComponentBeginningIndex]])) {
        
        currentRelativePathComponentBeginningIndex += 1;
    }
    
    NSArray *relativePathComponents = [pathComponents subarrayWithRange:NSMakeRange(currentRelativePathComponentBeginningIndex, (pathComponentsCount - currentRelativePathComponentBeginningIndex))];
    if ([relativePathComponents count] > 0) {
        NSString *previousPath = kMusicDirectoryPathStr;
        NSMutableArray *filePathsArray = [NSMutableArray arrayWithObjects:nil];
        for (int i = 0; i < [relativePathComponents count]; i++) {
            previousPath = [previousPath stringByAppendingPathComponent:[relativePathComponents objectAtIndex:i]];
            [filePathsArray addObject:previousPath];
        }

        currentSingleItemIndex = 0;
        File *file = [self importCurrentItemIfApplicableWithFilePaths:filePathsArray existingFilePaths:nil parentDirectory:nil currentManagedObjectContext:[self managedObjectContext] completionCallback:nil];
        
        // Don't forget to save the context.
        [self saveContext];
        
        return file;
    }
    
    return nil;
}

- (BOOL)createDirectoryWithName:(NSString *)name parentDirectory:(Directory *)parentDirectory {
    if ([name rangeOfString:@"/"].length > 0) {
        UIAlertView *invalidFolderNameAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Invalid Folder Name"
                                               message:@"Folder names cannot contain slashes."
                                               delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil];
        [invalidFolderNameAlert show];
    }
    else {
        NSString *directoryPath = nil;
        if (parentDirectory) {
            directoryPath = [parentDirectory path];
        }
        else {
            directoryPath = kMusicDirectoryPathStr;
        }
        
        NSString *folderPath = [directoryPath stringByAppendingPathComponent:name];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:folderPath]) {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Item Already Exists"
                                       message:[NSString stringWithFormat:@"An item with the name \"%@\" already exists in this directory. Please rename the existing item or choose a different name for the folder.", name]
                                       delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                       otherButtonTitles:nil];
            [errorAlert show];
        }
        else {
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
            [self createFolderWithoutSavingWithName:name creationDate:[NSDate date] parentDirectory:parentDirectory currentManagedObjectContext:[self managedObjectContext]];
            [self saveContext];
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)renameDirectory:(Directory *)directory newName:(NSString *)newName {
    if ([newName rangeOfString:@"/"].length > 0) {
        UIAlertView *invalidFolderNameAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Invalid Folder Name"
                                               message:@"Folder names cannot contain slashes."
                                               delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil];
        [invalidFolderNameAlert show];
        
        return NO;
    }
    else {
        Directory *parentDirectory = directory.parentDirectoryRef;
        
        NSString *parentDirectoryPath = nil;
        if (parentDirectory) {
            parentDirectoryPath = [parentDirectory path];
        }
        else {
            parentDirectoryPath = kMusicDirectoryPathStr;
        }
        
        NSString *existingDirectoryPath = [[directory path]stringByStandardizingPath];
        NSString *directoryPath = [[parentDirectoryPath stringByAppendingPathComponent:newName]stringByStandardizingPath];
        
        if (![existingDirectoryPath isEqualToString:directoryPath]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:directoryPath]) {
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Item Already Exists"
                                           message:[NSString stringWithFormat:@"An item with the name \"%@\" already exists in this directory. Please choose a different name for the folder.", newName]
                                           delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                           otherButtonTitles:nil];
                [errorAlert show];
                
                return NO;
            }
            else {
                [fileManager moveItemAtPath:existingDirectoryPath toPath:directoryPath error:nil];
                directory.name = newName;
                [self saveContext];
            }
        }
    }
    
    return YES;
}

- (BOOL)renameArchive:(Archive *)archive newName:(NSString *)newName {
    if ([newName rangeOfString:@"/"].length > 0) {
        UIAlertView *invalidFolderNameAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Invalid File Name"
                                               message:@"File names cannot contain slashes."
                                               delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil];
        [invalidFolderNameAlert show];
        
        return NO;
    }
    else {
        Directory *parentDirectory = archive.parentDirectoryRef;
        
        NSString *parentDirectoryPath = nil;
        if (parentDirectory) {
            parentDirectoryPath = [parentDirectory path];
        }
        else {
            parentDirectoryPath = kMusicDirectoryPathStr;
        }
        
        NSString *existingArchivePath = [[archive path]stringByStandardizingPath];
        NSString *archivePath = [[parentDirectoryPath stringByAppendingPathComponent:newName]stringByStandardizingPath];
        
        if (![existingArchivePath isEqualToString:archivePath]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:archivePath]) {
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Item Already Exists"
                                           message:[NSString stringWithFormat:@"An item with the name \"%@\" already exists in this directory. Please choose a different name for the archive.", newName]
                                           delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                           otherButtonTitles:nil];
                [errorAlert show];
                
                return NO;
            }
            else {
                [fileManager moveItemAtPath:existingArchivePath toPath:archivePath error:nil];
                archive.fileName = newName;
                [self saveContext];
            }
        }
    }
    
    return YES;
}

- (void)createBookmarkWithName:(NSString *)name url:(NSString *)url parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder {
    NSInteger index = 0;
    
    NSArray *bookmarkItemsArray = [self bookmarkItemsWithParentBookmarkFolder:parentBookmarkFolder];
    if ([bookmarkItemsArray count] > 0) {
        index = ([[[bookmarkItemsArray lastObject]index]integerValue] + 1);
    }
    
    Bookmark *bookmark = [[Bookmark alloc]initWithEntity:[NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:[self managedObjectContext]];
    bookmark.name = name;
    bookmark.url = url;
    
    BookmarkItem *bookmarkItem = [[BookmarkItem alloc]initWithEntity:[NSEntityDescription entityForName:@"BookmarkItem" inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:[self managedObjectContext]];
    bookmarkItem.index = [NSNumber numberWithInteger:index];
    bookmarkItem.bookmark = [NSNumber numberWithBool:YES];
    bookmarkItem.bookmarkRef = bookmark;
    
    if (parentBookmarkFolder) {
        bookmarkItem.parentBookmarkFolderRef = parentBookmarkFolder;
        [parentBookmarkFolder addContentBookmarkItemRefsObject:bookmarkItem];
    }
    
    [self saveContext];
}

- (void)createBookmarkFolderWithName:(NSString *)name parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder {
    NSInteger index = 0;
    
    NSArray *bookmarkItemsArray = [self bookmarkItemsWithParentBookmarkFolder:parentBookmarkFolder];
    if ([bookmarkItemsArray count] > 0) {
        index = ([[[bookmarkItemsArray lastObject]index]integerValue] + 1);
    }
    
    BookmarkFolder *bookmarkFolder = [[BookmarkFolder alloc]initWithEntity:[NSEntityDescription entityForName:@"BookmarkFolder" inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:[self managedObjectContext]];
    bookmarkFolder.name = name;
    
    BookmarkItem *bookmarkItem = [[BookmarkItem alloc]initWithEntity:[NSEntityDescription entityForName:@"BookmarkItem" inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:[self managedObjectContext]];
    bookmarkItem.index = [NSNumber numberWithInteger:index];
    bookmarkItem.bookmark = [NSNumber numberWithBool:NO];
    bookmarkItem.bookmarkFolderRef = bookmarkFolder;
    
    if (parentBookmarkFolder) {
        bookmarkItem.parentBookmarkFolderRef = parentBookmarkFolder;
        [parentBookmarkFolder addContentBookmarkItemRefsObject:bookmarkItem];
    }
    
    [self saveContext];
}

- (Directory *)createFolderWithoutSavingWithName:(NSString *)folderName creationDate:(NSDate *)creationDate parentDirectory:(Directory *)parentDirectory currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    Directory *directory = [[Directory alloc]initWithEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
    directory.creationDate = creationDate;
    directory.name = folderName;
    
    if (parentDirectory) {
        directory.parentDirectoryRef = parentDirectory;
        [parentDirectory addContentDirectoriesObject:directory];
    }
    return directory;
}

- (void)createFileObjectWithAlbumArtistName:(NSString *)albumArtistName
                                  albumName:(NSString *)albumName
                                 artistName:(NSString *)artistName
                                    bitRate:(NSNumber *)bitRate
                                   duration:(NSNumber *)duration
                                      genre:(NSString *)genre
                       iPodMusicLibraryFile:(BOOL)iPodMusicLibraryFile
                                     lyrics:(NSString *)lyrics
                               persistentID:(NSNumber *)persistentID
                                  playCount:(NSNumber *)playCount
                                     rating:(NSNumber *)rating
                                      title:(NSString *)title
                                      track:(NSNumber *)track
                                        url:(NSString *)url
                                       year:(NSNumber *)year {
    
    [self createFileObjectWithoutSavingWithAlbumArtistName:albumArtistName
                                                 albumName:albumName
                                                artistName:artistName
                                                   bitRate:bitRate
                                                  duration:duration
                                                     genre:genre
                                      iPodMusicLibraryFile:iPodMusicLibraryFile
                                            lastPlayedDate:nil
                                                    lyrics:lyrics
                                              persistentID:persistentID
                                                 playCount:playCount
                                                    rating:rating
                                                     title:title
                                                     track:track
                                                       url:url
                                                      year:year
                                              creationDate:[NSDate date]
                                           parentDirectory:nil
                               currentManagedObjectContext:[self managedObjectContext]];
    
    // Don't forget to save the context.
    [self saveContext];
}

- (File *)createFileObjectWithoutSavingWithAlbumArtistName:(NSString *)albumArtistName
                                                 albumName:(NSString *)albumName
                                                artistName:(NSString *)artistName
                                                   bitRate:(NSNumber *)bitRate
                                                  duration:(NSNumber *)duration
                                                     genre:(NSString *)genre
                                      iPodMusicLibraryFile:(BOOL)iPodMusicLibraryFile
                                            lastPlayedDate:(NSDate *)lastPlayedDate
                                                    lyrics:(NSString *)lyrics
                                              persistentID:(NSNumber *)persistentID
                                                 playCount:(NSNumber *)playCount
                                                    rating:(NSNumber *)rating
                                                     title:(NSString *)title
                                                     track:(NSNumber *)track
                                                       url:(NSString *)url
                                                      year:(NSNumber *)year
                                              creationDate:(NSDate *)creationDate
                                           parentDirectory:(Directory *)parentDirectory
                               currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    
    @autoreleasepool {
        if ((albumArtistName) && ([albumArtistName length] <= 0)) {
            albumArtistName = nil;
        }
        if ((albumName) && ([albumName length] <= 0)) {
            albumName = nil;
        }
        if ((artistName) && ([artistName length] <= 0)) {
            artistName = nil;
        }
        if ((genre) && ([genre length] <= 0)) {
            genre = nil;
        }
        if ((lyrics) && ([lyrics length] <= 0)) {
            lyrics = nil;
        }
        if ((title) && ([title length] <= 0)) {
            title = nil;
        }
        if ((url) && ([url length] <= 0)) {
            url = nil;
        }
        
        File *file = [[File alloc]initWithEntity:[NSEntityDescription entityForName:@"File" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
        
        // If this is an iPod music library file, the parent directory will always be nil, so a file type conditional is unnecessary here.
        if (parentDirectory) {
            file.parentDirectoryRef = parentDirectory;
            [parentDirectory addContentFilesObject:file];
        }
        
        if (albumArtistName) {
            file.albumArtistName = albumArtistName;
        }
        if (albumName) {
            file.albumName = albumName;
        }
        if (artistName) {
            file.artistName = artistName;
        }
        
        if (!iPodMusicLibraryFile) {
            file.bitRate = bitRate;
            file.bytes = [NSNumber numberWithUnsignedLongLong:[[[NSFileManager defaultManager]attributesOfItemAtPath:[[NSURL URLWithString:url]path] error:nil]fileSize]];
        }
        
        file.creationDate = creationDate;
        file.dateAdded = [NSDate date];
        file.duration = duration;
        if (genre) {
            file.genre = genre;
        }
        file.iPodMusicLibraryFile = [NSNumber numberWithBool:iPodMusicLibraryFile];
        file.lastPlayedDate = lastPlayedDate;
        if (lyrics) {
            file.lyrics = lyrics;
        }
        if (persistentID) {
            file.persistentID = persistentID;
        }
        if (playCount) {
            file.playCount = playCount;
        }
        else {
            file.playCount = [NSNumber numberWithInteger:0];
        }
        if (rating) {
            file.rating = rating;
        }
        else {
            file.rating = [NSNumber numberWithInteger:0];
        }
        
        if ((title) && ([title length] > 0) && ([[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)) {
            file.title = title;
        }
        else {
            // If this isn't set here, songs without titles will show up at the top of the list even though they will show up with the title "Unknown", which is potentially out of order given that the title field is one of the sort descriptors.
            // file.title = NSLocalizedString(@"Unknown", @"");
            file.title = [[[[NSURL URLWithString:url]path]lastPathComponent]stringByDeletingPathExtension];
        }
        if ((track) && ([track integerValue] > 0)) {
            file.track = track;
        }
        if (url) {
            if (iPodMusicLibraryFile) {
                file.url = url;
            }
            else {
                NSURL *formattedURL = [NSURL URLWithString:url];
                file.fileName = [formattedURL lastPathComponent];
                file.uppercaseExtension = [[formattedURL pathExtension]uppercaseString];
            }
        }
        if ((year) && ([year integerValue] > 0)) {
            file.year = year;
        }
        
        if (!iPodMusicLibraryFile) {
            TagReader *tagReader = [[TagReader alloc]initWithFileAtPath:[file filePath]];
            [self updateThumbnailForFile:file artworkData:tagReader.albumArt newFile:YES];
        }
        [self setRefsForFile:file currentManagedObjectContext:currentManagedObjectContext];
        
        return file;
    }
}

- (void)updateThumbnailForFile:(File *)file artworkData:(NSData *)artworkData {
    [self updateThumbnailForFile:file artworkData:artworkData newFile:NO];
}

- (void)updateThumbnailForFile:(File *)file artworkData:(NSData *)artworkData newFile:(BOOL)newFile {
    NSString *artworkFileName = file.artworkFileName;
    if ((artworkFileName) && ([artworkFileName length] > 0)) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *artworkFilePath = [kArtworkDirectoryPathStr stringByAppendingPathComponent:artworkFileName];
        if ([fileManager fileExistsAtPath:artworkFilePath]) {
            [fileManager removeItemAtPath:artworkFilePath error:nil];;
        }
    }
    
    NSString *thumbnailFileName = file.thumbnailFileName;
    if ((thumbnailFileName) && ([thumbnailFileName length] > 0)) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *thumbnailFilePath = [kThumbnailsDirectoryPathStr stringByAppendingPathComponent:thumbnailFileName];
        if ([fileManager fileExistsAtPath:thumbnailFilePath]) {
            [fileManager removeItemAtPath:thumbnailFilePath error:nil];
        }
    }
    
    if (artworkData) {
        // This old thumbnail file could simply be overwritten, but creating a new file here allows both the initial creation and the update of the thumbnail to use the same code.
        // This also provides a safeguard in case, for whatever reason, the app cannot overwrite the old file but can create the new file on the disk.
        
        // Artwork
        
        CFUUIDRef artworkUUID = CFUUIDCreate(kCFAllocatorDefault);
        NSString *artworkUUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, artworkUUID);
        CFRelease(artworkUUID);
        
        NSString *artworkDestinationPath = [kArtworkDirectoryPathStr stringByAppendingPathComponent:artworkUUIDString];
        
        [artworkData writeToFile:artworkDestinationPath atomically:YES];
        file.artworkFileName = artworkUUIDString;
        
        // Thumbnail
        
        // This scales the artwork to fill the context regardless of the artwork's original dimensions.
        /*
        UIGraphicsBeginImageContext(CGSizeMake(THUMBNAIL_SIDE_LENGTH_IN_PIXELS, THUMBNAIL_SIDE_LENGTH_IN_PIXELS));
        [[UIImage imageWithData:artworkData]drawInRect:CGRectMake(0, 0, THUMBNAIL_SIDE_LENGTH_IN_PIXELS, THUMBNAIL_SIDE_LENGTH_IN_PIXELS)];
        UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        */
        
        UIImage *thumbnail = [[UIImage imageWithData:artworkData]imageScaledToFitSize:CGSizeMake(THUMBNAIL_SIDE_LENGTH_IN_PIXELS, THUMBNAIL_SIDE_LENGTH_IN_PIXELS)];
        
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 1);
        
        CFUUIDRef thumbnailUUID = CFUUIDCreate(kCFAllocatorDefault);
        NSString *thumbnailUUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, thumbnailUUID);
        CFRelease(thumbnailUUID);
        
        NSString *thumbnailDestinationPath = [kThumbnailsDirectoryPathStr stringByAppendingPathComponent:thumbnailUUIDString];
        
        [thumbnailData writeToFile:thumbnailDestinationPath atomically:YES];
        file.thumbnailFileName = thumbnailUUIDString;
    }
    else {
        file.artworkFileName = nil;
        file.thumbnailFileName = nil;
    }
    
    // The below code only applies to existing files.
    if (!newFile) {
        // The below code should be used to clear any cached artwork when a given file is deleted, but I haven't included this functionality because of the potential performance implications it could have should a large number of files be deleted at the same time.
        
        // Calling -refreshObject:mergeChanges: notifies the appropriate fetched results controllers that the artwork has changed so they can update the applicable table view cells without reverting the objects to their saved states (in case they have changed in the meantime).
        // The changes must be merged, otherwise the objects and their properties will be reverted to their previous states.
        
        ArtworkCache *artworkCache = [ArtworkCache sharedArtworkCache];
        ThumbnailCache *thumbnailCache = [ThumbnailCache sharedThumbnailCache];
        
        if (([artworkCache imageForKey:file]) || ([thumbnailCache imageForKey:file])) {
            [artworkCache removeImageForKey:file];
            [thumbnailCache removeImageForKey:file];
            [[self managedObjectContext]refreshObject:file mergeChanges:YES];
        }
        if (file.albumRefForAlbumArtistGroup) {
            if (([artworkCache imageForKey:file.albumRefForAlbumArtistGroup]) || ([thumbnailCache imageForKey:file.albumRefForAlbumArtistGroup])) {
                [artworkCache removeImageForKey:file.albumRefForAlbumArtistGroup];
                [thumbnailCache removeImageForKey:file.albumRefForAlbumArtistGroup];
                [[self managedObjectContext]refreshObject:file.albumRefForAlbumArtistGroup mergeChanges:YES];
            }
        }
        if (file.albumRefForArtistGroup) {
            if (([artworkCache imageForKey:file.albumRefForArtistGroup]) || ([thumbnailCache imageForKey:file.albumRefForArtistGroup])) {
                [artworkCache removeImageForKey:file.albumRefForArtistGroup];
                [thumbnailCache removeImageForKey:file.albumRefForArtistGroup];
                [[self managedObjectContext]refreshObject:file.albumRefForArtistGroup mergeChanges:YES];
            }
        }
        if (file.artistRefForAlbumArtistGroup) {
            if (([artworkCache imageForKey:file.artistRefForAlbumArtistGroup]) || ([thumbnailCache imageForKey:file.artistRefForAlbumArtistGroup])) {
                [artworkCache removeImageForKey:file.artistRefForAlbumArtistGroup];
                [thumbnailCache removeImageForKey:file.artistRefForAlbumArtistGroup];
                [[self managedObjectContext]refreshObject:file.artistRefForAlbumArtistGroup mergeChanges:YES];
            }
        }
        if (file.artistRefForArtistGroup) {
            if (([artworkCache imageForKey:file.artistRefForArtistGroup]) || ([thumbnailCache imageForKey:file.artistRefForArtistGroup])) {
                [artworkCache removeImageForKey:file.artistRefForArtistGroup];
                [thumbnailCache removeImageForKey:file.artistRefForArtistGroup];
                [[self managedObjectContext]refreshObject:file.artistRefForArtistGroup mergeChanges:YES];
            }
        }
        
        Player *player = [Player sharedPlayer];
        
        // The object ID is used here because it is consistent across managed object contexts, and the two files being compared may be in different contexts.
        if ([player.nowPlayingFile.objectID isEqual:file.objectID]) {
            // If a song is playing and the user changes its artwork, it needs to be updated on the lock screen.
            [player updateNowPlayingInfo];
        }
    }
}

- (void)setRefsForFile:(File *)file currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    @autoreleasepool {
        NSString *albumArtistName = file.albumArtistName;
        NSString *artistName = file.artistName;
        NSString *albumName = file.albumName;
        NSString *genre = file.genre;
        
        if (((!albumArtistName) || ((albumArtistName) && ([albumArtistName length] <= 0))) && ((!artistName) || ((artistName) && ([artistName length] <= 0)))) {
            // These will supplement each other if one is present and the other is not. However, if neither one is present, then both will be set here.
            albumArtistName = NSLocalizedString(@"UNKNOWN_ARTIST", @"");
            artistName = NSLocalizedString(@"UNKNOWN_ARTIST", @"");
        }
        else {
            // If one of these properties is missing, supplement it with the other one.
            // This is why the song objects have their own artist and album artist fields.
            if (!artistName) {
                artistName = albumArtistName;
            }
            else if (!albumArtistName) {
                albumArtistName = artistName;
            }
        }
        
        if ((!albumName) || ((albumName) && ([albumName length] <= 0))) {
            // Supplement the album name if applicable.
            albumName = NSLocalizedString(@"UNKNOWN_ALBUM", @"");
        }
        if ((genre) && ([genre length] <= 0)) {
            genre = nil;
        }
        
        Artist *artistForAlbumArtistGroup = nil;
        Artist *artistForArtistGroup = nil;
        Album *albumForAlbumArtistGroup = nil;
        Album *albumForArtistGroup = nil;
        Genre *genreForAllGroups = nil;
        GenreArtist *genreArtistForAlbumArtistGroup = nil;
        GenreArtist *genreArtistForArtistGroup = nil;
        GenreAlbum *genreAlbumForAlbumArtistGroup = nil;
        GenreAlbum *genreAlbumForArtistGroup = nil;
        
        // Artist and Album Artist
        
        NSArray *artistsForAlbumArtistGroup = [self fetchedObjectsForEntityName:@"Artist" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == YES) AND (name == %@)", albumArtistName] currentManagedObjectContext:currentManagedObjectContext];
        if ([artistsForAlbumArtistGroup count] >= 1) {
            artistForAlbumArtistGroup = [artistsForAlbumArtistGroup objectAtIndex:0];
        }
        else {
            artistForAlbumArtistGroup = [[Artist alloc]initWithEntity:[NSEntityDescription entityForName:@"Artist" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
            artistForAlbumArtistGroup.groupByAlbumArtist = [NSNumber numberWithBool:YES];
            artistForAlbumArtistGroup.name = albumArtistName;
        }
        
        [artistForAlbumArtistGroup addFilesForAlbumArtistGroupObject:file];
        
        file.artistRefForAlbumArtistGroup = artistForAlbumArtistGroup;
        
        NSArray *artistsForArtistGroup = [self fetchedObjectsForEntityName:@"Artist" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == NO) AND (name == %@)", artistName] currentManagedObjectContext:currentManagedObjectContext];
        if ([artistsForArtistGroup count] >= 1) {
            artistForArtistGroup = [artistsForArtistGroup objectAtIndex:0];
        }
        else {
            artistForArtistGroup = [[Artist alloc]initWithEntity:[NSEntityDescription entityForName:@"Artist" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
            artistForArtistGroup.groupByAlbumArtist = [NSNumber numberWithBool:NO];
            artistForArtistGroup.name = artistName;
        }
        
        [artistForArtistGroup addFilesForArtistGroupObject:file];
        
        file.artistRefForArtistGroup = artistForArtistGroup;
        
        // Album
        
        NSArray *albumsForAlbumArtistGroup = [self fetchedObjectsForEntityName:@"Album" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == YES) AND (artist == %@) AND (name == %@)", artistForAlbumArtistGroup, albumName] currentManagedObjectContext:currentManagedObjectContext];
        
        if ([albumsForAlbumArtistGroup count] >= 1) {
            albumForAlbumArtistGroup = [albumsForAlbumArtistGroup objectAtIndex:0];
        }
        else {
            albumForAlbumArtistGroup = [[Album alloc]initWithEntity:[NSEntityDescription entityForName:@"Album" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
            albumForAlbumArtistGroup.groupByAlbumArtist = [NSNumber numberWithBool:YES];
            albumForAlbumArtistGroup.name = albumName;
            albumForAlbumArtistGroup.artist = artistForAlbumArtistGroup;
        }
        
        [albumForAlbumArtistGroup addFilesForAlbumArtistGroupObject:file];
        
        file.albumRefForAlbumArtistGroup = albumForAlbumArtistGroup;
        [artistForAlbumArtistGroup addAlbumsObject:albumForAlbumArtistGroup];
        
        NSArray *albumsForArtistGroup = albumsForArtistGroup = [self fetchedObjectsForEntityName:@"Album" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == NO) AND (artist == %@) AND (name == %@)", artistForArtistGroup, albumName] currentManagedObjectContext:currentManagedObjectContext];
        
        if ([albumsForArtistGroup count] >= 1) {
            albumForArtistGroup = [albumsForArtistGroup objectAtIndex:0];
        }
        else {
            albumForArtistGroup = [[Album alloc]initWithEntity:[NSEntityDescription entityForName:@"Album" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
            albumForArtistGroup.groupByAlbumArtist = [NSNumber numberWithBool:NO];
            albumForArtistGroup.name = albumName;
            albumForArtistGroup.artist = artistForArtistGroup;
        }
        
        [albumForArtistGroup addFilesForArtistGroupObject:file];
        
        file.albumRefForArtistGroup = albumForArtistGroup;
        [artistForArtistGroup addAlbumsObject:albumForArtistGroup];
        
        // Genre
        
        if (genre) {
            NSArray *genres = [self fetchedObjectsForEntityName:@"Genre" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"name == %@", genre] currentManagedObjectContext:currentManagedObjectContext];
            
            if ([genres count] >= 1) {
                genreForAllGroups = [genres objectAtIndex:0];
            }
            else {
                genreForAllGroups = [[Genre alloc]initWithEntity:[NSEntityDescription entityForName:@"Genre" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
                genreForAllGroups.name = genre;
            }
            
            [genreForAllGroups addFilesObject:file];
            
            file.genreRef = genreForAllGroups;
            
            NSArray *genreArtistsForAlbumArtistGroup = [self fetchedObjectsForEntityName:@"GenreArtist" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"genre" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == YES) AND (genre == %@) AND (artist == %@)", genreForAllGroups, artistForAlbumArtistGroup] currentManagedObjectContext:currentManagedObjectContext];
            
            if ([genreArtistsForAlbumArtistGroup count] >= 1) {
                genreArtistForAlbumArtistGroup = [genreArtistsForAlbumArtistGroup objectAtIndex:0];
            }
            else {
                genreArtistForAlbumArtistGroup = [[GenreArtist alloc]initWithEntity:[NSEntityDescription entityForName:@"GenreArtist" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
                genreArtistForAlbumArtistGroup.groupByAlbumArtist = [NSNumber numberWithBool:YES];
                if (artistForAlbumArtistGroup) {
                    genreArtistForAlbumArtistGroup.artist = artistForAlbumArtistGroup;
                }
                genreArtistForAlbumArtistGroup.genre = genreForAllGroups;
            }
            
            file.genreArtistRefForAlbumArtistGroup = genreArtistForAlbumArtistGroup;
            [artistForAlbumArtistGroup addGenreArtistsObject:genreArtistForAlbumArtistGroup];
            [genreForAllGroups addGenreArtistsObject:genreArtistForAlbumArtistGroup];
            
            NSArray *genreArtistsForArtistGroup = [self fetchedObjectsForEntityName:@"GenreArtist" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"genre" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == NO) AND (genre == %@) AND (artist == %@)", genreForAllGroups, artistForArtistGroup] currentManagedObjectContext:currentManagedObjectContext];
            
            if ([genreArtistsForArtistGroup count] >= 1) {
                genreArtistForArtistGroup = [genreArtistsForArtistGroup objectAtIndex:0];
            }
            else {
                genreArtistForArtistGroup = [[GenreArtist alloc]initWithEntity:[NSEntityDescription entityForName:@"GenreArtist" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
                genreArtistForArtistGroup.groupByAlbumArtist = [NSNumber numberWithBool:NO];
                genreArtistForArtistGroup.artist = artistForArtistGroup;
                genreArtistForArtistGroup.genre = genreForAllGroups;
            }
            
            file.genreArtistRefForArtistGroup = genreArtistForArtistGroup;
            [artistForArtistGroup addGenreArtistsObject:genreArtistForArtistGroup];
            [genreForAllGroups addGenreArtistsObject:genreArtistForArtistGroup];
            
            NSArray *genreAlbumsForAlbumArtistGroup = [self fetchedObjectsForEntityName:@"GenreAlbum" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"genre" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == YES) AND (genre == %@) AND (album == %@)", genreForAllGroups, albumForAlbumArtistGroup] currentManagedObjectContext:currentManagedObjectContext];
            
            if ([genreAlbumsForAlbumArtistGroup count] >= 1) {
                genreAlbumForAlbumArtistGroup = [genreAlbumsForAlbumArtistGroup objectAtIndex:0];
            }
            else {
                genreAlbumForAlbumArtistGroup = [[GenreAlbum alloc]initWithEntity:[NSEntityDescription entityForName:@"GenreAlbum" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
                genreAlbumForAlbumArtistGroup.groupByAlbumArtist = [NSNumber numberWithBool:YES];
                if (albumForAlbumArtistGroup) {
                    genreAlbumForAlbumArtistGroup.album = albumForAlbumArtistGroup;
                }
                genreAlbumForAlbumArtistGroup.genre = genreForAllGroups;
            }
            
            file.genreAlbumRefForAlbumArtistGroup = genreAlbumForAlbumArtistGroup;
            [albumForAlbumArtistGroup addGenreAlbumsObject:genreAlbumForAlbumArtistGroup];
            [genreForAllGroups addGenreAlbumsObject:genreAlbumForAlbumArtistGroup];
            
            NSArray *genreAlbumsForArtistGroup = genreAlbumsForArtistGroup = [self fetchedObjectsForEntityName:@"GenreAlbum" sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"genre" ascending:YES selector:@selector(localizedStandardCompare:)]] predicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == NO) AND (genre == %@) AND (album == %@)", genreForAllGroups, albumForArtistGroup] currentManagedObjectContext:currentManagedObjectContext];
            
            if ([genreAlbumsForArtistGroup count] >= 1) {
                genreAlbumForArtistGroup = [genreAlbumsForArtistGroup objectAtIndex:0];
            }
            else {
                genreAlbumForArtistGroup = [[GenreAlbum alloc]initWithEntity:[NSEntityDescription entityForName:@"GenreAlbum" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
                genreAlbumForArtistGroup.groupByAlbumArtist = [NSNumber numberWithBool:NO];
                genreAlbumForArtistGroup.album = albumForArtistGroup;
                genreAlbumForArtistGroup.genre = genreForAllGroups;
            }
            
            file.genreAlbumRefForArtistGroup = genreAlbumForArtistGroup;
            [albumForArtistGroup addGenreAlbumsObject:genreAlbumForArtistGroup];
            [genreForAllGroups addGenreAlbumsObject:genreAlbumForArtistGroup];
        }
    }
}

- (void)updateRefsForFile:(File *)file {
    NSManagedObjectContext *currentManagedObjectContext = [self managedObjectContext];
    
    [self deleteRefsForFile:file currentManagedObjectContext:currentManagedObjectContext];
    
    // If the user is updating the properties of the file, the playlist items must be refreshed for consistency in the PlaylistsDetailViewController instances and elsewhere.
    if ((file.playlistItemRefs) && ([file.playlistItemRefs count] > 0)) {
        for (PlaylistItem *playlistItem in file.playlistItemRefs) {
            // Calling -refreshObject:mergeChanges: without merging the changes notifies the appropriate fetched results controllers that the file has changed so they can update the applicable table view cells without reverting the objects to their saved states (in case they have changed in the meantime). As a result, this must be called on the main fetched results controller (which runs on the main thread).
            // The changes must be merged, otherwise the item and its properties will be reverted to their previous states (in case they were modified in the meantime).
            [[self managedObjectContext]refreshObject:playlistItem mergeChanges:YES];
        }
    }
    
    // These must be cleared before the new refs are set because if a given ref isn't set it is expected to be nil.
    file.albumRefForAlbumArtistGroup = nil;
    file.albumRefForArtistGroup = nil;
    file.artistRefForAlbumArtistGroup = nil;
    file.artistRefForArtistGroup = nil;
    file.genreAlbumRefForAlbumArtistGroup = nil;
    file.genreAlbumRefForArtistGroup = nil;
    file.genreArtistRefForAlbumArtistGroup = nil;
    file.genreArtistRefForArtistGroup = nil;
    file.genreRef = nil;
    
    [self setRefsForFile:file currentManagedObjectContext:currentManagedObjectContext];
    
    Player *player = [Player sharedPlayer];
    
    // The object ID is used here because it is consistent across managed object contexts, and the two files being compared may be in different contexts.
    if ([player.nowPlayingFile.objectID isEqual:file.objectID]) {
        // If a song is playing and the user changes its properties, it needs to be updated on the lock screen.
        [player updateNowPlayingInfo];
    }
}

- (void)deleteDirectory:(Directory *)directory {
    [self deleteDirectoryWithoutSaving:directory shouldRemoveFromDisk:YES currentManagedObjectContext:[self managedObjectContext]];
    [self saveContext];
}

- (void)deleteDirectoryWithoutSaving:(Directory *)directory shouldRemoveFromDisk:(BOOL)shouldRemoveFromDisk currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    NSArray *directoriesArray = [self directoriesWithParentDirectory:directory currentManagedObjectContext:currentManagedObjectContext];
    for (int i = 0; i < [directoriesArray count]; i++) {
        Directory *contentDirectory = [directoriesArray objectAtIndex:i];
        [self deleteDirectoryWithoutSaving:contentDirectory shouldRemoveFromDisk:shouldRemoveFromDisk currentManagedObjectContext:currentManagedObjectContext];
    }
    
    NSArray *filesArray = [self filesWithParentDirectory:directory currentManagedObjectContext:currentManagedObjectContext];
    for (int i = 0; i < [filesArray count]; i++) {
        File *file = [filesArray objectAtIndex:i];
        [self deleteFileWithoutSaving:file shouldRemoveFromDisk:YES currentManagedObjectContext:currentManagedObjectContext];
    }
    
    if (shouldRemoveFromDisk) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *directoryPath = [directory path];
        if (directoryPath) {
            if ([fileManager fileExistsAtPath:directoryPath]) {
                [fileManager removeItemAtPath:directoryPath error:nil];
            }
        }
    }
    
    [currentManagedObjectContext deleteObject:directory];
}

- (void)deleteArchive:(Archive *)archive {
    [self deleteArchiveWithoutSaving:archive shouldRemoveFromDisk:YES currentManagedObjectContext:[self managedObjectContext]];
    [self saveContext];
}

- (void)deleteArchiveWithoutSaving:(Archive *)archive shouldRemoveFromDisk:(BOOL)shouldRemoveFromDisk currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    if (shouldRemoveFromDisk) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *archivePath = [archive path];
        if (archivePath) {
            if ([fileManager fileExistsAtPath:archivePath]) {
                [fileManager removeItemAtPath:archivePath error:nil];
            }
        }
    }
    
    [currentManagedObjectContext deleteObject:archive];
}

- (void)deleteFile:(File *)file {
    [self deleteFileWithoutSaving:file shouldRemoveFromDisk:YES currentManagedObjectContext:[self managedObjectContext]];
    [self saveContext];
}

- (void)deleteFiles:(NSSet *)files {
    NSManagedObjectContext *currentManagedObjectContext = [self managedObjectContext];
    NSArray *filesArray = [files allObjects];
    for (int i = 0; i < [filesArray count]; i++) {
        [self deleteFileWithoutSaving:[filesArray objectAtIndex:i] shouldRemoveFromDisk:YES currentManagedObjectContext:currentManagedObjectContext];
    }
    [self saveContext];
}

- (void)deleteFileWithoutSaving:(File *)file shouldRemoveFromDisk:(BOOL)shouldRemoveFromDisk currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    [self deleteRefsForFile:file currentManagedObjectContext:currentManagedObjectContext];
    
    // These refs should only be deleted when the file itself is deleted.
    if (file.playlistItemRefs) {
        for (PlaylistItem *playlistItem in file.playlistItemRefs) {
            [currentManagedObjectContext deleteObject:playlistItem];
        }
    }
    
    // The player is initialized on the main thread in the app delegate when the app launches, so this entire block doesn't need to run on the main thread.
    Player *player = [Player sharedPlayer];
    
    NSString *url = [[file fileURL]absoluteString];
    
    PlayerState *playerState = [player playerState];
    
    if (playerState.playlist) {
        NSMutableArray *playlist = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:playerState.playlist]];
        if ([playlist containsObject:url]) {
            if (![[NSUserDefaults standardUserDefaults]boolForKey:kShuffleKey]) {
                NSIndexSet *indexes = [playlist indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [obj isEqual:url];
                }];
                
                NSInteger currentIndex = [playerState.index integerValue];
                __block NSInteger revisedIndex = currentIndex;
                [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    if (idx < currentIndex) {
                        revisedIndex -= 1;
                    }
                }];
                
                if (revisedIndex != currentIndex) {
                    [playerState performSelectorOnMainThread:@selector(setIndex:) withObject:[NSNumber numberWithInteger:revisedIndex] waitUntilDone:YES];
                }
            }
            
            [playlist removeObject:url];
            [playerState performSelectorOnMainThread:@selector(setPlaylist:) withObject:[NSKeyedArchiver archivedDataWithRootObject:playlist] waitUntilDone:YES];
        }
    }
    
    if (playerState.shufflePlaylist) {
        NSMutableArray *shufflePlaylist = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:playerState.shufflePlaylist]];
        if ([shufflePlaylist containsObject:url]) {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kShuffleKey]) {
                NSIndexSet *indexes = [shufflePlaylist indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [obj isEqual:url];
                }];
                
                NSInteger currentIndex = [playerState.index integerValue];
                __block NSInteger revisedIndex = currentIndex;
                [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    if (idx < currentIndex) {
                        revisedIndex -= 1;
                    }
                }];
                
                if (revisedIndex != currentIndex) {
                    [playerState performSelectorOnMainThread:@selector(setIndex:) withObject:[NSNumber numberWithInteger:revisedIndex] waitUntilDone:YES];
                }
            }
            
            [shufflePlaylist removeObject:url];
            [playerState performSelectorOnMainThread:@selector(setShufflePlaylist:) withObject:[NSKeyedArchiver archivedDataWithRootObject:shufflePlaylist] waitUntilDone:YES];
        }
    }
    
    // The object ID is used here because it is consistent across managed object contexts, and the two files being compared may be in different contexts.
    if ([player.nowPlayingFile.objectID isEqual:file.objectID]) {
        [player performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:YES];
    }
    
    if (![file.iPodMusicLibraryFile boolValue]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // This value is checked as a safeguard against a filesystem tree error. If the app only needs to delete the file's reference objects because it appears as though the file no longer exists on the disk, it will not try to remove it from the disk as well (as this is unnecessary and could cause the file to be deleted if it actually does exist on the disk).
        // In addition, if the reference objects are corrupt and are deleted as a result, they will be re-created using data from the actual files (as the app deletes the unneeded reference objects before creating the applicable ones), which would otherwise be deleted (potentially unnecessarily) along with their reference objects.
        if (shouldRemoveFromDisk) {
            NSString *filePath = [file filePath];
            if (filePath) {
                if ([fileManager fileExistsAtPath:filePath]) {
                    [fileManager removeItemAtPath:filePath error:nil];
                }
            }
        }
        
        NSString *artworkFileName = file.artworkFileName;
        if ((artworkFileName) && ([artworkFileName length] > 0)) {
            NSString *artworkFilePath = [kArtworkDirectoryPathStr stringByAppendingPathComponent:artworkFileName];
            if ([fileManager fileExistsAtPath:artworkFilePath]) {
                [fileManager removeItemAtPath:artworkFilePath error:nil];
            }
        }
        
        NSString *thumbnailFileName = file.thumbnailFileName;
        if ((thumbnailFileName) && ([thumbnailFileName length] > 0)) {
            NSString *thumbnailFilePath = [kThumbnailsDirectoryPathStr stringByAppendingPathComponent:thumbnailFileName];
            if ([fileManager fileExistsAtPath:thumbnailFilePath]) {
                [fileManager removeItemAtPath:thumbnailFilePath error:nil];
            }
        }
    }
    
    [currentManagedObjectContext deleteObject:file];
}

- (void)deleteRefsForFile:(File *)file currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    if ((file.albumRefForAlbumArtistGroup) && ((!file.albumRefForAlbumArtistGroup.filesForAlbumArtistGroup) || ([file.albumRefForAlbumArtistGroup.filesForAlbumArtistGroup count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.albumRefForAlbumArtistGroup];
    }
    if ((file.albumRefForArtistGroup) && ((!file.albumRefForArtistGroup.filesForArtistGroup) || ([file.albumRefForArtistGroup.filesForArtistGroup count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.albumRefForArtistGroup];
    }
    if ((file.artistRefForAlbumArtistGroup) && ((!file.artistRefForAlbumArtistGroup.filesForAlbumArtistGroup) || ([file.artistRefForAlbumArtistGroup.filesForAlbumArtistGroup count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.artistRefForAlbumArtistGroup];
    }
    if ((file.artistRefForArtistGroup) && ((!file.artistRefForArtistGroup.filesForArtistGroup) || ([file.artistRefForArtistGroup.filesForArtistGroup count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.artistRefForArtistGroup];
    }
    if ((file.genreAlbumRefForAlbumArtistGroup) && ((!file.genreAlbumRefForAlbumArtistGroup.filesForAlbumArtistGroup) || ([file.genreAlbumRefForAlbumArtistGroup.filesForAlbumArtistGroup count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.genreAlbumRefForAlbumArtistGroup];
    }
    if ((file.genreAlbumRefForArtistGroup) && ((!file.genreAlbumRefForArtistGroup.filesForArtistGroup) || ([file.genreAlbumRefForArtistGroup.filesForArtistGroup count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.genreAlbumRefForArtistGroup];
    }
    if ((file.genreArtistRefForAlbumArtistGroup) && ((!file.genreArtistRefForAlbumArtistGroup.filesForAlbumArtistGroup) || ([file.genreArtistRefForAlbumArtistGroup.filesForAlbumArtistGroup count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.genreArtistRefForAlbumArtistGroup];
    }
    if ((file.genreArtistRefForArtistGroup) && ((!file.genreArtistRefForArtistGroup.filesForArtistGroup) || ([file.genreArtistRefForArtistGroup.filesForArtistGroup count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.genreArtistRefForArtistGroup];
    }
    if ((file.genreRef) && ((!file.genreRef.files) || ([file.genreRef.files count] <= 1))) {
        [currentManagedObjectContext deleteObject:file.genreRef];
    }
    
    // This is necessary for core data to remove the deleted file from all of its parent entities automatically in order for the above deletion mechanism to work based on the object counts.
    if ((file.albumRefForAlbumArtistGroup) && (file.albumRefForAlbumArtistGroup.filesForAlbumArtistGroup)) {
        [file.albumRefForAlbumArtistGroup removeFilesForAlbumArtistGroupObject:file];
    }
    if ((file.albumRefForArtistGroup) && (file.albumRefForArtistGroup.filesForArtistGroup)) {
        [file.albumRefForArtistGroup removeFilesForArtistGroupObject:file];
    }
    if ((file.artistRefForAlbumArtistGroup) && (file.artistRefForAlbumArtistGroup.filesForAlbumArtistGroup)) {
        [file.artistRefForAlbumArtistGroup removeFilesForAlbumArtistGroupObject:file];
    }
    if ((file.artistRefForArtistGroup) && (file.artistRefForArtistGroup.filesForArtistGroup)) {
        [file.artistRefForArtistGroup removeFilesForArtistGroupObject:file];
    }
    if ((file.genreAlbumRefForAlbumArtistGroup) && (file.genreAlbumRefForAlbumArtistGroup.filesForAlbumArtistGroup)) {
        [file.genreAlbumRefForAlbumArtistGroup removeFilesForAlbumArtistGroupObject:file];
    }
    if ((file.genreAlbumRefForArtistGroup) && (file.genreAlbumRefForArtistGroup.filesForArtistGroup)) {
        [file.genreAlbumRefForArtistGroup removeFilesForArtistGroupObject:file];
    }
    if ((file.genreArtistRefForAlbumArtistGroup) && (file.genreArtistRefForAlbumArtistGroup.filesForAlbumArtistGroup)) {
        [file.genreArtistRefForAlbumArtistGroup removeFilesForAlbumArtistGroupObject:file];
    }
    if ((file.genreArtistRefForArtistGroup) && (file.genreArtistRefForArtistGroup.filesForArtistGroup)) {
        [file.genreArtistRefForArtistGroup removeFilesForArtistGroupObject:file];
    }
    if ((file.genreRef) && (file.genreRef.files)) {
        [file.genreRef removeFilesObject:file];
    }
}

- (void)deleteAlbum:(Album *)album {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        [self deleteFiles:album.filesForAlbumArtistGroup];
    }
    else {
        [self deleteFiles:album.filesForArtistGroup];
    }
    [[self managedObjectContext]deleteObject:album];
    [self saveContext];
}

- (void)deleteArtist:(Artist *)artist {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        [self deleteFiles:artist.filesForAlbumArtistGroup];
    }
    else {
        [self deleteFiles:artist.filesForArtistGroup];
    }
    [[self managedObjectContext]deleteObject:artist];
    [self saveContext];
}

- (void)deleteGenre:(Genre *)genre {
    [self deleteFiles:genre.files];
    [[self managedObjectContext]deleteObject:genre];
    [self saveContext];
}

- (void)deleteGenreAlbum:(GenreAlbum *)genreAlbum {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        [self deleteFiles:genreAlbum.filesForAlbumArtistGroup];
    }
    else {
        [self deleteFiles:genreAlbum.filesForArtistGroup];
    }
    [[self managedObjectContext]deleteObject:genreAlbum];
    [self saveContext];
}

- (void)deleteGenreArtist:(GenreArtist *)genreArtist {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        [self deleteFiles:genreArtist.filesForAlbumArtistGroup];
    }
    else {
        [self deleteFiles:genreArtist.filesForArtistGroup];
    }
    [[self managedObjectContext]deleteObject:genreArtist];
    [self saveContext];
}

- (void)clearPlaylist:(Playlist *)playlist {
    [self clearPlaylistWithoutSaving:playlist];
    [self saveContext];
}

- (void)clearPlaylistWithoutSaving:(Playlist *)playlist {
    NSArray *playlistItemsArray = [playlist.playlistItems allObjects];
    for (int i = 0; i < [playlistItemsArray count]; i++) {
        [self deletePlaylistItemWithoutSaving:[playlistItemsArray objectAtIndex:i]];
    }
}

- (void)deletePlaylist:(Playlist *)playlist {
    [self clearPlaylistWithoutSaving:playlist];
    [[self managedObjectContext]deleteObject:playlist];
    [self saveContext];
}

- (void)deletePlaylistItem:(PlaylistItem *)playlistItem {
    [self deletePlaylistItemWithoutSaving:playlistItem];
    [self saveContext];
}

- (void)deletePlaylistItemWithoutSaving:(PlaylistItem *)playlistItem {
    // It is not necessary to process the pending changes here because playlists aren't deleted when there are no remaining playlist items (which is why there isn't a corresponding playlist deletion implementation in the file deletion function above).
    [[self managedObjectContext]deleteObject:playlistItem];
}

- (void)deleteDownload:(Download *)download {
    [self deleteDownloadWithoutSaving:download];
    [self saveContext];
}

- (void)deleteDownloadWithoutSaving:(Download *)download {
    [[[Downloader sharedDownloader]requestForDownload:download]delete];
    [[self managedObjectContext]deleteObject:download];
}

- (void)deleteBookmarkItem:(BookmarkItem *)bookmarkItem {
    [self deleteBookmarkItemWithoutSaving:bookmarkItem];
    [self saveContext];
}

- (void)deleteBookmarkItemWithoutSaving:(BookmarkItem *)bookmarkItem {
    NSManagedObjectContext *currentManagedObjectContext = [self managedObjectContext];
    
    if ([bookmarkItem.bookmark boolValue]) {
        [currentManagedObjectContext deleteObject:bookmarkItem.bookmarkRef];
    }
    else {
        NSArray *contentBookmarkItemsArray = [bookmarkItem.bookmarkFolderRef.contentBookmarkItemRefs allObjects];
        for (int i = 0; i < [contentBookmarkItemsArray count]; i++) {
            [self deleteBookmarkItemWithoutSaving:[contentBookmarkItemsArray objectAtIndex:i]];
        }
        [currentManagedObjectContext deleteObject:bookmarkItem.bookmarkFolderRef];
    }
    
    [currentManagedObjectContext deleteObject:bookmarkItem];
}

- (NSArray *)fetchedObjectsForEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    @autoreleasepool {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentManagedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:currentManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        return [fetchedResultsController fetchedObjects];
    }
}

- (void)saveContext {
    if ([self managedObjectContext]) {
        if ([[self managedObjectContext]hasChanges]) {
            NSError *error = nil;
            if (![[self managedObjectContext]save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

- (void)saveBackgroundContext {
    for (int i = 0; i < [backgroundContextPendingMergeNotifications count]; i++) {
        [backgroundManagedObjectContext mergeChangesFromContextDidSaveNotification:[backgroundContextPendingMergeNotifications objectAtIndex:i]];
    }
    [backgroundContextPendingMergeNotifications removeAllObjects];
    
    if ([self backgroundManagedObjectContext]) {
        if ([[self backgroundManagedObjectContext]hasChanges]) {
            NSError *error = nil;
            if (![[self backgroundManagedObjectContext]save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator) {
            managedObjectContext = [[NSManagedObjectContext alloc]init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return managedObjectContext;
}

- (NSManagedObjectContext *)backgroundManagedObjectContext {
    if (!backgroundManagedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator) {
            backgroundManagedObjectContext = [[NSManagedObjectContext alloc]init];
            [backgroundManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return backgroundManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (!managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle]URLForResource:@"Model" withExtension:@"momd"];
        managedObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    }
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!persistentStoreCoordinator) {
        NSURL *storeURL = [[self applicationDataStorageDirectory]URLByAppendingPathComponent:@"Data.sqlite"];
        
        NSError *error = nil;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return persistentStoreCoordinator;
}

- (NSArray *)directoriesWithParentDirectory:(Directory *)parentDirectory currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Directory" inManagedObjectContext:currentManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = nil;
    if (parentDirectory) {
        predicate = [NSPredicate predicateWithFormat:@"parentDirectoryRef == %@", parentDirectory];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"parentDirectoryRef == nil"];
    }
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:currentManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController.fetchedObjects;
}

- (NSArray *)filesWithParentDirectory:(Directory *)parentDirectory currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:currentManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:titleSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = nil;
    if (parentDirectory) {
        predicate = [NSPredicate predicateWithFormat:@"(iPodMusicLibraryFile == %@) AND (parentDirectoryRef == %@)", [NSNumber numberWithBool:NO], parentDirectory];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(iPodMusicLibraryFile == %@) AND (parentDirectoryRef == nil)", [NSNumber numberWithBool:NO]];
    }
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:currentManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController.fetchedObjects;
}

- (NSArray *)bookmarkItemsWithParentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookmarkItem" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *indexSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:indexSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = nil;
    if (parentBookmarkFolder) {
        predicate = [NSPredicate predicateWithFormat:@"parentBookmarkFolderRef == %@", parentBookmarkFolder];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"parentBookmarkFolderRef == nil"];
    }
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController.fetchedObjects;
}

#pragma mark - Application's data storage directory

// Returns the URL to the application's data storage directory.
- (NSURL *)applicationDataStorageDirectory {
    return [NSURL fileURLWithPath:kDataStorageDirectoryPathStr];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
