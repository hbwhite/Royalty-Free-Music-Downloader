//
//  Playlist+Extensions.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/10/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Playlist+Extensions.h"
#import "PlaylistItem.h"
#import "File.h"
#import "File+Extensions.h"
#import "ArtworkCache.h"
#import "SkinManager.h"

// Caching artwork and thumbnails at the object level would make the cache unnecessarily large due to redundancy.
// Instead, all caching is handled by the ArtworkLoader and ThumbnailLoader classes.
// #import "ThumbnailCache.h"

@implementation Playlist (Extensions)

- (UIImage *)artwork {
    UIImage *rawArtwork = [self rawArtwork];
    if (rawArtwork) {
        return rawArtwork;
    }
    return [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork"];
}

- (UIImage *)thumbnail {
    /*
    ThumbnailCache *thumbnailCache = [ThumbnailCache sharedThumbnailCache];
    UIImage *cachedArtwork = [thumbnailCache imageForKey:self];
    
    if (cachedArtwork) {
        return cachedArtwork;
    }
    */
    
    UIImage *rawThumbnail = [self rawThumbnail];
    if (rawThumbnail) {
        return rawThumbnail;
    }
    return [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork_Thumbnail"];
}

- (UIImage *)rawArtwork {
    /*
    ArtworkCache *artworkCache = [ArtworkCache sharedArtworkCache];
    UIImage *cachedArtwork = [artworkCache imageForKey:self];
    
    if (cachedArtwork) {
        return cachedArtwork;
    }
    */
    
    NSMutableArray *filesArray = [NSMutableArray arrayWithObjects:nil];
    
    for (PlaylistItem *playlistItem in self.playlistItems) {
        [filesArray addObject:playlistItem.fileRef];
    }
    
    for (int i = 0; i < [filesArray count]; i++) {
        File *file = [filesArray objectAtIndex:i];
        UIImage *rawArtwork = [file rawArtwork];
        if (rawArtwork) {
            // [artworkCache setImage:rawArtwork forKey:self];
            return rawArtwork;
        }
    }
    return nil;
}

- (UIImage *)rawThumbnail {
    NSMutableArray *filesArray = [NSMutableArray arrayWithObjects:nil];
    
    for (PlaylistItem *playlistItem in self.playlistItems) {
        [filesArray addObject:playlistItem.fileRef];
    }
    
    for (int i = 0; i < [filesArray count]; i++) {
        File *file = [filesArray objectAtIndex:i];
        UIImage *rawThumbnail = [file rawThumbnail];
        if (rawThumbnail) {
            // [thumbnailCache setImage:rawThumbnail forKey:self];
            return rawThumbnail;
        }
    }
    return nil;
}

@end
