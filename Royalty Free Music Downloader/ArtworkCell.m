//
//  ArtworkCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "ArtworkCell.h"
#import "SkinManager.h"

@interface ArtworkCell ()

@property (nonatomic, strong) UIView *artworkBottomSeparatorView;

@end

@implementation ArtworkCell

// Public
@synthesize artworkImageView;
@synthesize nowPlayingImageView;
@synthesize artworkOperation;

// Private
@synthesize artworkBottomSeparatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // The container image view prevents empty space in the album artwork from being highlighted blue when the cell is selected.
        UIImageView *artworkContainerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 43, 43)];
        artworkContainerImageView.image = [UIImage imageNamed:@"Backdrop"];
        
        artworkImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 43, 43)];
        artworkImageView.contentMode = UIViewContentModeScaleAspectFit;
        [artworkContainerImageView addSubview:artworkImageView];
        
        [self.contentView addSubview:artworkContainerImageView];
        
        nowPlayingImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.contentView.frame.size.width - 22), 0, 22, 43)];
        nowPlayingImageView.backgroundColor = [UIColor clearColor];
        nowPlayingImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        nowPlayingImageView.contentMode = UIViewContentModeCenter;
        nowPlayingImageView.hidden = YES;
        nowPlayingImageView.image = [UIImage iOS7SkinImageNamed:@"Playing"];
        nowPlayingImageView.highlightedImage = [SkinManager iOS7Skin] ? nowPlayingImageView.image : [UIImage imageNamed:@"Playing-Selected"];
        [self.contentView addSubview:nowPlayingImageView];
    }
    return self;
}

- (void)configure {
    [super configure];
    
    // This prevents duplicate separator views from being added to the cell, leaving vestigial separators that are unaccounted for.
    
    if ([SkinManager iOS6Skin]) {
        if (!artworkBottomSeparatorView) {
            artworkBottomSeparatorView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (self.frame.size.height - 1), self.frame.size.width, 1)];
            artworkBottomSeparatorView.image = [UIImage imageNamed:@"Separator-6"];
            artworkBottomSeparatorView.backgroundColor = [SkinManager iOS6SkinSeparatorColor];
            artworkBottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:artworkBottomSeparatorView];
        }
    }
    else {
        if (artworkBottomSeparatorView) {
            [artworkBottomSeparatorView removeFromSuperview];
            artworkBottomSeparatorView = nil;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    artworkImageView.frame = CGRectMake(0, 0, 44, 44);
    
    CGRect textLabelFrame = self.textLabel.frame;
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    
    NSInteger originalRightContentOffset = (self.contentView.frame.size.width - (self.textLabel.frame.origin.x + self.textLabel.frame.size.width));
    
    // The text label is automatically shortened according to the length of the text.
    // This system works because if the latter of these two values is smaller than the former, then the text label is likely too short for the truncation (using the latter value) to be seen.
    NSInteger rightContentOffset = MIN(originalRightContentOffset, 10);
    if (!nowPlayingImageView.hidden) {
        rightContentOffset += 22;
        nowPlayingImageView.frame = CGRectMake((self.contentView.frame.size.width - rightContentOffset), 0, 22, 44);
    }
    
    textLabelFrame.size.width = (self.contentView.frame.size.width - (50 + rightContentOffset));
    textLabelFrame.origin.x = 50;
    
    detailTextLabelFrame.size.width = (self.contentView.frame.size.width - (50 + rightContentOffset));
    detailTextLabelFrame.origin.x = 50;
    
    self.textLabel.frame = textLabelFrame;
    self.detailTextLabel.frame = detailTextLabelFrame;
}

@end
