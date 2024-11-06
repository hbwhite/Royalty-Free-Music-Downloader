//
//  DownloadCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/15/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "DownloadCell.h"
#import "Downloader.h"
#import "Download.h"
#import "SkinManager.h"

@interface DownloadCell ()

@property (nonatomic, strong) UIView *topSeparatorView;
@property (nonatomic, strong) UIView *bottomSeparatorView;

- (void)actionButtonPressed;

@end

@implementation DownloadCell

// Public
@synthesize titleLabel;
@synthesize downloadProgressSlider;
@synthesize detailLabel;
@synthesize actionButton;
@synthesize processingActivityIndicatorView;
@synthesize download;
@synthesize downloadRequest;

// Private
@synthesize topSeparatorView;
@synthesize bottomSeparatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, (self.contentView.frame.size.width - 17), 23)];
        titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        
        downloadProgressSlider = [[UISlider alloc]init];
        
        if ([SkinManager iOS7]) {
            downloadProgressSlider.frame = CGRectMake(8, 11, (self.contentView.frame.size.width - 15), 23);
        }
        else {
            downloadProgressSlider.frame = CGRectMake(8, 16, (self.contentView.frame.size.width - 15), 23);
        }
        
        downloadProgressSlider.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);
        downloadProgressSlider.userInteractionEnabled = NO;
        [downloadProgressSlider setThumbImage:[UIImage imageNamed:@"Transparency"] forState:UIControlStateNormal];
        downloadProgressSlider.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:downloadProgressSlider];
        
        detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 32, (self.contentView.frame.size.width - 17), 23)];
        detailLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);
        detailLabel.textColor = [UIColor grayColor];
        detailLabel.font = [UIFont systemFontOfSize:12];
        detailLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:detailLabel];
        
        actionButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 29, 29)];
        [actionButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        processingActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        processingActivityIndicatorView.frame = CGRectMake(0, 0, 20, 20);
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self setDownloading];
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        // This prevents duplicate separator views from being added to the cell, leaving vestigial separators that are unaccounted for.
        
        if (!topSeparatorView) {
            topSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
            topSeparatorView.backgroundColor = [UIColor whiteColor];
            topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self insertSubview:topSeparatorView atIndex:0];
        }
        
        if (!bottomSeparatorView) {
            // A height of 55 is expected.
            bottomSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 54, self.frame.size.width, 1)];
            bottomSeparatorView.backgroundColor = [SkinManager iOS6SkinSeparatorColor];
            bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:bottomSeparatorView];
        }
        
        titleLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        
        detailLabel.textColor = [SkinManager iOS6SkinLightTextColor];
        detailLabel.shadowColor = [UIColor whiteColor];
        detailLabel.shadowOffset = CGSizeMake(0, 1);
        
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        if (topSeparatorView) {
            [topSeparatorView removeFromSuperview];
            topSeparatorView = nil;
        }
        if (bottomSeparatorView) {
            [bottomSeparatorView removeFromSuperview];
            bottomSeparatorView = nil;
        }
        
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.shadowColor = nil;
        titleLabel.shadowOffset = CGSizeMake(0, -1);
        
        detailLabel.textColor = [UIColor grayColor];
        detailLabel.shadowColor = nil;
        detailLabel.shadowOffset = CGSizeMake(0, -1);
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setDownloading {
    [actionButton setImage:[UIImage skinImageNamed:@"Download_Pause_Button"] forState:UIControlStateNormal];
    [actionButton setImage:[UIImage skinImageNamed:@"Download_Pause_Button-Selected"] forState:UIControlStateHighlighted];
    self.accessoryView = actionButton;
}

- (void)setPaused {
    [actionButton setImage:[UIImage skinImageNamed:@"Download_Resume_Button"] forState:UIControlStateNormal];
    [actionButton setImage:[UIImage skinImageNamed:@"Download_Resume_Button-Selected"] forState:UIControlStateHighlighted];
    self.accessoryView = actionButton;
}

- (void)setProcessing {
    self.accessoryView = processingActivityIndicatorView;
    [processingActivityIndicatorView startAnimating];
}

- (void)actionButtonPressed {
    if (download) {
        kDownloadState downloadState = [download.state integerValue];
        if (downloadState != kDownloadStateWaiting) {
            Downloader *downloader = [Downloader sharedDownloader];
            
            if ([download.state integerValue] == kDownloadStateDownloading) {
                [downloader pauseDownload:download];
            }
            else {
                [downloader resumeDownload:download];
            }
        }
    }
}

- (void)dealloc {
    self.downloadRequest.downloadRequestProgressDelegate = nil;
    self.downloadRequest.downloadRequestDataDelegate = nil;
}

@end
