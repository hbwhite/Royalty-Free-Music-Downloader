//
//  EditBookmarkFolderViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "BookmarkFolder.h"

@protocol EditBookmarkFolderViewControllerDelegate <NSObject>

@required
- (BookmarkFolder *)editBookmarkFolderViewControllerBookmarkFolder;
- (void)editBookmarkFolderViewControllerDidChooseBookmarkFolderName:(NSString *)folderName parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder;

@optional
- (BookmarkFolder *)editBookmarkFolderViewControllerParentBookmarkFolder;

@end
