//
//  LegacyScrollViewDelegate.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 7/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "LegacyScrollViewDelegate.h"

@implementation LegacyScrollViewDelegate

@synthesize originalDelegate;
@synthesize replacedDelegate;

// Because the scroll view delegate is overridden on devices running iOS 4.3, these methods must be forwarded to enable zooming.

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
            [originalDelegate scrollViewWillBeginDragging:scrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
            [originalDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
            [originalDelegate scrollViewWillBeginDecelerating:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
            [originalDelegate scrollViewDidEndDecelerating:scrollView];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
            [originalDelegate scrollViewDidEndScrollingAnimation:scrollView];
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
            [originalDelegate scrollViewDidZoom:scrollView];
        }
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
            [originalDelegate scrollViewWillBeginZooming:scrollView withView:view];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
            return [originalDelegate viewForZoomingInScrollView:scrollView];
        }
    }
    return nil;
}

// These are the only methods that need to be forwarded to the BrowserViewController.

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
            [originalDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
        }
    }
    
    if (replacedDelegate) {
        if ([replacedDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
            [replacedDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (originalDelegate) {
        if ([originalDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [originalDelegate scrollViewDidScroll:scrollView];
        }
    }
    
    if (replacedDelegate) {
        if ([replacedDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [replacedDelegate scrollViewDidScroll:scrollView];
        }
    }
}

@end
