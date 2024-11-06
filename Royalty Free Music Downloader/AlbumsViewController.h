//
//  AlbumsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "AlbumsViewControllerDelegate.h"
#import "SongsViewControllerDelegate.h"
#import "SingleAlbumViewControllerDelegate.h"

@class Album;
@class Artist;

@interface AlbumsViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, SongsViewControllerDelegate, SingleAlbumViewControllerDelegate> {
@public
    id <AlbumsViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSFetchedResultsController *fetchedResultsController;
    NSFetchedResultsController *editingFetchedResultsController;
    Album *selectedAlbum;
    UILabel *albumCountLabel;
}

@property (nonatomic, unsafe_unretained) id <AlbumsViewControllerDelegate> delegate;

@end
