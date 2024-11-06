//
//  Downloader.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/2/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadRequest.h"
#import "DownloadRequestDelegate.h"

@class ASINetworkQueue;
@class DownloadRequest;

@interface Downloader : NSObject <NSFetchedResultsControllerDelegate, DownloadRequestDelegate> {
@public
    NSMutableArray *downloadRequests;
    ASINetworkQueue *queue;
@private
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, strong) NSMutableArray *downloadRequests;
@property (nonatomic, strong) ASINetworkQueue *queue;

+ (Downloader *)sharedDownloader;
- (void)downloadItemAtURL:(NSURL *)url;
- (void)downloadItemWithoutSavingAtURL:(NSURL *)url;
- (void)downloadSongAtURL:(NSURL *)url;
- (void)downloadSongWithoutSavingAtURL:(NSURL *)url;
- (void)downloadArchiveAtURL:(NSURL *)url;
- (void)downloadArchiveWithoutSavingAtURL:(NSURL *)url;
- (DownloadRequest *)requestForDownload:(Download *)download;
- (void)pauseDownload:(Download *)download;
- (void)resumeDownload:(Download *)download;
- (void)deleteDownload:(Download *)download;

@end
