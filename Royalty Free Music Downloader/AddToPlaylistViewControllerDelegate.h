//
//  AddToPlaylistViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@class Playlist;

@protocol AddToPlaylistViewControllerDelegate <NSObject>

@required
- (Playlist *)addToPlaylistViewControllerPlaylist;

@optional
- (void)addToPlaylistViewControllerDidSelectFiles:(NSArray *)files;

@end
