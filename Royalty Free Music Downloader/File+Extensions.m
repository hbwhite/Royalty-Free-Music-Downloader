//
//  File+Extensions.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "File+Extensions.h"
#import "FilePaths.h"
#import "Directory.h"
#import "SkinManager.h"
#import "ArtworkCache.h"
#import <MediaPlayer/MediaPlayer.h>

// Caching artwork and thumbnails at the object level would make the cache unnecessarily large due to redundancy.
// Instead, all caching is handled by the ArtworkLoader and ThumbnailLoader classes.
// #import "ThumbnailCache.h"

// EXTEREMELY IMPORTANT: File names MUST be checked to ensure they are not blank (zero characters in length).
// Example: if ((fileName) && ([fileName length] > 0)) { ... }
// If a file name is blank, the app could append its file name to the path of its parent directory and delete the resultant path.
// Because the file name is blank, the app could, in turn, delete the parent directory and all of the files within it.

@implementation File (Extensions)

- (NSURL *)fileURL {
    // NSURL will crash if nil is passed as a parameter in the following statements.
    if ([self.iPodMusicLibraryFile boolValue]) {
        if (self.url) {
            return [NSURL URLWithString:self.url];
        }
    }
    else {
        NSString *filePath = [self filePath];
        if (filePath) {
            return [NSURL fileURLWithPath:filePath];
        }
    }
    return nil;
}

- (NSString *)filePath {
    if ((self.fileName) && ([self.fileName length] > 0)) {
        if (self.parentDirectoryRef) {
            return [kMusicDirectoryPathStr stringByAppendingPathComponent:[self pathByAffixingParentDirectory:self.parentDirectoryRef toPath:self.fileName]];
        }
        return [kMusicDirectoryPathStr stringByAppendingPathComponent:self.fileName];
    }
    return nil;
}

- (MPMediaItem *)mediaItem {
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:self.persistentID forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc]initWithFilterPredicates:[NSSet setWithObject:predicate]];
    NSArray *songs = [mediaQuery items];
    if (songs) {
        if ([songs count] > 0) {
            MPMediaItem *mediaItem = [songs objectAtIndex:0];
            return mediaItem;
        }
    }
    return nil;
}

- (NSString *)pathByAffixingParentDirectory:(Directory *)parentDirectory toPath:(NSString *)path {
    NSString *affixedPath = [parentDirectory.name stringByAppendingPathComponent:path];
    if (parentDirectory.parentDirectoryRef) {
        return [self pathByAffixingParentDirectory:parentDirectory.parentDirectoryRef toPath:affixedPath];
    }
    return affixedPath;
}

- (NSInteger)standardizedTrack {
    NSInteger track = [self.track integerValue];
    if (track > 0) {
        return track;
    }
    return 1;
}

- (UIImage *)rawArtwork {
    /*
    ArtworkCache *artworkCache = [ArtworkCache sharedArtworkCache];
    UIImage *cachedArtwork = [artworkCache imageForKey:self];
    
    if (cachedArtwork) {
        return cachedArtwork;
    }
    */
    
    if ([self.iPodMusicLibraryFile boolValue]) {
        MPMediaItem *mediaItem = [self mediaItem];
        if (mediaItem) {
            MPMediaItemArtwork *mediaItemArtwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
            
            UIImage *artwork = [mediaItemArtwork imageWithSize:CGSizeMake(512, 512)];
            if (artwork) {
                // [artworkCache setImage:artwork forKey:self];
                return artwork;
            }
        }
    }
    else {
        if (self.artworkFileName) {
            UIImage *artwork = [UIImage imageWithContentsOfFile:[kArtworkDirectoryPathStr stringByAppendingPathComponent:self.artworkFileName]];
            if (artwork) {
                // [artworkCache setImage:artwork forKey:self];
                return artwork;
            }
        }
    }
    return nil;
}

- (UIImage *)rawThumbnail {
    /*
    ThumbnailCache *thumbnailCache = [ThumbnailCache sharedThumbnailCache];
    UIImage *cachedThumbnail = [thumbnailCache imageForKey:self];
    
    if (cachedThumbnail) {
        return cachedThumbnail;
    }
    */
    
    if ([self.iPodMusicLibraryFile boolValue]) {
        MPMediaItem *mediaItem = [self mediaItem];
        if (mediaItem) {
            MPMediaItemArtwork *mediaItemArtwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
            
            UIImage *thumbnail = [mediaItemArtwork imageWithSize:CGSizeMake(88, 88)];
            if (thumbnail) {
                // [thumbnailCache setImage:thumbnail forKey:self];
                return thumbnail;
            }
        }
    }
    else {
        if (self.thumbnailFileName) {
            UIImage *thumbnail = [UIImage imageWithContentsOfFile:[kThumbnailsDirectoryPathStr stringByAppendingPathComponent:self.thumbnailFileName]];
            if (thumbnail) {
                // [thumbnailCache setImage:thumbnail forKey:self];
                return thumbnail;
            }
        }
    }
    return nil;
}

- (UIImage *)artwork {
    UIImage *rawArtwork = [self rawArtwork];
    if (rawArtwork) {
        return rawArtwork;
    }
    return [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork"];
}

- (UIImage *)thumbnail {
    UIImage *rawThumbnail = [self rawThumbnail];
    if (rawThumbnail) {
        return rawThumbnail;
    }
    return [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork_Thumbnail"];
}

@end
