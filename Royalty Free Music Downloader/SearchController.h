//
//  SearchController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/23/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongSelectorDelegate.h"
#import "SearchControllerDelegate.h"
#import "SingleAlbumViewControllerDelegate.h"
#import "AlbumsViewControllerDelegate.h"
#import "SongsViewControllerDelegate.h"
#import "PlaylistsDetailViewControllerDelegate.h"
#import "MultipleTagEditorNavigationControllerDelegate.h"

@class VisibilityViewController;
@class Artist;
@class Album;
@class Playlist;

@interface SearchController : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, AlbumsViewControllerDelegate, SingleAlbumViewControllerDelegate, PlaylistsDetailViewControllerDelegate, SongsViewControllerDelegate, MultipleTagEditorNavigationControllerDelegate> {
@public
    VisibilityViewController <SearchControllerDelegate> __unsafe_unretained *delegate;
    id <SongSelectorDelegate> __unsafe_unretained songSelectorDelegate;
@private
    NSFetchedResultsController *artistsFetchedResultsController;
    NSFetchedResultsController *albumsFetchedResultsController;
    NSFetchedResultsController *songsFetchedResultsController;
    NSFetchedResultsController *playlistsFetchedResultsController;
    NSFetchedResultsController *artistsEditingFetchedResultsController;
    NSFetchedResultsController *albumsEditingFetchedResultsController;
    NSFetchedResultsController *songsEditingFetchedResultsController;
    Artist *selectedArtist;
    Album *selectedAlbum;
    Playlist *selectedPlaylist;
}

@property (nonatomic, unsafe_unretained) VisibilityViewController <SearchControllerDelegate> *delegate;
@property (nonatomic, unsafe_unretained) id <SongSelectorDelegate> songSelectorDelegate;

- (void)updateSections;
- (void)didFinishSearching;

@end
