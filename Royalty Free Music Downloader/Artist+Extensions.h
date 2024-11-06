//
//  Artist+Extensions.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/10/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Artist.h"

@interface Artist (Extensions)

- (UIImage *)artwork;
- (UIImage *)thumbnail;

- (UIImage *)rawArtwork;
- (UIImage *)rawThumbnail;

@end
