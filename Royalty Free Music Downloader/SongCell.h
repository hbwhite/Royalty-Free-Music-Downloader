//
//  SongCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckmarkOverlayCell.h"

@interface SongCell : CheckmarkOverlayCell {
    UIImageView *nowPlayingImageView;
}

@property (nonatomic, strong) UIImageView *nowPlayingImageView;

- (void)configure;

@end
