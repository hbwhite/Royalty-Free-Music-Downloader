//
//  ArtworkCache.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/10/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArtworkCache : NSObject {
@private
    NSMutableArray *cacheArray;
    NSMutableDictionary *cacheDictionary;
}

+ (ArtworkCache *)sharedArtworkCache;
- (void)setImage:(UIImage *)image forKey:(NSManagedObject *)key;
- (void)removeImageForKey:(NSManagedObject *)key;
- (UIImage *)imageForKey:(NSManagedObject *)key;

@end
