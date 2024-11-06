//
//  SingleAlbumHeaderCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SingleAlbumHeaderCell.h"
#import "SkinManager.h"
#import "UIImage+SkinImage.h"
#import "UIImage+SafeStretchableImage.h"

#define SEPARATOR_COLOR_WHITE_VALUE (208.0 / 255.0)

@interface SingleAlbumHeaderCell ()

@property (nonatomic, strong) UIView *backgroundImageView;
@property (nonatomic, strong) UIImageView *albumArtworkImageView;
@property (nonatomic, strong) UIImageView *albumArtworkReflectionImageView;
@property (nonatomic, strong) UIView *bottomSeparatorView;

@end

@implementation SingleAlbumHeaderCell

// Public
@synthesize artistLabel;
@synthesize albumLabel;
@synthesize detailLabel1;
@synthesize detailLabel2;
@synthesize shuffleButton;

// Private
@synthesize backgroundImageView;
@synthesize albumArtworkImageView;
@synthesize albumArtworkReflectionImageView;
@synthesize bottomSeparatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 115)];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self insertSubview:backgroundImageView atIndex:0];
        
        albumArtworkImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 90, 90)];
        albumArtworkImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        albumArtworkImageView.backgroundColor = [UIColor blackColor];
        albumArtworkImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:albumArtworkImageView];
        
        albumArtworkReflectionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 90, 90)];
        albumArtworkReflectionImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        albumArtworkReflectionImageView.alpha = 1;
        albumArtworkReflectionImageView.backgroundColor = [UIColor blackColor];
        albumArtworkReflectionImageView.contentMode = UIViewContentModeScaleAspectFit;
        albumArtworkReflectionImageView.transform = CGAffineTransformScale(albumArtworkReflectionImageView.transform, 1, -1);
        
        CAGradientLayer *reflectionFadeLayer = [CAGradientLayer layer];
        reflectionFadeLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:1 alpha:1].CGColor, nil];
        reflectionFadeLayer.startPoint = CGPointMake(0, 1);
        reflectionFadeLayer.endPoint = CGPointMake(0, 0.8);
        reflectionFadeLayer.frame = CGRectMake(0, 0, 90, 90);
        [albumArtworkReflectionImageView.layer addSublayer:reflectionFadeLayer];
        
        [self.contentView addSubview:albumArtworkReflectionImageView];
        
        artistLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 10, 200, 15)];
        artistLabel.backgroundColor = [UIColor clearColor];
        artistLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        artistLabel.font = [UIFont boldSystemFontOfSize:14];
        artistLabel.adjustsFontSizeToFitWidth = YES;
        artistLabel.minimumFontSize = 9;
        [self.contentView addSubview:artistLabel];
        
        albumLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 25, 200, 20)];
        albumLabel.backgroundColor = [UIColor clearColor];
        albumLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        albumLabel.font = [UIFont boldSystemFontOfSize:16];
        albumLabel.adjustsFontSizeToFitWidth = YES;
        albumLabel.minimumFontSize = 9;
        [self.contentView addSubview:albumLabel];
        
        detailLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(110, 45, 200, 15)];
        detailLabel1.backgroundColor = [UIColor clearColor];
        detailLabel1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        detailLabel1.textColor = [UIColor colorWithWhite:(109.0 / 255.0) alpha:1];
        detailLabel1.adjustsFontSizeToFitWidth = YES;
        detailLabel1.minimumFontSize = 9;
        [self.contentView addSubview:detailLabel1];
        
        detailLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(110, 60, 200, 15)];
        detailLabel2.backgroundColor = [UIColor clearColor];
        detailLabel2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        detailLabel2.textColor = [UIColor colorWithWhite:(109.0 / 255.0) alpha:1];
        detailLabel2.adjustsFontSizeToFitWidth = YES;
        detailLabel2.minimumFontSize = 9;
        [self.contentView addSubview:detailLabel2];
        
        shuffleButton = [[UIButton alloc]init];
        shuffleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        shuffleButton.imageView.contentMode = UIViewContentModeCenter;
        shuffleButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        shuffleButton.titleLabel.shadowOffset = CGSizeMake(shuffleButton.titleLabel.frame.size.width, 1);
        [shuffleButton setTitleColor:[UIColor colorWithWhite:(65.0 / 255.0) alpha:1] forState:UIControlStateNormal];
        [shuffleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [shuffleButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shuffleButton setTitleShadowColor:[UIColor colorWithWhite:(65.0 / 255.0) alpha:1] forState:UIControlStateHighlighted];
        [shuffleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 30)];
        [self.contentView addSubview:shuffleButton];
        
        // This is necessary to prevent the album artwork reflection from "overflowing" into the table view.
        self.clipsToBounds = YES;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configure {
    backgroundImageView.image = [UIImage skinImageNamed:@"Single_Album_Header_Gradient"];
    
    // This prevents duplicate separator views from being added to the cell, leaving vestigial separators that are unaccounted for.
    
    if ([SkinManager iOS6Skin]) {
        artistLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        albumLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        detailLabel1.textColor = [SkinManager iOS6SkinLightGrayColor];
        detailLabel2.textColor = [SkinManager iOS6SkinLightGrayColor];
        
        shuffleButton.frame = CGRectMake((self.contentView.frame.size.width - 57), 74, 49, 28);
        [shuffleButton setTitle:nil forState:UIControlStateNormal];
        [shuffleButton setBackgroundImage:[UIImage imageNamed:@"Shuffle_Button-6"] forState:UIControlStateNormal];
        [shuffleButton setBackgroundImage:[UIImage imageNamed:@"Shuffle_Button-Selected-6"] forState:UIControlStateHighlighted];
        
        if (!bottomSeparatorView) {
            bottomSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 114, self.frame.size.width, 1)];
            bottomSeparatorView.backgroundColor = [SkinManager iOS6SkinSeparatorColor];
            bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.contentView addSubview:bottomSeparatorView];
        }
    }
    else {
        artistLabel.textColor = [UIColor blackColor];
        albumLabel.textColor = [UIColor blackColor];
        
        if ([SkinManager iOS7Skin]) {
            detailLabel1.textColor = [UIColor blackColor];
            detailLabel2.textColor = [UIColor blackColor];
            
            albumArtworkReflectionImageView.hidden = YES;
            backgroundImageView.hidden = YES;
            
            shuffleButton.frame = CGRectMake((self.contentView.frame.size.width - 36), 90, 18, 12);
            [shuffleButton setTitle:nil forState:UIControlStateNormal];
            [shuffleButton setBackgroundImage:[UIImage imageNamed:@"Shuffle-7"] forState:UIControlStateNormal];
            [shuffleButton setBackgroundImage:[UIImage imageNamed:@"Shuffle-7"] forState:UIControlStateHighlighted];
        }
        else {
            detailLabel1.textColor = [UIColor grayColor];
            detailLabel2.textColor = [UIColor grayColor];
            
            albumArtworkReflectionImageView.hidden = NO;
            backgroundImageView.hidden = YES;
            
            // The shuffle button width must account for the size of the title edge insets.
            NSInteger shuffleButtonWidth = ([NSLocalizedString(@"Shuffle", @"") sizeWithFont:[UIFont boldSystemFontOfSize:14]].width + 37);
            
            shuffleButton.frame = CGRectMake((self.contentView.frame.size.width - (shuffleButtonWidth + 10)), 80, shuffleButtonWidth, 25);
            [shuffleButton setTitle:NSLocalizedString(@"Shuffle", @"") forState:UIControlStateNormal];
            [shuffleButton setBackgroundImage:[[UIImage imageNamed:@"Shuffle_Button"]safeStretchableImageWithLeftCapWidth:25 topCapHeight:12] forState:UIControlStateNormal];
            [shuffleButton setBackgroundImage:[[UIImage imageNamed:@"Shuffle_Button-Selected"]safeStretchableImageWithLeftCapWidth:25 topCapHeight:12] forState:UIControlStateHighlighted];
        }
        
        if (bottomSeparatorView) {
            [bottomSeparatorView removeFromSuperview];
            bottomSeparatorView = nil;
        }
    }
    
    if ([SkinManager iOS7Skin]) {
        detailLabel1.font = [UIFont systemFontOfSize:12];
        detailLabel2.font = [UIFont systemFontOfSize:12];
    }
    else {
        detailLabel1.font = [UIFont boldSystemFontOfSize:12];
        detailLabel2.font = [UIFont boldSystemFontOfSize:12];
    }
}

- (void)setAlbumArtworkImage:(UIImage *)albumArtworkImage {
    albumArtworkImageView.image = albumArtworkImage;
    albumArtworkReflectionImageView.image = albumArtworkImage;
}

@end
