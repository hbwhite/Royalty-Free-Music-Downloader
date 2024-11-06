//
//  SongsViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@class Artist;

@protocol SongsViewControllerDelegate <NSObject>

@optional
- (Artist *)songsViewControllerArtist;

@end
