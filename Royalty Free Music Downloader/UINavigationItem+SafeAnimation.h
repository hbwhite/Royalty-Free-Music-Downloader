//
//  UINavigationItem+SafeAnimation.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (SafeAnimation)

- (void)safelySetLeftBarButtonItemAnimated:(UIBarButtonItem *)newLeftBarButtonItem;
- (void)safelySetRightBarButtonItemAnimated:(UIBarButtonItem *)newRightBarButtonItem;

@end
