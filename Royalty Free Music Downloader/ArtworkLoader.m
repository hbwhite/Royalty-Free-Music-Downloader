//
//  ArtworkLoader.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/25/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "ArtworkLoader.h"
#import "File.h"
#import "File+Extensions.h"
#import "Album+Extensions.h"
#import "Artist+Extensions.h"
#import "Playlist+Extensions.h"
#import "ArtworkCache.h"
#import "iCarousel.h"
#import "CoverFlowView.h"
#import "FilePaths.h"

#define ARTWORK_LOAD_DELAY              0.2
#define MAX_TOTAL_OPERATION_COUNT       50

static ArtworkLoader *sharedArtworkLoader = nil;

@interface ArtworkLoader ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation ArtworkLoader

// Private
@synthesize operationQueue;

+ (ArtworkLoader *)sharedArtworkLoader {
    @synchronized(sharedArtworkLoader) {
        if (!sharedArtworkLoader) {
            sharedArtworkLoader = [[ArtworkLoader alloc]init];
        }
        return sharedArtworkLoader;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc]init];
        operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return self;
}

- (void)loadArtworkForCover:(CoverFlowView *)cover atIndex:(NSInteger)index inCoverFlowView:(iCarousel *)coverFlowView artworkContainer:(NSManagedObject *)artworkContainer {
    @autoreleasepool {
        ArtworkCache *artworkCache = [ArtworkCache sharedArtworkCache];
        
        UIImage *cachedArtwork = [artworkCache imageForKey:artworkContainer];
        if (cachedArtwork) {
            cover.image = cachedArtwork;
            return;
        }
        
        cover.image = [UIImage imageNamed:@"Missing_Album_Artwork_Cover"];
        
        if ([artworkContainer respondsToSelector:@selector(rawArtwork)]) {
            [operationQueue addOperationWithBlock:^{
                while (operationQueue.operationCount >= MAX_TOTAL_OPERATION_COUNT) {
                    [[operationQueue.operations objectAtIndex:0]performSelectorInBackground:@selector(cancel) withObject:nil];
                }
                
                [NSThread sleepForTimeInterval:ARTWORK_LOAD_DELAY];
                
                if ((cover) && (coverFlowView)) {
                    if ([[coverFlowView visibleItemViews]containsObject:cover]) {
                        dispatch_queue_t queue = dispatch_get_main_queue();
                        dispatch_async(queue, ^{
                            // The Core Data variables accessed by this function cannot be accessed in a background thread created by the operation queue without creating a separate managed object context.
                            // As a result, they are accessed on the main thread here.
                            
                            // A (File *) cast is used here because the artwork container will always be a managed object with an -rawArtwork extension. (File *) is used as a generalization to simplify the cast.
                            UIImage *artwork = [(File *)artworkContainer rawArtwork];
                            if (artwork) {
                                [artworkCache setImage:artwork forKey:artworkContainer];
                                cover.image = artwork;
                            }
                        });
                    }
                }
            }];
        }
    }
}

@end
