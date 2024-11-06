//
//  SingleAlbumSongCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SingleAlbumSongCell.h"
#import "SkinManager.h"

@interface SingleAlbumSongCell ()

@property (nonatomic, strong) UIView *topSeparatorView;
@property (nonatomic, strong) UIView *bottomSeparatorView;
@property (nonatomic, strong) UIView *leftTitleSeparatorView1;
@property (nonatomic, strong) UIView *leftTitleSeparatorView2;
@property (nonatomic, strong) UIView *rightTitleSeparatorView;

@end

@implementation SingleAlbumSongCell

// Public
@synthesize fullBackgroundView;
@synthesize trackNumberLabel;
@synthesize titleLabel;
@synthesize nowPlayingImageView;
@synthesize durationLabel;
@synthesize checkmarkOverlayView;

// Private
@synthesize topSeparatorView;
@synthesize bottomSeparatorView;
@synthesize leftTitleSeparatorView1;
@synthesize leftTitleSeparatorView2;
@synthesize rightTitleSeparatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        fullBackgroundView = [[UIView alloc]initWithFrame:self.frame];
        fullBackgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self insertSubview:fullBackgroundView atIndex:0];
        
        trackNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 38, 43)];
        trackNumberLabel.backgroundColor = [UIColor clearColor];
        trackNumberLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:trackNumberLabel];
        
        titleLabel = [[UILabel alloc]init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:titleLabel];
        
        nowPlayingImageView = [[UIImageView alloc]init];
        nowPlayingImageView.backgroundColor = [UIColor clearColor];
        nowPlayingImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        nowPlayingImageView.contentMode = UIViewContentModeCenter;
        nowPlayingImageView.hidden = YES;
        nowPlayingImageView.image = [UIImage iOS7SkinImageNamed:@"Playing"];
        nowPlayingImageView.highlightedImage = [SkinManager iOS7Skin] ? nowPlayingImageView.image : [UIImage imageNamed:@"Playing-Selected"];
        [self.contentView addSubview:nowPlayingImageView];
        
        durationLabel = [[UILabel alloc]init];
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        // This is the maximum font size to display a duration with a single hours digit.
        durationLabel.minimumFontSize = 11;
        durationLabel.adjustsFontSizeToFitWidth = YES;
        
        durationLabel.textColor = [UIColor colorWithWhite:(109.0 / 255.0) alpha:1];
        
        [self.contentView addSubview:durationLabel];
        
        checkmarkOverlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 43)];
        checkmarkOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        checkmarkOverlayView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        checkmarkOverlayView.hidden = YES;
        
        UIImageView *checkmarkOverlayImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 38, 43)];
        checkmarkOverlayImageView.contentMode = UIViewContentModeCenter;
        
        if ([SkinManager iOS7Skin]) {
            checkmarkOverlayImageView.image = [UIImage imageNamed:@"Checkmark-7"];
            checkmarkOverlayImageView.highlightedImage = checkmarkOverlayImageView.image;
        }
        else {
            checkmarkOverlayImageView.image = [UIImage imageNamed:@"Checkmark"];
            checkmarkOverlayImageView.highlightedImage = [UIImage imageNamed:@"Checkmark-Selected"];
        }
        
        [checkmarkOverlayView addSubview:checkmarkOverlayImageView];
        
        [self addSubview:checkmarkOverlayView];
    }
    return self;
}

