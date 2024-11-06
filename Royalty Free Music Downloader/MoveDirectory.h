//
//  MoveDirectory.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/26/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Directory;

@interface MoveDirectory : NSObject {
    Directory *directoryRef;
    NSInteger tier;
    BOOL enabled;
}

@property (nonatomic, strong) Directory *directoryRef;
@property (nonatomic) NSInteger tier;
@property (readwrite) BOOL enabled;

@end
