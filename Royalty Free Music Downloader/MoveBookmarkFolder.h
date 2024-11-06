//
//  MoveBookmarkFolder.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/26/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BookmarkFolder;

@interface MoveBookmarkFolder : NSObject {
    BookmarkFolder *bookmarkFolderRef;
    NSInteger tier;
}

@property (nonatomic, strong) BookmarkFolder *bookmarkFolderRef;
@property (nonatomic) NSInteger tier;

@end
