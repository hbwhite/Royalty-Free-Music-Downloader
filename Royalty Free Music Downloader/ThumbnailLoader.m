//
//  ThumbnailLoader.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/25/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "ThumbnailLoader.h"
#import "File.h"
#import "File+Extensions.h"
#import "Album+Extensions.h"
#import "Artist+Extensions.h"
#import "Playlist+Extensions.h"
#import "ArtworkCell.h"
#import "ThumbnailCache.h"
#import "FilePaths.h"
#import "SkinManager.h"

#define THUMBNAIL_LOAD_DELAY            0.2
#define MAX_TOTAL_OPERATION_COUNT       50

static ThumbnailLoader *sharedThumbnailLoader = nil;

@interface ThumbnailLoader ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation ThumbnailLoader

// Private
@synthesize operationQueue;

+ (ThumbnailLoader *)sharedThumbnailLoader {
    @synchronized(sharedThumbnailLoader) {
        if (!sharedThumbnailLoader) {
            sharedThumbnailLoader = [[ThumbnailLoader alloc]init];
        }
        return sharedThumbnailLoader;
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

- (NSOperation *)loadThumbnailForCell:(ArtworkCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView artworkContainer:(NSManagedObject *)artworkContainer {
    @autoreleasepool {
        ThumbnailCache *thumbnailCache = [ThumbnailCache sharedThumbnailCache];
        
        UIImage *cachedThumbnail = [thumbnailCache imageForKey:artworkContainer];
        if (cachedThumbnail) {
            cell.artworkImageView.image = cachedThumbnail;
            return nil;
        }
        
        cell.artworkImageView.image = [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork_Thumbnail"];
        
        if ([artworkContainer respondsToSelector:@selector(rawThumbnail)]) {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                while (operationQueue.operationCount >= MAX_TOTAL_OPERATION_COUNT) {
                    [[operationQueue.operations objectAtIndex:0]performSelectorInBackground:@selector(cancel) withObject:nil];
                }
                
                [NSThread sleepForTimeInterval:THUMBNAIL_LOAD_DELAY];
                
                if ((cell) && (indexPath) && (tableView) && (artworkContainer)) {
                    if ([[tableView indexPathsForRowsInRect:CGRectMake(0, tableView.contentOffset.y, tableView.frame.size.width, tableView.frame.size.height)]containsObject:indexPath]) {
                        dispatch_queue_t queue = dispatch_get_main_queue();
                        dispatch_async(queue, ^{
                            // The Core Data variables accessed by this function cannot be accessed in a background thread created by the operation queue without creating a separate managed object context.
                            // As a result, they are accessed on the main thread here.
                            
                            // A (File *) cast is used here because the artwork container will always be a managed object with an -rawThumbnail extension. (File *) is used as a generalization to simplify the cast.
                            UIImage *thumbnail = [(File *)artworkContainer rawThumbnail];
                            if (thumbnail) {
                                [thumbnailCache setImage:thumbnail forKey:artworkContainer];
                                cell.artworkImageView.image = thumbnail;
                            }
                        });
                    }
                }
            }];
            
            [operationQueue addOperation:operation];
            
            return operation;
        }
        
        return nil;
    }
}

@end
