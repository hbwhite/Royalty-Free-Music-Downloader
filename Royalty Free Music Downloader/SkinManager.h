//
//  SkinManager.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/8/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+SkinImage.h"

#define kSkinDidChangeNotification  @"Skin Did Change"

@interface SkinManager : NSObject {
    
}

+ (NSInteger)skinIndex;
+ (BOOL)iOS6Skin;
+ (BOOL)iOS7;
+ (BOOL)iOS7Skin;

// Default Skin
+ (UIColor *)defaultSkinTableViewSectionFooterTextColor;
+ (UIColor *)defaultSkinSearchBarPlaceholderTextColor;

// iOS 6 Skin
+ (UIColor *)iOS6SkinDarkGrayColor;
+ (UIColor *)iOS6SkinLightGrayColor;
+ (UIColor *)iOS6SkinLightTextColor;
+ (UIColor *)iOS6SkinTableViewBackgroundColor;
+ (UIColor *)iOS6SkinTableViewSectionHeaderTextColor;
+ (UIColor *)iOS6SkinTableViewSectionHeaderShadowColor;
+ (UIColor *)iOS6SkinTableViewSectionIndexTrackingBackgroundColor;
+ (UIColor *)iOS6SkinNowPlayingTextShadowColor;
+ (UIColor *)iOS6SkinSeparatorColor;

// iOS 7 Skin
+ (UIColor *)iOS7SkinBlueColor;
+ (UIColor *)iOS7SkinHighlightedBlueColor;
+ (UIColor *)iOS7SkinTableViewSectionFooterTextColor;
+ (UIColor *)iOS7SkinSearchBarPlaceholderTextColor;
+ (UIColor *)iOS7SkinTableViewBackgroundColor;

+ (void)applySkinIfApplicable;
+ (void)applySkinWithIndex:(NSInteger)index;

@end
