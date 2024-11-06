//
//  FilesViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/29/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@class Directory;

@protocol FilesViewControllerDelegate <NSObject>

@required
- (Directory *)filesViewControllerParentDirectory;

@end
