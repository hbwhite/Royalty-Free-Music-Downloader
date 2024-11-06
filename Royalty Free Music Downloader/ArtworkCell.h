//
//  ArtworkCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckmarkOverlayCell.h"

@interface ArtworkCell : CheckmarkOverlayCell {
@public
    UIImageView *artworkImageView;
    UIImageView *nowPlayingImageView;
    NSOperation *artworkOperation;
@private
    UIImageView *artworkBottomSeparatorView;
}

@property (nonatomic, strong) UIImageView *artworkImageView;
@property (nonatomic, strong) UIImageView *nowPlayingImageView;
@property (nonatomic, strong) NSOperation *artworkOperation;

- (void)configure;

@end
