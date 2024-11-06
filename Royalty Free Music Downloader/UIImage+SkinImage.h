//
//  UIImage+SkinImage.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/12/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SkinImage)

+ (UIImage *)skinImageNamed:(NSString *)name;
+ (UIImage *)iOS6SkinImageNamed:(NSString *)name;
+ (UIImage *)iOS7SkinImageNamed:(NSString *)name;

@end
