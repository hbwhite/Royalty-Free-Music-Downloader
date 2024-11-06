//
//  DownloadRequest.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/4/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "DownloadRequest.h"
#import "Downloader.h"
#import "Download.h"
#import "Archive.h"
#import "DataManager.h"
#import "TagReader.h"
#import "AppDelegate.h"
#import "TTTUnitOfInformationFormatter.h"
#import "FilePaths.h"

#import <math.h>

static NSString *kAutomaticallyRenameDownloadsKey   = @"Automatically Rename Downloads";
static NSString *kIncludeArtistInFileNameKey        = @"Include Artist In File Name";
static NSString *kDownloadNotificationsKey          = @"Download Notifications";

static NSString *kGroupByAlbumArtistKey             = @"Group By Album Artist";

static NSString *kCopyFormatStr                     = @" (%i)";

@interface DownloadRequest ()

@property (nonatomic, strong) TTTUnitOfInformationFormatter *formatter;

- (void)postDownloadNotificationIfApplicableWithName:(NSString *)name success:(BOOL)success;
- (BOOL)fileExistsWithName:(NSString *)fileName;
- (NSString *)finalFileNameForFileWithName:(NSString *)fileName;
- (NSString *)downloadDestinationPathForFileWithName:(NSString *)fileName;

@end

@implementation DownloadRequest

// Public
@synthesize downloadRequestDelegate;
@synthesize downloadRequestProgressDelegate;
@synthesize downloadRequestDataDelegate;
@synthesize download = _download;

// Private
@synthesize formatter;

- (id)initWithURL:(NSURL *)newURL {
    self = [super initWithURL:newURL];
    if (self) {
        self.delegate = self;
        self.downloadProgressDelegate = self;
        
        formatter = [[TTTUnitOfInformationFormatter alloc]init];
        [formatter setDisplaysInTermsOfBytes:YES];
        [formatter setUsesIECBinaryPrefixesForCalculation:NO];
        [formatter setUsesIECBinaryPrefixesForDisplay:NO];
    }
    return self;
}

// If the requests are canceled and restarted, the bytesDownloadedSoFar and totalBytesToDownload properties of the ASINetworkQueue can become inaccurate.
// To ensure that these values are always accurate, the following functions are used instead.

- (unsigned long long)calculatedBytesDownloaded {
    return (totalBytesRead + partialDownloadSize);
}

- (unsigned long long)calculatedTotalBytesToDownload {
    return (contentLength + partialDownloadSize);
}

- (float)calculatedProgress {
    unsigned long long calculatedTotalBytesToDownload = [self calculatedTotalBytesToDownload];
    if (calculatedTotalBytesToDownload > 0) {
        return (float)(([self calculatedBytesDownloaded] * 1.0) / (calculatedTotalBytesToDownload * 1.0));
    }
    return 0;
}

// If the requests are canceled and restarted, the progress property of the ASINetworkQueue can become inaccurate.
// To ensure that this value is always accurate, the following function is only used as a notification that the progress changed.

- (void)setProgress:(float)newProgress {
    float calculatedNewProgress = [self calculatedProgress];
    
    // The app will crash if the float value of the progress is NaN and it tries to set the value of the download progress slider accordingly.
    if (!isnan(calculatedNewProgress)) {
        if (downloadRequestProgressDelegate) {
            if ([downloadRequestProgressDelegate respondsToSelector:@selector(setValue:)]) {
                [downloadRequestProgressDelegate setValue:calculatedNewProgress];
            }
        }
    }
    
    if (downloadRequestDataDelegate) {
        if ([downloadRequestDataDelegate respondsToSelector:@selector(setText:)]) {
            [downloadRequestDataDelegate setText:[self detailLabelText]];
        }
    }
}

- (NSString *)detailLabelText {
    if (totalBytesRead > 0) {
        unsigned long long calculatedBytesDownloaded = [self calculatedBytesDownloaded];
        unsigned long long calculatedTotalBytesToDownload = [self calculatedTotalBytesToDownload];
        
        NSString *expectedSizeString = nil;
        if ((calculatedTotalBytesToDownload > 0) && (calculatedBytesDownloaded <= calculatedTotalBytesToDownload)) {
            expectedSizeString = [formatter stringFromNumber:[NSNumber numberWithUnsignedLongLong:calculatedTotalBytesToDownload] ofUnit:TTTByte];
        }
        else {
            expectedSizeString = @"Unknown Size";
        }
        
        return [NSString stringWithFormat:@"%@ of %@", [formatter stringFromNumber:[NSNumber numberWithUnsignedLongLong:calculatedBytesDownloaded] ofUnit:TTTByte], expectedSizeString];
    }
    else {
        return @"Preparing to download...";
    }
}

