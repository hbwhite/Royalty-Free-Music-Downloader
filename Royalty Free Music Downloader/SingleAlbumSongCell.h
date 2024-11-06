//
//  SingleAlbumSongCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleAlbumSongCell : UITableViewCell {
@public
    UIView *fullBackgroundView;
    UILabel *trackNumberLabel;
    UILabel *titleLabel;
    UIImageView *nowPlayingImageView;
    UILabel *durationLabel;
    UIView *checkmarkOverlayView;
@private
    UIView *topSeparatorView;
    UIView *bottomSeparatorView;
    UIView *leftTitleSeparatorView1;
    UIView *leftTitleSeparatorView2;
    UIView *rightTitleSeparatorView;
}

@property (nonatomic, strong) UIView *fullBackgroundView;
@property (nonatomic, strong) UILabel *trackNumberLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *nowPlayingImageView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIView *checkmarkOverlayView;

- (void)configure;

@end
