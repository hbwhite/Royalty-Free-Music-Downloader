//
//  File+Extensions.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "File.h"
#import <MediaPlayer/MediaPlayer.h>

@interface File (Extensions)

- (NSURL *)fileURL;
- (NSString *)filePath;
- (MPMediaItem *)mediaItem;
- (NSInteger)standardizedTrack;

- (UIImage *)rawArtwork;
- (UIImage *)rawThumbnail;

- (UIImage *)artwork;
- (UIImage *)thumbnail;

@end
