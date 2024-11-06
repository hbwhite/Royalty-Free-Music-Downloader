//
//  SingleAlbumSelectAllCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SingleAlbumSelectAllCell.h"
#import "SkinManager.h"

@interface SingleAlbumSelectAllCell ()

@property (nonatomic, strong) UIView *topSeparatorView;
@property (nonatomic, strong) UIView *bottomSeparatorView;
@property (nonatomic, strong) UIView *leftTitleSeparatorView1;
@property (nonatomic, strong) UIView *leftTitleSeparatorView2;
@property (nonatomic, strong) UIView *rightTitleSeparatorView;

@end

@implementation SingleAlbumSelectAllCell

// Public
@synthesize fullBackgroundView;
@synthesize titleLabel;

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
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, (self.contentView.frame.size.width - 95), 43)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:titleLabel];
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
        
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        
        fullBackgroundView.backgroundColor = [SkinManager iOS6SkinTableViewSectionHeaderShadowColor];
    }
    else {
        if ([SkinManager iOS7Skin]) {
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
        
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.shadowColor = nil;
        titleLabel.shadowOffset = CGSizeMake(0, -1);
        
        fullBackgroundView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animate {
    if ([SkinManager iOS6Skin]) {
        if (highlighted) {
            titleLabel.shadowColor = [UIColor clearColor];
        }
        else {
            titleLabel.shadowColor = [UIColor whiteColor];
        }
    }
    [super setHighlighted:highlighted animated:animate];
}

@end
