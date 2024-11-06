//
//  BookmarksViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Bookmark.h"
#import "BookmarkFolder.h"

@protocol BookmarksViewControllerDelegate <NSObject>

@required
- (BookmarkFolder *)bookmarksViewControllerParentBookmarkFolder;

@optional
- (void)bookmarksViewControllerDoneButtonPressed;
- (void)bookmarksViewControllerDidSelectBookmarkForURL:(NSURL *)url;

@end
