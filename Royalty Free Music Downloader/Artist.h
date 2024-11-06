//
//  Artist.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/23/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, File, GenreArtist;

@interface Artist : NSManagedObject

@property (nonatomic, retain) NSNumber * groupByAlbumArtist;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *albums;
@property (nonatomic, retain) NSSet *filesForAlbumArtistGroup;
@property (nonatomic, retain) NSSet *filesForArtistGroup;
@property (nonatomic, retain) NSSet *genreArtists;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addAlbumsObject:(Album *)value;
- (void)removeAlbumsObject:(Album *)value;
- (void)addAlbums:(NSSet *)values;
- (void)removeAlbums:(NSSet *)values;
- (void)addFilesForAlbumArtistGroupObject:(File *)value;
- (void)removeFilesForAlbumArtistGroupObject:(File *)value;
- (void)addFilesForAlbumArtistGroup:(NSSet *)values;
- (void)removeFilesForAlbumArtistGroup:(NSSet *)values;
- (void)addFilesForArtistGroupObject:(File *)value;
- (void)removeFilesForArtistGroupObject:(File *)value;
- (void)addFilesForArtistGroup:(NSSet *)values;
- (void)removeFilesForArtistGroup:(NSSet *)values;
- (void)addGenreArtistsObject:(GenreArtist *)value;
- (void)removeGenreArtistsObject:(GenreArtist *)value;
- (void)addGenreArtists:(NSSet *)values;
- (void)removeGenreArtists:(NSSet *)values;
@end
