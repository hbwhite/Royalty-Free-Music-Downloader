//
//  EditBookmarkFolderViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditBookmarkFolderViewControllerDelegate.h"
#import "MoveBookmarkItemViewControllerDelegate.h"

@class BookmarkFolder;

@interface EditBookmarkFolderViewController : UITableViewController <UITextFieldDelegate, MoveBookmarkItemViewControllerDelegate> {
@public
    id <EditBookmarkFolderViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSString *bookmarkFolderName;
    BookmarkFolder *parentBookmarkFolder;
    BOOL didSave;
    BOOL didPushViewController;
}

@property (nonatomic, unsafe_unretained) id <EditBookmarkFolderViewControllerDelegate> delegate;

@end
