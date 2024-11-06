//
//  Download+Path.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Download+Path.h"
#import "Directory.h"
#import "FilePaths.h"

@implementation Download (Path)

- (NSString *)temporaryDownloadFilePath {
    if (self.parentDirectoryRef) {
        return [kTemporaryDownloadDirectoryPathStr stringByAppendingPathComponent:[self pathByAffixingParentDirectory:self.parentDirectoryRef toPath:self.temporaryDownloadFileName]];
    }
    return [kTemporaryDownloadDirectoryPathStr stringByAppendingPathComponent:self.temporaryDownloadFileName];
}

- (NSString *)downloadDestinationFilePath {
    if (self.parentDirectoryRef) {
        return [kTemporaryDownloadDirectoryPathStr stringByAppendingPathComponent:[self pathByAffixingParentDirectory:self.parentDirectoryRef toPath:self.downloadDestinationFileName]];
    }
    return [kTemporaryDownloadDirectoryPathStr stringByAppendingPathComponent:self.downloadDestinationFileName];
}

- (NSString *)pathByAffixingParentDirectory:(Directory *)parentDirectory toPath:(NSString *)path {
    NSString *affixedPath = [parentDirectory.name stringByAppendingPathComponent:path];
    if (parentDirectory.parentDirectoryRef) {
        return [self pathByAffixingParentDirectory:parentDirectory.parentDirectoryRef toPath:affixedPath];
    }
    return affixedPath;
}

@end
