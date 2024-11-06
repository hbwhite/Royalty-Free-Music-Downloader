//
//  GenreAlbumsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "GenreSongsViewController.h"
#import "GenreSingleAlbumViewController.h"
#import "GenreAlbumsViewControllerDelegate.h"

@class Genre;
@class GenreAlbum;
@class GenreArtist;

@interface GenreAlbumsViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, GenreSongsViewControllerDelegate, GenreSingleAlbumViewControllerDelegate> {
@public
    id <GenreAlbumsViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSFetchedResultsController *fetchedResultsController;
    NSFetchedResultsController *editingFetchedResultsController;
    UILabel *albumCountLabel;
    GenreAlbum *selectedGenreAlbum;
}

@property (nonatomic, unsafe_unretained) id <GenreAlbumsViewControllerDelegate> delegate;

@end
