//
//  GenreSingleAlbumViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "GenreSingleAlbumViewControllerDelegate.h"

@class Genre;
@class Album;

@interface GenreSingleAlbumViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
@public
    id <GenreSingleAlbumViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSFetchedResultsController *fetchedResultsController;
    NSFetchedResultsController *editingFetchedResultsController;
}

@property (nonatomic, unsafe_unretained) id <GenreSingleAlbumViewControllerDelegate> delegate;

@end
