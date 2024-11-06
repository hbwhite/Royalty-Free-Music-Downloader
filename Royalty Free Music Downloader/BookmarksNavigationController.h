//
//  BookmarksNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarksNavigationControllerDelegate.h"
#import "BookmarksViewControllerDelegate.h"

@class BookmarksViewController;

@interface BookmarksNavigationController : UINavigationController <BookmarksViewControllerDelegate> {
@public
    id <BookmarksNavigationControllerDelegate> __unsafe_unretained bookmarksNavigationControllerDelegate;
@private
    BookmarksViewController *bookmarksViewController;
}

@property (nonatomic, unsafe_unretained) id <BookmarksNavigationControllerDelegate> bookmarksNavigationControllerDelegate;

@end
