//
//  UIImage+SkinImage.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/12/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "UIImage+SkinImage.h"
#import "SkinManager.h"

static NSString *kiOS6SkinImageSuffixStr    = @"-6";
static NSString *kiOS7SkinImageSuffixStr    = @"-7";

@implementation UIImage (SkinImage)

+ (UIImage *)skinImageNamed:(NSString *)name {
    if ([SkinManager iOS6Skin]) {
        return [self imageNamed:[name stringByAppendingString:kiOS6SkinImageSuffixStr]];
    }
    else {
        return [self iOS7SkinImageNamed:name];
    }
}

+ (UIImage *)iOS6SkinImageNamed:(NSString *)name {
    // Selects either an iOS 6 skin image with the given name or the default image.
    // An iOS 6 skin image is returned for both the iOS 6 and iOS 7 skins (the iOS 6 skin is the minimum requirement).
    // iOS 7 skin images with the given name are ignored.
    
    if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
        UIImage *iOS6Image = [self imageNamed:[name stringByAppendingString:kiOS6SkinImageSuffixStr]];
        if (iOS6Image) {
            return iOS6Image;
        }
    }
    
    return [self imageNamed:name];
}

+ (UIImage *)iOS7SkinImageNamed:(NSString *)name {
    // Selects either an iOS 7 skin image with the given name or the default image.
    // iOS 6 skin images with the given name are ignored.
    
    if ([SkinManager iOS7Skin]) {
        UIImage *iOS7Image = [self imageNamed:[name stringByAppendingString:kiOS7SkinImageSuffixStr]];
        if (iOS7Image) {
            return iOS7Image;
        }
    }
    
    return [self imageNamed:name];
}

@end
