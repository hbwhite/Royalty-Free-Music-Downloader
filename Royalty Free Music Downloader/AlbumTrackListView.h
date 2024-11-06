//
//  AlbumTrackListView.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/6/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumTrackListViewDelegate.h"

@class Album;

@interface AlbumTrackListView : UIView <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
@public
    id <AlbumTrackListViewDelegate> __unsafe_unretained delegate;
    UITableView *theTableView;
    NSFetchedResultsController *fetchedResultsController;
@private
    BOOL settingCurrentFile;
}

@property (nonatomic, unsafe_unretained) id <AlbumTrackListViewDelegate> delegate;
@property (nonatomic, strong) UITableView *theTableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)updateTracks;
- (void)nowPlayingFileDidChange;

@end
