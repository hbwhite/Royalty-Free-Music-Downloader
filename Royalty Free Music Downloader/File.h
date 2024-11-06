//
//  File.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 7/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, Artist, Directory, Genre, GenreAlbum, GenreArtist, PlaylistItem;

@interface File : NSManagedObject

@property (nonatomic, retain) NSString * albumArtistName;
@property (nonatomic, retain) NSString * albumName;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSString * artworkFileName;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSNumber * iPodMusicLibraryFile;
@property (nonatomic, retain) NSDate * lastPlayedDate;
@property (nonatomic, retain) NSString * lyrics;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSNumber * playCount;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * thumbnailFileName;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * track;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * bytes;
@property (nonatomic, retain) NSNumber * bitRate;
@property (nonatomic, retain) NSString * uppercaseExtension;
@property (nonatomic, retain) Album *albumRefForAlbumArtistGroup;
@property (nonatomic, retain) Album *albumRefForArtistGroup;
@property (nonatomic, retain) Artist *artistRefForAlbumArtistGroup;
@property (nonatomic, retain) Artist *artistRefForArtistGroup;
@property (nonatomic, retain) GenreAlbum *genreAlbumRefForAlbumArtistGroup;
@property (nonatomic, retain) GenreAlbum *genreAlbumRefForArtistGroup;
@property (nonatomic, retain) GenreArtist *genreArtistRefForAlbumArtistGroup;
@property (nonatomic, retain) GenreArtist *genreArtistRefForArtistGroup;
@property (nonatomic, retain) Genre *genreRef;
@property (nonatomic, retain) Directory *parentDirectoryRef;
@property (nonatomic, retain) NSSet *playlistItemRefs;
@end

@interface File (CoreDataGeneratedAccessors)

- (void)addPlaylistItemRefsObject:(PlaylistItem *)value;
- (void)removePlaylistItemRefsObject:(PlaylistItem *)value;
- (void)addPlaylistItemRefs:(NSSet *)values;
- (void)removePlaylistItemRefs:(NSSet *)values;
@end
