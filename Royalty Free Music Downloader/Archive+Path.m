//
//  Archive+Path.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Archive+Path.h"
#import "Directory.h"
#import "FilePaths.h"

// EXTEREMELY IMPORTANT: File names MUST be checked to ensure they are not blank (zero characters in length).
// Example: if ((fileName) && ([fileName length] > 0)) { ... }
// If a file name is blank, the app could append its file name to the path of its parent directory and delete the resultant path.
// Because the file name is blank, the app could, in turn, delete the parent directory and all of the files within it.

@implementation Archive (Path)

- (NSString *)path {
    if ((self.fileName) && ([self.fileName length] > 0)) {
        if (self.parentDirectoryRef) {
            return [kMusicDirectoryPathStr stringByAppendingPathComponent:[self pathByAffixingParentDirectory:self.parentDirectoryRef toPath:self.fileName]];
        }
        return [kMusicDirectoryPathStr stringByAppendingPathComponent:self.fileName];
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

@end
