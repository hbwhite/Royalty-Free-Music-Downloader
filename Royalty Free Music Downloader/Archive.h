//
//  Archive.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 7/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Directory;

@interface Archive : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * bytes;
@property (nonatomic, retain) Directory *parentDirectoryRef;

@end
