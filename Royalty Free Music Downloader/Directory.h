//
//  Directory.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 7/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Directory, Download, File;

@interface Directory : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *contentDirectories;
@property (nonatomic, retain) NSSet *contentDownloads;
@property (nonatomic, retain) NSSet *contentFiles;
@property (nonatomic, retain) Directory *parentDirectoryRef;
@property (nonatomic, retain) NSSet *contentArchives;
@end

@interface Directory (CoreDataGeneratedAccessors)

- (void)addContentDirectoriesObject:(Directory *)value;
- (void)removeContentDirectoriesObject:(Directory *)value;
- (void)addContentDirectories:(NSSet *)values;
- (void)removeContentDirectories:(NSSet *)values;
- (void)addContentDownloadsObject:(Download *)value;
- (void)removeContentDownloadsObject:(Download *)value;
- (void)addContentDownloads:(NSSet *)values;
- (void)removeContentDownloads:(NSSet *)values;
- (void)addContentFilesObject:(File *)value;
- (void)removeContentFilesObject:(File *)value;
- (void)addContentFiles:(NSSet *)values;
- (void)removeContentFiles:(NSSet *)values;
- (void)addContentArchivesObject:(NSManagedObject *)value;
- (void)removeContentArchivesObject:(NSManagedObject *)value;
- (void)addContentArchives:(NSSet *)values;
- (void)removeContentArchives:(NSSet *)values;
@end
