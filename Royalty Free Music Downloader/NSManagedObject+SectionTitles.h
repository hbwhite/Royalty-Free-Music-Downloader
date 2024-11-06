//
//  NSManagedObject+SectionTitles.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (SectionTitles)

- (NSString *)fileSectionTitle;
- (NSString *)albumSectionTitle;
- (NSString *)artistSectionTitle;
- (NSString *)playlistSectionTitle;
- (NSString *)genreSectionTitle;
- (NSString *)genreArtistSectionTitle;
- (NSString *)genreAlbumSectionTitle;

@end
