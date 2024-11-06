//
//  UIImage+SafeStretchableImage.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/12/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "UIImage+SafeStretchableImage.h"

@implementation UIImage (SafeStretchableImage)

- (UIImage *)safeStretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
    if ([self respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        return [self resizableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, ((self.size.height - topCapHeight) - 1), ((self.size.width - leftCapWidth) - 1)) resizingMode:UIImageResizingModeStretch];
    }
    else {
        return [self stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    }
}

@end
