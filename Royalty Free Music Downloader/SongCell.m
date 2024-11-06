//
//  SongCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SongCell.h"
#import "SkinManager.h"

@implementation SongCell

@synthesize nowPlayingImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        nowPlayingImageView = [[UIImageView alloc]init];
        nowPlayingImageView.backgroundColor = [UIColor clearColor];
        nowPlayingImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        nowPlayingImageView.contentMode = UIViewContentModeCenter;
        nowPlayingImageView.hidden = YES;
        [self.contentView addSubview:nowPlayingImageView];
    }
    return self;
}

- (void)configure {
    [super configure];
    
    nowPlayingImageView.image = [UIImage iOS7SkinImageNamed:@"Playing"];
    nowPlayingImageView.highlightedImage = [SkinManager iOS7Skin] ? nowPlayingImageView.image : [UIImage imageNamed:@"Playing-Selected"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect textLabelFrame = self.textLabel.frame;
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    
    NSInteger originalRightContentOffset = (self.contentView.frame.size.width - (self.textLabel.frame.origin.x + self.textLabel.frame.size.width));
    
    NSInteger leftContentOffset = textLabelFrame.origin.x;
    if (self.imageView.image) {
        leftContentOffset = 50;
    }
    
    // The text label is automatically shortened according to the length of the text.
    // This system works because if the latter of these two values is smaller than the former, then the text label is likely too short for the truncation (using the latter value) to be seen.
    NSInteger rightContentOffset = MIN(originalRightContentOffset, 10);
    if (!nowPlayingImageView.hidden) {
        rightContentOffset += 22;
        nowPlayingImageView.frame = CGRectMake((self.contentView.frame.size.width - rightContentOffset), 0, 22, 44);
    }
    
    textLabelFrame.size.width = (self.contentView.frame.size.width - (leftContentOffset + rightContentOffset));
    textLabelFrame.origin.x = leftContentOffset;
    
    detailTextLabelFrame.size.width = (self.contentView.frame.size.width - (leftContentOffset + rightContentOffset));
    detailTextLabelFrame.origin.x = leftContentOffset;
    
    self.textLabel.frame = textLabelFrame;
    self.detailTextLabel.frame = detailTextLabelFrame;
}

@end
