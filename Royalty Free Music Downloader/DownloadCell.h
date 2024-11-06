//
//  DownloadCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/15/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Download;
@class DownloadRequest;

@interface DownloadCell : UITableViewCell {
@public
    UILabel *titleLabel;
    UISlider *downloadProgressSlider;
    UILabel *detailLabel;
    UIButton *actionButton;
    UIActivityIndicatorView *processingActivityIndicatorView;
    Download *download;
    DownloadRequest *downloadRequest;
@private
    UIView *topSeparatorView;
    UIView *bottomSeparatorView;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISlider *downloadProgressSlider;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIActivityIndicatorView *processingActivityIndicatorView;
@property (nonatomic, strong) Download *download;
@property (nonatomic, strong) DownloadRequest *downloadRequest;

- (void)configure;
- (void)setDownloading;
- (void)setPaused;
- (void)setProcessing;

@end
