//
//  EditBookmarkViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "BookmarkFolder.h"

enum {
    kEditBookmarkViewControllerModeAddBookmark = 0,
    kEditBookmarkViewControllerModeEditBookmark
};
typedef NSUInteger kEditBookmarkViewControllerMode;

@protocol EditBookmarkViewControllerDelegate <NSObject>

@required
- (kEditBookmarkViewControllerMode)editBookmarkViewControllerMode;
- (NSString *)editBookmarkViewControllerBookmarkName;
- (NSString *)editBookmarkViewControllerBookmarkURL;

@optional
- (BookmarkFolder *)editBookmarkViewControllerParentBookmarkFolder;
- (void)editBookmarkViewControllerDidCancel;
- (void)editBookmarkViewControllerDidChooseBookmarkName:(NSString *)bookmarkName url:(NSString *)url parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder;

@end
