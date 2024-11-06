//
//  Downloader.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/2/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Downloader.h"
#import "DataManager.h"
#import "ASINetworkQueue.h"
#import "Download.h"
#import "Download+Path.h"
#import "DownloadRequest.h"
#import "FilePaths.h"
#import "SettingsViewController.h"

static Downloader *sharedDownloader             = nil;

static NSString *kSimultaneousDownloadsKey      = @"Simultaneous Downloads";
static NSString *kDownloadAttemptsKey           = @"Download Attempts";

static NSString *kCopyFormatStr                 = @" (%i)";
static NSString *kDownloadPathExtensionStr      = @"download";

@interface Downloader ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)createDownloadRequestForDownload:(Download *)download;
- (BOOL)fileExistsWithName:(NSString *)fileName;
- (NSString *)finalFileNameForFileWithName:(NSString *)fileName;

@end

@implementation Downloader

// Public
@synthesize downloadRequests;
@synthesize queue;

// Private
@synthesize fetchedResultsController;

+ (Downloader *)sharedDownloader {
    @synchronized(sharedDownloader) {
        if (!sharedDownloader) {
            sharedDownloader = [[Downloader alloc]init];
        }
        return sharedDownloader;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        downloadRequests = [[NSMutableArray alloc]init];
        
        queue = [[ASINetworkQueue alloc]init];
        queue.showAccurateProgress = YES;
        queue.shouldCancelAllRequestsOnFailure = NO;
        
        NSInteger simultaneousDownloads = [[NSUserDefaults standardUserDefaults]integerForKey:kSimultaneousDownloadsKey];
        if ((simultaneousDownloads > 0) && (simultaneousDownloads <= 50)) {
            queue.maxConcurrentOperationCount = simultaneousDownloads;
        }
        else {
            queue.maxConcurrentOperationCount = 5;
        }
        
        NSArray *savedDownloadsArray = [[self fetchedResultsController]fetchedObjects];
        for (int i = 0; i < [savedDownloadsArray count]; i++) {
            Download *download = [savedDownloadsArray objectAtIndex:i];
            [self createDownloadRequestForDownload:download];
        }
        
        [queue go];
    }
    return self;
}

- (void)downloadItemAtURL:(NSURL *)url {
    [self downloadItemWithoutSavingAtURL:url];
    [[DataManager sharedDataManager]saveContext];
}

- (void)downloadItemWithoutSavingAtURL:(NSURL *)url {
    NSArray *archiveExtensionsArray = [NSArray arrayWithObjects:@"rar", @"cbr", @"zip", nil];
    NSString *extension = [[url pathExtension]lowercaseString];
    if ([archiveExtensionsArray containsObject:extension]) {
        [self downloadArchiveWithoutSavingAtURL:url];
    }
    else {
        [self downloadSongWithoutSavingAtURL:url];
    }
}

- (void)downloadSongAtURL:(NSURL *)url {
    [self downloadSongWithoutSavingAtURL:url];
    [[DataManager sharedDataManager]saveContext];
}

