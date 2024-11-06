//
//  PlaylistsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "TextInputNavigationControllerDelegate.h"
#import "AddToPlaylistViewController.h"
#import "PlaylistsDetailViewController.h"

@class Playlist;

enum {
    kRowIdentifierNone = 0,
    kRowIdentifierTop25MostPlayed,
    kRowIdentifierMyTopRated,
    kRowIdentifierRecentlyPlayed,
    kRowIdentifierRecentlyAdded
};
typedef NSUInteger kRowIdentifier;

@interface PlaylistsViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, TextInputNavigationControllerDelegate, AddToPlaylistViewControllerDelegate, PlaylistsDetailViewControllerDelegate> {
@private
    NSFetchedResultsController *fetchedResultsController;
    Playlist *selectedPlaylist;
    BOOL addingPlaylist;
    
    kRowIdentifier row1ID;
    kRowIdentifier row2ID;
    kRowIdentifier row3ID;
    kRowIdentifier row4ID;
}


@end
