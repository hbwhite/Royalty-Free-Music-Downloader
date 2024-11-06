//
//  UIImage+SafeStretchableImage.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/12/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SafeStretchableImage)

- (UIImage *)safeStretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end
