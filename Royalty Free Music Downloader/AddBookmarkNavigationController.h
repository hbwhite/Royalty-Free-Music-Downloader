//
//  AddBookmarkNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBookmarkNavigationControllerDelegate.h"
#import "EditBookmarkViewControllerDelegate.h"

@class EditBookmarkViewController;

@interface AddBookmarkNavigationController : UINavigationController <EditBookmarkViewControllerDelegate> {
@public
    id <AddBookmarkNavigationControllerDelegate> __unsafe_unretained addBookmarkNavigationControllerDelegate;
@private
    EditBookmarkViewController *editBookmarkViewController;
}

@property (nonatomic, unsafe_unretained) id <AddBookmarkNavigationControllerDelegate> addBookmarkNavigationControllerDelegate;

@end
