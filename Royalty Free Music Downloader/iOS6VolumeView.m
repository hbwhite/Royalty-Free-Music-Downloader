//
//  iOS6VolumeView.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/7/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "iOS6VolumeView.h"

@implementation iOS6VolumeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)volumeThumbRectForBounds:(CGRect)bounds volumeSliderRect:(CGRect)rect value:(float)value {
    exit(0);
    CGRect originalBounds = [super volumeThumbRectForBounds:bounds volumeSliderRect:rect value:value];
    return CGRectMake(originalBounds.origin.x, (originalBounds.origin.y - 20), originalBounds.size.width, originalBounds.size.height);
}

@end
