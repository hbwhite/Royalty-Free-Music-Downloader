//
//  EditBookmarkViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditBookmarkViewControllerDelegate.h"
#import "MoveBookmarkItemViewControllerDelegate.h"

@class BookmarkFolder;

@interface EditBookmarkViewController : UITableViewController <UITextFieldDelegate, MoveBookmarkItemViewControllerDelegate> {
@public
    id <EditBookmarkViewControllerDelegate> __unsafe_unretained delegate;
@private
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *saveButton;
    NSString *bookmarkName;
    NSString *bookmarkURL;
    BookmarkFolder *parentBookmarkFolder;
    BOOL didSave;
    BOOL didPushViewController;
    BOOL didCancel;
}

@property (nonatomic, unsafe_unretained) id <EditBookmarkViewControllerDelegate> delegate;

@end
