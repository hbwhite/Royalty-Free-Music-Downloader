//
//  Page.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Page : NSManagedObject

@property (nonatomic, retain) NSString * currentTitle;
@property (nonatomic, retain) NSString * currentURL;
@property (nonatomic, retain) NSNumber * pageIndex;
@property (nonatomic, retain) NSString * previewFileName;
@property (nonatomic, retain) NSNumber * urlIndex;
@property (nonatomic, retain) NSData * urls;

@end
