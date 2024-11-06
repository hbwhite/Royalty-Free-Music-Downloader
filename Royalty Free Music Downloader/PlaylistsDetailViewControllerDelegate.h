//
//  PlaylistsDetailViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@class Playlist;

@protocol PlaylistsDetailViewControllerDelegate <NSObject>

@required
- (Playlist *)playlistsDetailViewControllerPlaylist;

@end
