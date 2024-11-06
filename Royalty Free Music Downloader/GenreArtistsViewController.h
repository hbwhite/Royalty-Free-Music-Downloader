//
//  GenreArtistsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "GenreSingleAlbumViewControllerDelegate.h"
#import "GenreAlbumsViewControllerDelegate.h"
#import "GenreArtistsViewControllerDelegate.h"
#import "MultipleTagEditorNavigationControllerDelegate.h"

@class Genre;
@class GenreArtist;
@class Album;

@interface GenreArtistsViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, GenreSingleAlbumViewControllerDelegate, GenreAlbumsViewControllerDelegate, MultipleTagEditorNavigationControllerDelegate> {
@public
    id <GenreArtistsViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSFetchedResultsController *fetchedResultsController;
    NSFetchedResultsController *editingFetchedResultsController;
    UILabel *artistCountLabel;
    Album *selectedAlbum;
    GenreArtist *selectedGenreArtist;
}

@property (nonatomic, unsafe_unretained) id <GenreArtistsViewControllerDelegate> delegate;

@end
