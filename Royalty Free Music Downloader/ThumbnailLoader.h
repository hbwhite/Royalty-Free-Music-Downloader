//
//  ThumbnailLoader.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/25/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class File;
@class ArtworkCell;
@class ArtworkContainer;

@interface ThumbnailLoader : NSObject {
@private
    NSOperationQueue *operationQueue;
}

+ (ThumbnailLoader *)sharedThumbnailLoader;
- (NSOperation *)loadThumbnailForCell:(ArtworkCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView artworkContainer:(NSManagedObject *)artworkContainer;

@end
