//
//  BookmarksViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarksViewControllerDelegate.h"
#import "EditBookmarkViewControllerDelegate.h"
#import "EditBookmarkFolderViewControllerDelegate.h"

@class BookmarkItem;

@interface BookmarksViewController : UITableViewController <NSFetchedResultsControllerDelegate, BookmarksViewControllerDelegate, EditBookmarkViewControllerDelegate, EditBookmarkFolderViewControllerDelegate> {
@public
    id <BookmarksViewControllerDelegate> __unsafe_unretained delegate;
@private
    UIBarButtonItem *doneButton;
    UIBarButtonItem *editButton;
    UIBarButtonItem *editDoneButton;
    UIBarButtonItem *flexibleSpaceBarButtonItem;
    UIBarButtonItem *createNewFolderButton;
    NSFetchedResultsController *fetchedResultsController;
    BookmarkItem *selectedBookmarkItem;
}

@property (nonatomic, unsafe_unretained) id <BookmarksViewControllerDelegate> delegate;

@end
