//
//  CheckmarkOverlayCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "CheckmarkOverlayCell.h"
#import "SkinManager.h"

@implementation CheckmarkOverlayCell

@synthesize checkmarkOverlayView;
@synthesize checkmarkOverlayImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        checkmarkOverlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        checkmarkOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        checkmarkOverlayView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        checkmarkOverlayView.hidden = YES;
        
        checkmarkOverlayImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
        checkmarkOverlayImageView.contentMode = UIViewContentModeCenter;
        [checkmarkOverlayView addSubview:checkmarkOverlayImageView];
        
        [self addSubview:checkmarkOverlayView];
    }
    return self;
}

- (void)configure {
    [super configure];
    
    if ([SkinManager iOS7Skin]) {
        checkmarkOverlayImageView.image = [UIImage imageNamed:@"Checkmark-7"];
        checkmarkOverlayImageView.highlightedImage = checkmarkOverlayImageView.image;
    }
    else {
        checkmarkOverlayImageView.image = [UIImage imageNamed:@"Checkmark"];
        checkmarkOverlayImageView.highlightedImage = [UIImage imageNamed:@"Checkmark-Selected"];
    }
}

@end
