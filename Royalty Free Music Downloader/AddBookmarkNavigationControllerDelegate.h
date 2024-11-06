//
//  AddBookmarkNavigationControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "BookmarkFolder.h"

@protocol AddBookmarkNavigationControllerDelegate <NSObject>

@optional
- (void)addBookmarkNavigationControllerDidCancel;
- (void)addBookmarkNavigationControllerDidChooseBookmarkName:(NSString *)bookmarkName url:(NSString *)url parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder;

@required
- (NSString *)addBookmarkNavigationControllerBookmarkName;
- (NSString *)addBookmarkNavigationControllerBookmarkURL;

@end
