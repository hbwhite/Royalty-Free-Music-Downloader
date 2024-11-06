//
//  UINavigationItem+SafeAnimation.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "UINavigationItem+SafeAnimation.h"

@implementation UINavigationItem (SafeAnimation)

- (void)safelySetLeftBarButtonItemAnimated:(UIBarButtonItem *)newLeftBarButtonItem {
    // Available in iOS 5.0 or later.
    if ([self respondsToSelector:@selector(setLeftBarButtonItem:animated:)]) {
        [self setLeftBarButtonItem:newLeftBarButtonItem animated:YES];
    }
    else {
        [self setLeftBarButtonItem:newLeftBarButtonItem];
    }
}

- (void)safelySetRightBarButtonItemAnimated:(UIBarButtonItem *)newRightBarButtonItem {
    // Available in iOS 5.0 or later.
    if ([self respondsToSelector:@selector(setRightBarButtonItem:animated:)]) {
        [self setRightBarButtonItem:newRightBarButtonItem animated:YES];
    }
    else {
        [self setRightBarButtonItem:newRightBarButtonItem];
    }
}

@end
