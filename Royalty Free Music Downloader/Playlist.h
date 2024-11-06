//
//  Playlist.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 7/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PlaylistItem;

@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *playlistItems;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addPlaylistItemsObject:(PlaylistItem *)value;
- (void)removePlaylistItemsObject:(PlaylistItem *)value;
- (void)addPlaylistItems:(NSSet *)values;
- (void)removePlaylistItems:(NSSet *)values;
@end
