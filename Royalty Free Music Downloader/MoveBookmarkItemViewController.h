//
//  MoveBookmarkItemViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveBookmarkItemViewControllerDelegate.h"

@class MoveBookmarkFolder;

@interface MoveBookmarkItemViewController : UITableViewController {
@public
    id <MoveBookmarkItemViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSMutableArray *bookmarkFolders;
    MoveBookmarkFolder *selectedBookmarkFolder;
}

@property (nonatomic, unsafe_unretained) id <MoveBookmarkItemViewControllerDelegate> delegate;

@end
