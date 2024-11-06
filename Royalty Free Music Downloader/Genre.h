//
//  Genre.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/20/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File, GenreAlbum, GenreArtist;

@interface Genre : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *files;
@property (nonatomic, retain) NSSet *genreAlbums;
@property (nonatomic, retain) NSSet *genreArtists;
@end

@interface Genre (CoreDataGeneratedAccessors)

- (void)addFilesObject:(File *)value;
- (void)removeFilesObject:(File *)value;
- (void)addFiles:(NSSet *)values;
- (void)removeFiles:(NSSet *)values;
- (void)addGenreAlbumsObject:(GenreAlbum *)value;
- (void)removeGenreAlbumsObject:(GenreAlbum *)value;
- (void)addGenreAlbums:(NSSet *)values;
- (void)removeGenreAlbums:(NSSet *)values;
- (void)addGenreArtistsObject:(GenreArtist *)value;
- (void)removeGenreArtistsObject:(GenreArtist *)value;
- (void)addGenreArtists:(NSSet *)values;
- (void)removeGenreArtists:(NSSet *)values;
@end
