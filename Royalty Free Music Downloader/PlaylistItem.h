//
//  PlaylistItem.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/28/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File, Playlist;

@interface PlaylistItem : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) File *fileRef;
@property (nonatomic, retain) Playlist *playlistRef;

@end
