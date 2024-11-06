//
//  ArtistsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "SingleAlbumViewControllerDelegate.h"
#import "AlbumsViewControllerDelegate.h"
#import "MultipleTagEditorNavigationControllerDelegate.h"

@class Album;
@class Artist;

@interface ArtistsViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, SingleAlbumViewControllerDelegate, AlbumsViewControllerDelegate, MultipleTagEditorNavigationControllerDelegate> {
@private
    NSFetchedResultsController *fetchedResultsController;
    NSFetchedResultsController *editingFetchedResultsController;
    UILabel *artistCountLabel;
    Album *selectedAlbum;
    Artist *selectedArtist;
}

@end
