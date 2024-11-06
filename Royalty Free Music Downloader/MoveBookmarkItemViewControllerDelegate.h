//
//  MoveBookmarkItemViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/23/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "BookmarkItem.h"
#import "BookmarkFolder.h"

@protocol MoveBookmarkItemViewControllerDelegate <NSObject>

@required
- (BookmarkFolder *)moveBookmarkItemViewControllerParentBookmarkFolder;

@optional
- (BookmarkFolder *)moveBookmarkItemViewControllerBookmarkFolder;
- (void)moveBookmarkItemViewControllerDidSelectBookmarkFolder:(BookmarkFolder *)bookmarkFolder;

@end