- (void)pause {
    [self clearDelegatesAndCancel];
    [self setDidFailSelector:nil];
    [self setDidFinishSelector:nil];
    
    if (downloadRequestDelegate) {
        if ([downloadRequestDelegate respondsToSelector:@selector(downloadRequestDidFinish:)]) {
            [downloadRequestDelegate downloadRequestDidFinish:self];
        }
    }
    
    self.download.state = [NSNumber numberWithInteger:kDownloadStatePaused];
    [[DataManager sharedDataManager]saveContext];
}

- (void)delete {
    [self clearDelegatesAndCancel];
    [self setDidFailSelector:nil];
    [self setDidFinishSelector:nil];
    
    if (downloadRequestDelegate) {
        if ([downloadRequestDelegate respondsToSelector:@selector(downloadRequestDidFinish:)]) {
            [downloadRequestDelegate downloadRequestDidFinish:self];
        }
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // These are safeguards in case a file path is incorrectly set to the path of a parent directory or other directory (downloads will not be directories).
    
    BOOL temporaryFileIsDirectory = NO;
    [fileManager fileExistsAtPath:temporaryFileDownloadPath isDirectory:&temporaryFileIsDirectory];
    
    if (!temporaryFileIsDirectory) {
        [fileManager removeItemAtPath:temporaryFileDownloadPath error:nil];
    }
    
    BOOL destinationFileIsDirectory = NO;
    [fileManager fileExistsAtPath:downloadDestinationPath isDirectory:&destinationFileIsDirectory];
    
    if (!destinationFileIsDirectory) {
        [fileManager removeItemAtPath:downloadDestinationPath error:nil];
    }
}

- (void)requestStarted:(ASIHTTPRequest *)request {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        self.download.state = [NSNumber numberWithInteger:kDownloadStateDownloading];
        [[DataManager sharedDataManager]saveContext];
    });
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        self.download.state = [NSNumber numberWithInteger:kDownloadStateProcessing];
        [[DataManager sharedDataManager]saveContext];
        
        [self performSelectorInBackground:@selector(process) withObject:nil];
    });
    
    if (downloadRequestDelegate) {
        if ([downloadRequestDelegate respondsToSelector:@selector(downloadRequestDidFinish:)]) {
            [downloadRequestDelegate downloadRequestDidFinish:self];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        self.download.state = [NSNumber numberWithInteger:kDownloadStateFailed];
        [[DataManager sharedDataManager]saveContext];
    });
    
    if (downloadRequestDelegate) {
        if ([downloadRequestDelegate respondsToSelector:@selector(downloadRequestDidFinish:)]) {
            [downloadRequestDelegate downloadRequestDidFinish:self];
        }
    }
    
    [self postDownloadNotificationIfApplicableWithName:self.download.name success:NO];
}

- (void)postDownloadNotificationIfApplicableWithName:(NSString *)name success:(BOOL)success {
    if (([(AppDelegate *)[[UIApplication sharedApplication]delegate]isRunningInBackground]) && ([[NSUserDefaults standardUserDefaults]boolForKey:kDownloadNotificationsKey])) {
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        
        if (name) {
            if (success) {
                notification.alertBody = [@"Download Complete: " stringByAppendingString:name];
            }
            else {
                notification.alertBody = [@"Download Failed: " stringByAppendingString:name];
            }
        }
        else {
            if (success) {
                notification.alertBody = @"Download Complete";
            }
            else {
                notification.alertBody = @"Download Failed";
            }
        }
        
        notification.alertAction = @"View";
        notification.fireDate = [NSDate date];
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication]presentLocalNotificationNow:notification];
    }
}

