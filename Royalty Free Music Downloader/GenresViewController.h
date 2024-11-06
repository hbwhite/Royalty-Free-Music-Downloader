//
//  GenresViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "GenreArtistsViewControllerDelegate.h"
#import "MultipleTagEditorNavigationControllerDelegate.h"

@class Genre;

@interface GenresViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, GenreArtistsViewControllerDelegate, MultipleTagEditorNavigationControllerDelegate> {
@private
    NSFetchedResultsController *fetchedResultsController;
    NSFetchedResultsController *editingFetchedResultsController;
    UILabel *genreCountLabel;
    Genre *selectedGenre;
}

@end
