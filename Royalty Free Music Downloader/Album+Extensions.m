//
//  Album+Extensions.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Album+Extensions.h"
#import "File.h"
#import "File+Extensions.h"
#import "ArtworkCache.h"
#import "SkinManager.h"

// Caching artwork and thumbnails at the object level would make the cache unnecessarily large due to redundancy.
// Instead, all caching is handled by the ArtworkLoader and ThumbnailLoader classes.
// #import "ThumbnailCache.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@implementation Album (Extensions)

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

- (UIImage *)coverFlowArtwork {
    UIImage *rawArtwork = [self rawArtwork];
    if (rawArtwork) {
        return rawArtwork;
    }
    return [UIImage imageNamed:@"Missing_Album_Artwork_Cover"];
}

- (NSNumber *)year {
    NSSet *files = nil;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        files = self.filesForAlbumArtistGroup;
    }
    else {
        files = self.filesForArtistGroup;
    }
    
    NSArray *filesArray = [files allObjects];
    for (int i = 0; i < [filesArray count]; i++) {
        File *file = [filesArray objectAtIndex:i];
        if (file.year) {
            return file.year;
        }
    }
    
    return nil;
}

#pragma mark Private methods

- (UIImage *)rawArtwork {
    /*
    ArtworkCache *artworkCache = [ArtworkCache sharedArtworkCache];
    UIImage *cachedArtwork = [artworkCache imageForKey:self];
    
    if (cachedArtwork) {
        return cachedArtwork;
    }
    */
    
    NSSet *files = nil;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        files = self.filesForAlbumArtistGroup;
    }
    else {
        files = self.filesForArtistGroup;
    }
    
    NSArray *filesArray = [files allObjects];
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
    NSSet *files = nil;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        files = self.filesForAlbumArtistGroup;
    }
    else {
        files = self.filesForArtistGroup;
    }
    
    NSArray *filesArray = [files allObjects];
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
