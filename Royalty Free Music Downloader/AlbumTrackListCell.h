//
//  AlbumTrackListCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/2/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTrackListCell : UITableViewCell {
@public
    UILabel *trackNumberLabel;
    UIImageView *nowPlayingImageView;
    UILabel *titleLabel;
    UILabel *durationLabel;
@private
    UIView *leftTitleSeparatorView;
    UIView *rightTitleSeparatorView;
}

@property (nonatomic, strong) UILabel *trackNumberLabel;
@property (nonatomic, strong) UIImageView *nowPlayingImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *durationLabel;

@end
