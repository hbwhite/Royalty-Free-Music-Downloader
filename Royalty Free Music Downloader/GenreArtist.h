//
//  GenreArtist.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/20/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, File, Genre;

@interface GenreArtist : NSManagedObject

@property (nonatomic, retain) NSNumber * groupByAlbumArtist;
@property (nonatomic, retain) Artist *artist;
@property (nonatomic, retain) NSSet *filesForAlbumArtistGroup;
@property (nonatomic, retain) NSSet *filesForArtistGroup;
@property (nonatomic, retain) Genre *genre;
@end

@interface GenreArtist (CoreDataGeneratedAccessors)

- (void)addFilesForAlbumArtistGroupObject:(File *)value;
- (void)removeFilesForAlbumArtistGroupObject:(File *)value;
- (void)addFilesForAlbumArtistGroup:(NSSet *)values;
- (void)removeFilesForAlbumArtistGroup:(NSSet *)values;
- (void)addFilesForArtistGroupObject:(File *)value;
- (void)removeFilesForArtistGroupObject:(File *)value;
- (void)addFilesForArtistGroup:(NSSet *)values;
- (void)removeFilesForArtistGroup:(NSSet *)values;
@end
