//
//  DownloadRequest.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/4/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ASIHTTPRequest.h"
#import "DownloadRequestDelegate.h"

@class Download;
@class TTTUnitOfInformationFormatter;

enum {
    kDownloadStateWaiting = 0,
    kDownloadStateDownloading,
    kDownloadStatePaused,
    kDownloadStateFailed,
    kDownloadStateProcessing
};
typedef NSUInteger kDownloadState;

@interface DownloadRequest : ASIHTTPRequest <ASIHTTPRequestDelegate> {
@public
    id <DownloadRequestDelegate> __unsafe_unretained downloadRequestDelegate;
    UISlider __unsafe_unretained *downloadRequestProgressDelegate;
    UILabel __unsafe_unretained *downloadRequestDataDelegate;
    Download __unsafe_unretained *_download;
@private
    TTTUnitOfInformationFormatter *formatter;
}

@property (nonatomic, unsafe_unretained) id <DownloadRequestDelegate> downloadRequestDelegate;
@property (nonatomic, unsafe_unretained) UISlider *downloadRequestProgressDelegate;
@property (nonatomic, unsafe_unretained) UILabel *downloadRequestDataDelegate;
@property (nonatomic, unsafe_unretained) Download *download;

- (unsigned long long)calculatedBytesDownloaded;
- (unsigned long long)calculatedTotalBytesToDownload;
- (float)calculatedProgress;
- (void)pause;
- (void)delete;
- (NSString *)detailLabelText;
- (void)process;

@end
