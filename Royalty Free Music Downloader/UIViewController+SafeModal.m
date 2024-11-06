//
//  UIViewController+SafeModal.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "UIViewController+SafeModal.h"

@implementation UIViewController (SafeModal)

- (UIViewController *)safeModalViewController {
    // Use iOS 5's new modal view controller functions when possible.
    if ([self respondsToSelector:@selector(presentedViewController)]) {
        return [self presentedViewController];
    }
    else {
        return [self modalViewController];
    }
}

- (void)safelyPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated completion:(void (^)(void))completion {
    // Use iOS 5's new modal view controller functions when possible.
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:modalViewController animated:animated completion:completion];
    }
    else {
        [self presentModalViewController:modalViewController animated:animated];
        if (completion) {
            completion();
        }
    }
}

- (void)safelyDismissModalViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    // Use iOS 5's new modal view controller functions when possible.
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:animated completion:completion];
    }
    else {
        [self dismissModalViewControllerAnimated:animated];
        if (completion) {
            completion();
        }
    }
}

@end
