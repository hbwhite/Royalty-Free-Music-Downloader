//
//  SingleAlbumHeaderCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SingleAlbumHeaderCell : UITableViewCell {
@public
    UILabel *artistLabel;
    UILabel *albumLabel;
    UILabel *detailLabel1;
    UILabel *detailLabel2;
    UIButton *shuffleButton;
@private
    UIImageView *backgroundImageView;
    UIImageView *albumArtworkImageView;
    UIImageView *albumArtworkReflectionImageView;
    UIView *bottomSeparatorView;
}

@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UILabel *albumLabel;
@property (nonatomic, strong) UILabel *detailLabel1;
@property (nonatomic, strong) UILabel *detailLabel2;
@property (nonatomic, strong) UIButton *shuffleButton;

- (void)configure;
- (void)setAlbumArtworkImage:(UIImage *)albumArtworkImage;

@end
