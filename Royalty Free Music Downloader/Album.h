//
//  Album.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/23/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, File, GenreAlbum;

@interface Album : NSManagedObject

@property (nonatomic, retain) NSNumber * groupByAlbumArtist;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Artist *artist;
@property (nonatomic, retain) NSSet *filesForAlbumArtistGroup;
@property (nonatomic, retain) NSSet *filesForArtistGroup;
@property (nonatomic, retain) NSSet *genreAlbums;
@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addFilesForAlbumArtistGroupObject:(File *)value;
- (void)removeFilesForAlbumArtistGroupObject:(File *)value;
- (void)addFilesForAlbumArtistGroup:(NSSet *)values;
- (void)removeFilesForAlbumArtistGroup:(NSSet *)values;
- (void)addFilesForArtistGroupObject:(File *)value;
- (void)removeFilesForArtistGroupObject:(File *)value;
- (void)addFilesForArtistGroup:(NSSet *)values;
- (void)removeFilesForArtistGroup:(NSSet *)values;
- (void)addGenreAlbumsObject:(GenreAlbum *)value;
- (void)removeGenreAlbumsObject:(GenreAlbum *)value;
- (void)addGenreAlbums:(NSSet *)values;
- (void)removeGenreAlbums:(NSSet *)values;
@end
