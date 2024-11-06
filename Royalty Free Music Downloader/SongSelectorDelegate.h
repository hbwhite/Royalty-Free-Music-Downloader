//
//  SongSelectorDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/26/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Modes.h"

@class File;
@class Playlist;

@protocol SongSelectorDelegate <NSObject>

@required
- (kMode)songSelectorMode;

@optional
// kModeAddToPlaylist
- (Playlist *)songSelectorPlaylist;
- (NSArray *)songSelectorSelectedFiles;
- (void)songSelectorDidSelectFile:(File *)selectedFile;
- (void)songSelectorDidSelectFiles:(NSArray *)selectedFiles;
- (void)songSelectorDidFinishSelectingFiles;

@end
