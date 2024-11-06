//
//  ArtworkCache.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/10/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "ArtworkCache.h"

#define CACHE_SIZE  50

static ArtworkCache *sharedArtworkCache = nil;

@interface ArtworkCache ()

@property (nonatomic, strong) NSMutableArray *cacheArray;
@property (nonatomic, strong) NSMutableDictionary *cacheDictionary;

@end

@implementation ArtworkCache

@synthesize cacheArray;
@synthesize cacheDictionary;

+ (ArtworkCache *)sharedArtworkCache {
    @synchronized(sharedArtworkCache) {
        if (!sharedArtworkCache) {
            sharedArtworkCache = [[ArtworkCache alloc]init];
        }
        return sharedArtworkCache;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        cacheArray = [[NSMutableArray alloc]init];
        cacheDictionary = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSManagedObject *)key {
    while ([cacheArray count] >= CACHE_SIZE) {
        id key = [cacheArray objectAtIndex:0];
        [cacheDictionary removeObjectForKey:key];
        [cacheArray removeObject:key];
    }
    
    NSManagedObjectID *keyID = [key objectID];
    [cacheDictionary setObject:image forKey:keyID];
    [cacheArray addObject:keyID];
}

- (void)removeImageForKey:(NSManagedObject *)key {
    NSManagedObjectID *keyID = [key objectID];
    [cacheDictionary removeObjectForKey:keyID];
    [cacheArray removeObject:keyID];
}

- (UIImage *)imageForKey:(NSManagedObject *)key {
    return [cacheDictionary objectForKey:[key objectID]];
}

@end
