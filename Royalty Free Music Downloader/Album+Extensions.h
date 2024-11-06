//
//  Album+Extensions.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Album.h"

@interface Album (Extensions)

- (UIImage *)artwork;
- (UIImage *)thumbnail;
- (UIImage *)coverFlowArtwork;
- (NSNumber *)year;

- (UIImage *)rawArtwork;
- (UIImage *)rawThumbnail;

@end
