//
//  GenreSongsViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@class Genre;
@class GenreArtist;

@protocol GenreSongsViewControllerDelegate <NSObject>

@required
- (Genre *)genreSongsViewControllerGenre;

@optional
- (GenreArtist *)genreSongsViewControllerGenreArtist;

@end
