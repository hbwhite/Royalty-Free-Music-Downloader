//
//  BookmarkItem.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookmark, BookmarkFolder;

@interface BookmarkItem : NSManagedObject

@property (nonatomic, retain) NSNumber * bookmark;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) BookmarkFolder *parentBookmarkFolderRef;
@property (nonatomic, retain) Bookmark *bookmarkRef;
@property (nonatomic, retain) BookmarkFolder *bookmarkFolderRef;

@end