- (void)configure {
    // This prevents duplicate separator views from being added to the cell, leaving vestigial separators that are unaccounted for.
    
    if ([SkinManager iOS6Skin]) {
        if (!topSeparatorView) {
            topSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
            topSeparatorView.backgroundColor = [UIColor whiteColor];
            topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:topSeparatorView];
        }
        
        if (!bottomSeparatorView) {
            bottomSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, (self.frame.size.height - 1), self.frame.size.width, 1)];
            bottomSeparatorView.backgroundColor = [SkinManager iOS6SkinSeparatorColor];
            bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:bottomSeparatorView];
        }
        
        if (!leftTitleSeparatorView1) {
            leftTitleSeparatorView1 = [[UIView alloc]initWithFrame:CGRectMake(38, 0, 1, 43)];
            leftTitleSeparatorView1.backgroundColor = [UIColor whiteColor];
            leftTitleSeparatorView1.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            [self.contentView addSubview:leftTitleSeparatorView1];
        }
        
        if (!leftTitleSeparatorView2) {
            leftTitleSeparatorView2 = [[UIView alloc]initWithFrame:CGRectMake(39, 0, 1, 43)];
            leftTitleSeparatorView2.backgroundColor = [SkinManager iOS6SkinSeparatorColor];
            leftTitleSeparatorView2.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            [self.contentView addSubview:leftTitleSeparatorView2];
        }
        
        if (rightTitleSeparatorView) {
            [rightTitleSeparatorView removeFromSuperview];
            rightTitleSeparatorView = nil;
        }
        
        trackNumberLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        nowPlayingImageView.frame = CGRectMake((self.contentView.frame.size.width - 45), 0, 22, 43);
        
        durationLabel.font = [UIFont systemFontOfSize:13];
        durationLabel.textAlignment = UITextAlignmentLeft;
        
        trackNumberLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        trackNumberLabel.shadowColor = [UIColor whiteColor];
        trackNumberLabel.shadowOffset = CGSizeMake(0, 1);
        
        durationLabel.textColor = trackNumberLabel.textColor;
        durationLabel.shadowColor = trackNumberLabel.shadowColor;
        durationLabel.shadowOffset = trackNumberLabel.shadowOffset;
    }
    else {
        if ([SkinManager iOS7Skin]) {
            trackNumberLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.font = [UIFont boldSystemFontOfSize:15];
            durationLabel.font = [UIFont systemFontOfSize:15];
            
            durationLabel.frame = CGRectMake((self.contentView.frame.size.width - 58), 0, 40, 43);
            durationLabel.textColor = [UIColor blackColor];
            
            nowPlayingImageView.frame = CGRectMake((self.contentView.frame.size.width - 81), 0, 22, 43);
            
            if (leftTitleSeparatorView1) {
                [leftTitleSeparatorView1 removeFromSuperview];
                leftTitleSeparatorView1 = nil;
            }
            
            if (rightTitleSeparatorView) {
                [rightTitleSeparatorView removeFromSuperview];
                rightTitleSeparatorView = nil;
            }
        }
        else {
            trackNumberLabel.font = [UIFont boldSystemFontOfSize:15];
            titleLabel.font = [UIFont boldSystemFontOfSize:15];
            durationLabel.font = [UIFont boldSystemFontOfSize:15];
            
            durationLabel.frame = CGRectMake((self.contentView.frame.size.width - 44), 0, 40, 43);
            durationLabel.textColor = [UIColor grayColor];
            
            nowPlayingImageView.frame = CGRectMake((self.contentView.frame.size.width - 67), 0, 22, 43);
            
            if (!leftTitleSeparatorView1) {
                leftTitleSeparatorView1 = [[UIView alloc]initWithFrame:CGRectMake(38, 0, 1, 43)];
                leftTitleSeparatorView1.backgroundColor = [UIColor colorWithWhite:(217.0 / 255.0) alpha:1];
                leftTitleSeparatorView1.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
                [self.contentView addSubview:leftTitleSeparatorView1];
            }
            
            if (!rightTitleSeparatorView) {
                rightTitleSeparatorView = [[UIView alloc]initWithFrame:CGRectMake((self.contentView.frame.size.width - 45), 0, 1, 43)];
                rightTitleSeparatorView.backgroundColor = [UIColor colorWithWhite:(217.0 / 255.0) alpha:1];
                rightTitleSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [self.contentView addSubview:rightTitleSeparatorView];
            }
        }
        
        if (leftTitleSeparatorView2) {
            [leftTitleSeparatorView2 removeFromSuperview];
            leftTitleSeparatorView2 = nil;
        }
        
        if (topSeparatorView) {
            [topSeparatorView removeFromSuperview];
            topSeparatorView = nil;
        }
        if (bottomSeparatorView) {
            [bottomSeparatorView removeFromSuperview];
            bottomSeparatorView = nil;
        }
        
        durationLabel.textAlignment = UITextAlignmentRight;
        
        trackNumberLabel.textColor = [UIColor blackColor];
        trackNumberLabel.shadowColor = nil;
        trackNumberLabel.shadowOffset = CGSizeMake(0, -1);
        
        durationLabel.shadowColor = nil;
        durationLabel.shadowOffset = CGSizeMake(0, -1);
    }
    
    titleLabel.textColor = trackNumberLabel.textColor;
    titleLabel.shadowColor = trackNumberLabel.shadowColor;
    titleLabel.shadowOffset = trackNumberLabel.shadowOffset;
    
    if ([SkinManager iOS7Skin]) {
        trackNumberLabel.highlightedTextColor = trackNumberLabel.textColor;
        titleLabel.highlightedTextColor = titleLabel.textColor;
        durationLabel.highlightedTextColor = durationLabel.textColor;
    }
    else {
        trackNumberLabel.highlightedTextColor = [UIColor whiteColor];
        titleLabel.highlightedTextColor = [UIColor whiteColor];
        durationLabel.highlightedTextColor = [UIColor whiteColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([SkinManager iOS6Skin]) {
        if (nowPlayingImageView.hidden) {
            titleLabel.frame = CGRectMake(50, 5, (self.contentView.frame.size.width - 60), 17);
            durationLabel.frame = CGRectMake(50, 22, (self.contentView.frame.size.width - 60), 17);
        }
        else {
            titleLabel.frame = CGRectMake(50, 5, (self.contentView.frame.size.width - 95), 17);
            durationLabel.frame = CGRectMake(50, 22, (self.contentView.frame.size.width - 95), 17);
        }
    }
    else {
        if ([SkinManager iOS7]) {
            if (nowPlayingImageView.hidden) {
                titleLabel.frame = CGRectMake(50, 0, (self.contentView.frame.size.width - 109), 43);
            }
            else {
                titleLabel.frame = CGRectMake(50, 0, (self.contentView.frame.size.width - 131), 43);
            }
        }
        else {
            if (nowPlayingImageView.hidden) {
                titleLabel.frame = CGRectMake(50, 0, (self.contentView.frame.size.width - 95), 43);
            }
            else {
                titleLabel.frame = CGRectMake(50, 0, (self.contentView.frame.size.width - 117), 43);
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animate {
    if ([SkinManager iOS6Skin]) {
        if (highlighted) {
            trackNumberLabel.shadowColor = [UIColor clearColor];
        }
        else {
            trackNumberLabel.shadowColor = [UIColor whiteColor];
        }
        
        titleLabel.shadowColor = trackNumberLabel.shadowColor;
        durationLabel.shadowColor = trackNumberLabel.shadowColor;
    }
    [super setHighlighted:highlighted animated:animate];
}

@end
