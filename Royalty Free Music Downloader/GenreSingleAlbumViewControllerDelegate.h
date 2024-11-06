//
//  GenreSingleAlbumViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@class Genre;
@class Album;

@protocol GenreSingleAlbumViewControllerDelegate <NSObject>

@required
- (Genre *)genreSingleAlbumViewControllerGenre;
- (Album *)genreSingleAlbumViewControllerAlbum;

@end
