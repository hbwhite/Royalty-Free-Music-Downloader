//
//  NSArray+Shuffle.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 4/12/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "NSArray+Shuffle.h"

@implementation NSArray (Shuffle)

- (NSArray *)shuffledArrayWithFirstObject:(id)firstObject {
    // If there are duplicate items in the array, using -removeObject:... will remove the duplicates.
    // Because playlists can contain duplicate items, the following implementation must be used instead to ensure that they remain intact.
    NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray:self];
    NSIndexSet *indexes = [shuffledArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqual:firstObject];
    }];
    if ([indexes count] > 0) {
        [shuffledArray removeObjectAtIndex:[indexes firstIndex]];
    }
    
    NSUInteger count = [shuffledArray count];
    for (int i = 0; i < count; i++) {
        NSInteger remainingElementCount = (count - i);
        NSInteger exchangeIndex = (arc4random() % remainingElementCount) + i;
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    return [[NSArray arrayWithObject:firstObject]arrayByAddingObjectsFromArray:shuffledArray];
}

@end