- (void)downloadSongWithoutSavingAtURL:(NSURL *)url {
    NSString *title = [[[url lastPathComponent]stringByDeletingPathExtension]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // An NSURL must be used to determine the download file name because it will automatically remove any query strings in the last path component, e.g. "test.mp3?query=test"
    NSString *downloadFileName = [[url lastPathComponent]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
    
    Download *download = [NSEntityDescription insertNewObjectForEntityForName:@"Download" inManagedObjectContext:managedObjectContext];
    download.creationDate = [NSDate date];
    download.name = title;
    download.originalFileName = downloadFileName;
    download.downloadURL = [url absoluteString];
    
    NSArray *audioExtensionsArray = [NSArray arrayWithObjects:@"m4a", @"m4r", @"m4b", @"m4p", @"mp4", @"3g2", @"aac", @"wav", @"aif", @"aifc", @"aiff", @"mp3", nil];
    if (![audioExtensionsArray containsObject:[[downloadFileName pathExtension]lowercaseString]]) {
        downloadFileName = [downloadFileName stringByAppendingString:@"mp3"];
    }
    
    download.temporaryDownloadFileName = [self finalFileNameForFileWithName:[downloadFileName stringByAppendingPathExtension:kDownloadPathExtensionStr]];
    download.downloadDestinationFileName = [self finalFileNameForFileWithName:downloadFileName];
    
    [self createDownloadRequestForDownload:download];
}

- (void)downloadArchiveAtURL:(NSURL *)url {
    [self downloadArchiveWithoutSavingAtURL:url];
    [[DataManager sharedDataManager]saveContext];
}

- (void)downloadArchiveWithoutSavingAtURL:(NSURL *)url {
    NSString *title = [[[url lastPathComponent]stringByDeletingPathExtension]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // An NSURL must be used to determine the download file name because it will automatically remove any query strings in the last path component, e.g. "test.mp3?query=test"
    NSString *downloadFileName = [[url lastPathComponent]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
    
    Download *download = [NSEntityDescription insertNewObjectForEntityForName:@"Download" inManagedObjectContext:managedObjectContext];
    download.creationDate = [NSDate date];
    download.name = title;
    download.originalFileName = downloadFileName;
    download.downloadURL = [url absoluteString];
    
    NSArray *archiveExtensionsArray = [NSArray arrayWithObjects:@"rar", @"cbr", @"zip", nil];
    if (![archiveExtensionsArray containsObject:[[downloadFileName pathExtension]lowercaseString]]) {
        downloadFileName = [downloadFileName stringByAppendingString:@"zip"];
    }
    
    download.temporaryDownloadFileName = [self finalFileNameForFileWithName:[downloadFileName stringByAppendingPathExtension:kDownloadPathExtensionStr]];
    download.downloadDestinationFileName = [self finalFileNameForFileWithName:downloadFileName];
    
    [self createDownloadRequestForDownload:download];
}

- (DownloadRequest *)requestForDownload:(Download *)download {
    for (int i = 0; i < [downloadRequests count]; i++) {
        DownloadRequest *request = [downloadRequests objectAtIndex:i];
        if ([request.download isEqual:download]) {
            return request;
        }
    }
    return nil;
}

- (void)pauseDownload:(Download *)download {
    [[self requestForDownload:download]pause];
}

- (void)resumeDownload:(Download *)download {
    download.state = [NSNumber numberWithInteger:kDownloadStateWaiting];
    [[DataManager sharedDataManager]saveContext];
    
    [self createDownloadRequestForDownload:download];
}

- (void)deleteDownload:(Download *)download {
    [[DataManager sharedDataManager]deleteDownload:download];
}

- (void)createDownloadRequestForDownload:(Download *)download {
    kDownloadState downloadState = [download.state integerValue];
    if ((downloadState == kDownloadStateWaiting) || (downloadState == kDownloadStateDownloading) || (downloadState == kDownloadStateProcessing)) {
        DownloadRequest *downloadRequest = [[DownloadRequest alloc]initWithURL:[NSURL URLWithString:download.downloadURL]];
        downloadRequest.downloadRequestDelegate = self;
        downloadRequest.timeOutSeconds = 120;
        
        NSInteger downloadAttempts = [[NSUserDefaults standardUserDefaults]integerForKey:kDownloadAttemptsKey];
        if ((downloadAttempts > 0) && (downloadAttempts <= 50)) {
            downloadRequest.numberOfTimesToRetryOnTimeout = downloadAttempts;
        }
        else {
            downloadRequest.numberOfTimesToRetryOnTimeout = 5;
        }
        
        downloadRequest.allowResumeForFileDownloads = YES;
        downloadRequest.shouldContinueWhenAppEntersBackground = YES;
        downloadRequest.temporaryFileDownloadPath = [download temporaryDownloadFilePath];
        downloadRequest.downloadDestinationPath = [download downloadDestinationFilePath];
        downloadRequest.showAccurateProgress = YES;
        downloadRequest.download = download;
        
        NSInteger downloadState = [download.state integerValue];
        if (downloadState == kDownloadStateProcessing) {
            [downloadRequest performSelectorInBackground:@selector(process) withObject:nil];
        }
        else if (downloadState != kDownloadStateFailed) {
            [downloadRequests addObject:downloadRequest];
            [queue addOperation:downloadRequest];
        }
    }
}

- (void)downloadRequestDidFinish:(DownloadRequest *)request {
    [downloadRequests performSelectorOnMainThread:@selector(removeObject:) withObject:request waitUntilDone:YES];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:creationDateSortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // This delegate method must be implemented (in addition to the delegate being set) for the fetched results controller to track changes to the managed object context.
}

- (BOOL)fileExistsWithName:(NSString *)fileName {
    // All directories are searched for consistency and simplicity.
    
    NSString *formattedFileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *searchPathsArray = [NSArray arrayWithObjects:kTemporaryDownloadDirectoryPathStr, kMusicDirectoryPathStr, nil];
    for (NSString *searchPath in searchPathsArray) {
        NSString *filePath = [searchPath stringByAppendingPathComponent:formattedFileName];
        if ([fileManager fileExistsAtPath:filePath]) {
            return YES;
        }
    }
    
    NSArray *downloads = [[self fetchedResultsController]fetchedObjects];
    for (int i = 0; i < [downloads count]; i++) {
        Download *download = [downloads objectAtIndex:i];
        if ([download.temporaryDownloadFileName isEqualToString:formattedFileName]) {
            return YES;
        }
        else if ([download.downloadDestinationFileName isEqualToString:formattedFileName]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)finalFileNameForFileWithName:(NSString *)fileName {
    NSString *finalFileName = @"Untitled";
    if ((fileName) && ([fileName length] > 0)) {
        finalFileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    }
    
    if ([self fileExistsWithName:finalFileName]) {
        NSString *filePathExtension = [finalFileName pathExtension];
        if ([filePathExtension length] > 0) {
            NSString *baseFileName = [finalFileName stringByDeletingPathExtension];
            
            NSInteger copyNumber = 2;
            while ([self fileExistsWithName:[[baseFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]stringByAppendingPathExtension:filePathExtension]]) {
                copyNumber += 1;
            }
            return [[baseFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]stringByAppendingPathExtension:filePathExtension];
        }
        else {
            NSInteger copyNumber = 2;
            while ([self fileExistsWithName:[finalFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]]) {
                copyNumber += 1;
            }
            return [finalFileName stringByAppendingFormat:kCopyFormatStr, copyNumber];
        }
    }
    else {
        return finalFileName;
    }
}

@end
