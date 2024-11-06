//
//  AdBlocker.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface AdBlocker : NSObject {
    sqlite3 *database;
}

+ (AdBlocker *)sharedAdBlocker;
- (BOOL)shouldFilterHost:(NSString *)host;

@end
