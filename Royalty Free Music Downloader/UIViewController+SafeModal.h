//
//  UIViewController+SafeModal.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (SafeModal)

- (UIViewController *)safeModalViewController;
- (void)safelyPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)safelyDismissModalViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end
