//
//  Download+Path.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Download.h"

@interface Download (Path)

- (NSString *)temporaryDownloadFilePath;
- (NSString *)downloadDestinationFilePath;

@end
