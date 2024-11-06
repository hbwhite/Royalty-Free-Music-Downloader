//
//  BookmarkFolder.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/22/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BookmarkItem;

@interface BookmarkFolder : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) BookmarkItem *bookmarkItemRef;
@property (nonatomic, retain) NSSet *contentBookmarkItemRefs;
@end

@interface BookmarkFolder (CoreDataGeneratedAccessors)

- (void)addContentBookmarkItemRefsObject:(BookmarkItem *)value;
- (void)removeContentBookmarkItemRefsObject:(BookmarkItem *)value;
- (void)addContentBookmarkItemRefs:(NSSet *)values;
- (void)removeContentBookmarkItemRefs:(NSSet *)values;
@end
