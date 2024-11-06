//
//  NSManagedObject+SectionTitles.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "NSManagedObject+SectionTitles.h"

static NSString *kArtistKey = @"artist";
static NSString *kAlbumKey  = @"album";

@implementation NSManagedObject (SectionTitles)

- (NSString *)fileSectionTitle {
    UILocalizedIndexedCollation *localizedIndexedCollation = [UILocalizedIndexedCollation currentCollation];
    NSInteger index = [localizedIndexedCollation sectionForObject:self collationStringSelector:@selector(title)];
    NSString *sectionTitle = [[localizedIndexedCollation sectionTitles]objectAtIndex:index];
    return sectionTitle;
}

- (NSString *)albumSectionTitle {
    return [self sectionTitleForNameKey];
}

- (NSString *)artistSectionTitle {
    return [self sectionTitleForNameKey];
}

- (NSString *)playlistSectionTitle {
    return [self sectionTitleForNameKey];
}

- (NSString *)genreSectionTitle {
    return [self sectionTitleForNameKey];
}

- (NSString *)genreArtistSectionTitle {
    [self willAccessValueForKey:kArtistKey];
    
    NSString *genreArtistSectionTitle = [[self valueForKey:kArtistKey]artistSectionTitle];
    
    [self didAccessValueForKey:kArtistKey];
    
    return genreArtistSectionTitle;
}

- (NSString *)genreAlbumSectionTitle {
    [self willAccessValueForKey:kAlbumKey];
    
    NSString *genreAlbumSectionTitle = [[self valueForKey:kAlbumKey]albumSectionTitle];
    
    [self didAccessValueForKey:kAlbumKey];
    
    return genreAlbumSectionTitle;
}

#pragma mark Private methods

- (NSString *)sectionTitleForNameKey {
    UILocalizedIndexedCollation *localizedIndexedCollation = [UILocalizedIndexedCollation currentCollation];
    NSInteger index = [localizedIndexedCollation sectionForObject:self collationStringSelector:@selector(name)];
    NSString *sectionTitle = [[localizedIndexedCollation sectionTitles]objectAtIndex:index];
    return sectionTitle;
}

@end
