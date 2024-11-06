//
//  UILocalizedIndexedCollation+StandardizedSectionIndexTitles.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 5/13/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "UILocalizedIndexedCollation+StandardizedSectionIndexTitles.h"

static NSString *kPoundSignStr  = @"#";

@implementation UILocalizedIndexedCollation (StandardizedSectionIndexTitles)

- (NSArray *)standardizedSectionIndexTitles {
    NSMutableArray *sectionIndexTitles = [NSMutableArray arrayWithArray:[self sectionIndexTitles]];
    
    if ([sectionIndexTitles containsObject:kPoundSignStr]) {
        [sectionIndexTitles removeObject:kPoundSignStr];
    }
    [sectionIndexTitles insertObject:kPoundSignStr atIndex:0];
    
    return sectionIndexTitles;
}

@end
