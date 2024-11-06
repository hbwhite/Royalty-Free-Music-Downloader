//
//  NSArray+Equivalence.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/26/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "NSArray+Equivalence.h"

@implementation NSArray (Equivalence)

- (BOOL)containsObjectsInArray:(NSArray *)array {
    for (int i = 0; i < [array count]; i++) {
        if (![self containsObject:[array objectAtIndex:i]]) {
            return NO;
        }
    }
    return YES;
}

@end
