//
//  PlaylistsDetailViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "AddToPlaylistViewController.h"
#import "PlaylistsDetailViewControllerDelegate.h"

@interface PlaylistsDetailViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, AddToPlaylistViewControllerDelegate> {
@public
    id <PlaylistsDetailViewControllerDelegate> __unsafe_unretained delegate;
@private
    UIBarButtonItem *addButton;
    UISearchBar *searchBar;
    NSFetchedResultsController *fetchedResultsController;
    UILabel *songCountLabel;
}

@property (nonatomic, unsafe_unretained) id <PlaylistsDetailViewControllerDelegate> delegate;

@end
