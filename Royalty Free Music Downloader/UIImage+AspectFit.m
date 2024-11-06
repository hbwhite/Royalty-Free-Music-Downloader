//
//  UIImage+AspectFit.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 5/6/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "UIImage+AspectFit.h"

@implementation UIImage (AspectFit)

- (UIImage *)imageScaledToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageScaledToFitSize:(CGSize)size {
    CGFloat aspect = (self.size.width / self.size.height);
    if ((size.width / aspect) <= size.height) {
        return [self imageScaledToSize:CGSizeMake(size.width, (size.width / aspect))];
    }
    else {
        return [self imageScaledToSize:CGSizeMake((size.height * aspect), size.height)];
    }
}

@end
