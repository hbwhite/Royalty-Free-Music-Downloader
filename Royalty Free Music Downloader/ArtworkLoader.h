//
//  ArtworkLoader.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/25/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class File;
@class iCarousel;
@class CoverFlowView;
@class ArtworkContainer;

@interface ArtworkLoader : NSObject {
@private
    NSOperationQueue *operationQueue;
}

+ (ArtworkLoader *)sharedArtworkLoader;
- (void)loadArtworkForCover:(CoverFlowView *)cover atIndex:(NSInteger)index inCoverFlowView:(iCarousel *)coverFlowView artworkContainer:(NSManagedObject *)artworkContainer;

@end
