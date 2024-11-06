//
//  Download.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 7/11/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Directory;

@interface Download : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * downloadDestinationFileName;
@property (nonatomic, retain) NSString * downloadURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * temporaryDownloadFileName;
@property (nonatomic, retain) NSString * originalFileName;
@property (nonatomic, retain) Directory *parentDirectoryRef;

@end