- (void)process {
    // This function is performed in the background and allocates memory.
    // To ensure that it does not leak memory on devices running iOS 4, its contents must be contained within an autorelease pool block.
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        while (![fileManager fileExistsAtPath:downloadDestinationPath]);
        
        NSArray *archiveExtensionsArray = [NSArray arrayWithObjects:@"rar", @"cbr", @"zip", nil];
        NSString *extension = [[downloadDestinationPath pathExtension]lowercaseString];
        if ([archiveExtensionsArray containsObject:extension]) {
            NSString *fileName = [downloadDestinationPath lastPathComponent];
            
            if ((!fileName) || ([[fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] <= 0)) {
                fileName = @"Untitled";
            }
            
            NSString *filePath = [self downloadDestinationPathForFileWithName:fileName];
            
            [fileManager moveItemAtPath:downloadDestinationPath toPath:filePath error:nil];
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                DataManager *dataManager = [DataManager sharedDataManager];
                NSManagedObjectContext *managedObjectContext = [dataManager managedObjectContext];
                
                Archive *archive = [[Archive alloc]initWithEntity:[NSEntityDescription entityForName:@"Archive" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
                archive.bytes = [NSNumber numberWithUnsignedLongLong:[[[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil]fileSize]];
                archive.creationDate = [NSDate date];
                archive.fileName = fileName;
                
                [dataManager saveContext];
                
                [dataManager deleteDownload:self.download];
                
                [self postDownloadNotificationIfApplicableWithName:fileName success:YES];
            });
        }
        else {
            TagReader *tagReader = [[TagReader alloc]initWithFileAtPath:downloadDestinationPath];
            
            NSString *title = tagReader.title;
            
            if ((!title) || ([[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] <= 0)) {
                title = [self.download.originalFileName stringByDeletingPathExtension];
            }
            
            if ((!title) || ([[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] <= 0)) {
                title = @"Untitled";
            }
            
            NSString *fileBaseName = [self.download.originalFileName stringByDeletingPathExtension];
            
            if ((!fileBaseName) || ([[fileBaseName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] <= 0)) {
                fileBaseName = @"Untitled";
            }
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults boolForKey:kAutomaticallyRenameDownloadsKey]) {
                if (([defaults boolForKey:kIncludeArtistInFileNameKey]) && (((tagReader.artist) && ([[tagReader.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)) ||
                                                                            ((tagReader.albumArtist) && ([[tagReader.albumArtist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)))) {
                    
                    if ([defaults boolForKey:kGroupByAlbumArtistKey]) {
                        if ((tagReader.albumArtist) && ([[tagReader.albumArtist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)) {
                            fileBaseName = [[tagReader.albumArtist stringByAppendingString:@" - "]stringByAppendingString:title];
                        }
                        else {
                            fileBaseName = [[tagReader.artist stringByAppendingString:@" - "]stringByAppendingString:title];
                        }
                    }
                    else {
                        if ((tagReader.artist) && ([[tagReader.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)) {
                            fileBaseName = [[tagReader.artist stringByAppendingString:@" - "]stringByAppendingString:title];
                        }
                        else {
                            fileBaseName = [[tagReader.albumArtist stringByAppendingString:@" - "]stringByAppendingString:title];
                        }
                    }
                }
                else {
                    fileBaseName = title;
                }
            }
            
            NSString *fileName = fileBaseName;
            
            NSString *pathExtension = [downloadDestinationPath pathExtension];
            if (pathExtension) {
                fileName = [fileBaseName stringByAppendingPathExtension:pathExtension];
            }
            
            NSString *filePath = [self downloadDestinationPathForFileWithName:fileName];
            
            [fileManager moveItemAtPath:downloadDestinationPath toPath:filePath error:nil];
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                DataManager *dataManager = [DataManager sharedDataManager];
                
                [dataManager createFileObjectWithAlbumArtistName:tagReader.albumArtist
                                                       albumName:tagReader.album
                                                      artistName:tagReader.artist
                                                         bitRate:[NSNumber numberWithInt:tagReader.bitrate]
                                                        duration:[NSNumber numberWithInt:tagReader.duration]
                                                           genre:tagReader.genre
                                            iPodMusicLibraryFile:NO
                                                          lyrics:tagReader.lyrics
                                                    persistentID:nil
                                                       playCount:nil
                                                          rating:nil
                                                           title:title
                                                           track:tagReader.track
                                                             url:[[NSURL fileURLWithPath:filePath]absoluteString]
                                                            year:tagReader.year];
                
                [dataManager deleteDownload:self.download];
                
                [self postDownloadNotificationIfApplicableWithName:title success:YES];
            });
        }
    }
}

- (BOOL)fileExistsWithName:(NSString *)fileName {
    NSString *formattedFileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *filePath = [kMusicDirectoryPathStr stringByAppendingPathComponent:formattedFileName];
    return [[NSFileManager defaultManager]fileExistsAtPath:filePath];
}

- (NSString *)finalFileNameForFileWithName:(NSString *)fileName {
    NSString *finalFileName = @"Untitled";
    if ((fileName) && ([fileName length] > 0)) {
        finalFileName = fileName;
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

- (NSString *)downloadDestinationPathForFileWithName:(NSString *)fileName {
    NSString *formattedFileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    return [kMusicDirectoryPathStr stringByAppendingPathComponent:[self finalFileNameForFileWithName:formattedFileName]];
}

@end
