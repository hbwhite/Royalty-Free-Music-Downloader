//
//  FilePaths.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#define kDataStorageFoundationDirectoryPathStr  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"com.harrisonapps.freemusicdownloader"]
#define kDataStorageDirectoryPathStr            [kDataStorageFoundationDirectoryPathStr stringByAppendingPathComponent:@"Data"]
#define kTemporaryDownloadDirectoryPathStr      [kDataStorageFoundationDirectoryPathStr stringByAppendingPathComponent:@"Downloads"]
#define kArtworkDirectoryPathStr                [kDataStorageFoundationDirectoryPathStr stringByAppendingPathComponent:@"Artwork"]
#define kThumbnailsDirectoryPathStr             [kDataStorageFoundationDirectoryPathStr stringByAppendingPathComponent:@"Thumbnails"]
#define kMusicDirectoryPathStr                  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
