//
//  BrowserState.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/27/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BrowserState : NSManagedObject

@property (nonatomic, retain) NSNumber * currentPageIndex;
@property (nonatomic, retain) NSData * history;

@end
