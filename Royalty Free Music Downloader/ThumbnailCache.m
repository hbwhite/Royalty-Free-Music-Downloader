//
//  ThumbnailCache.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/10/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "ThumbnailCache.h"

#define CACHE_SIZE  50

static ThumbnailCache *sharedThumbnailCache = nil;

@interface ThumbnailCache ()

@property (nonatomic, strong) NSMutableArray *cacheArray;
@property (nonatomic, strong) NSMutableDictionary *cacheDictionary;

@end

@implementation ThumbnailCache

@synthesize cacheArray;
@synthesize cacheDictionary;

+ (ThumbnailCache *)sharedThumbnailCache {
    @synchronized(sharedThumbnailCache) {
        if (!sharedThumbnailCache) {
            sharedThumbnailCache = [[ThumbnailCache alloc]init];
        }
        return sharedThumbnailCache;
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
