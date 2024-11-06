//
//  AdBlocker.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "AdBlocker.h"

static AdBlocker *sharedAdBlocker   = nil;

@implementation AdBlocker

+ (AdBlocker *)sharedAdBlocker {
    @synchronized(sharedAdBlocker) {
        if (!sharedAdBlocker) {
            sharedAdBlocker = [[AdBlocker alloc]init];
        }
        return sharedAdBlocker;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *databasePath = [[NSBundle mainBundle]pathForResource:@"adblock" ofType:@"sqlite"];
        
        if (sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
        
        /*
        NSString *query = @"SELECT id, host FROM blacklist ORDER BY id";
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int uniqueId = sqlite3_column_int(statement, 0);
                char *host = (char *)sqlite3_column_text(statement, 1);
                NSString *hostString = [[NSString alloc]initWithUTF8String:host];
                NSLog(@"id = %i, host = %@", uniqueId, hostString);
            }
            sqlite3_finalize(statement);
        }
        */
    }
    return self;
}

- (BOOL)shouldFilterHost:(NSString *)host {
    BOOL shouldFilterHost = NO;
    
    // Hosts are searched by exact match in order of increasing complexity, preventing false positives when generalizing to legitimate parent domains.
    // For example, using a wildcard may filter all subdomains of google.com just because adservices.google.com is in the blacklist.
    // Using this system, an exact match is searched for "google.com", followed by "adservices.google.com", eliminating the use of wildcards.
    // Similarly, a domain such as "subdomain.of.adservices.google.com" would be searched by "google.com" -> "adservices.google.com" -> "of.adservices.google.com" -> "subdomain.of.adservices.google.com"
    // The blacklist includes specific subdomains, such as "adservices.google.com" (as opposed to "google.com"), so this is a valid process.
    
    // NSLog(@"[internal] searching all hosts matching %@", host);
    
    NSString *query = [NSString stringWithFormat:@"SELECT id, host FROM blacklist WHERE host = '%@'", host];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            /*
            int uniqueId = sqlite3_column_int(statement, 0);
            char *host = (char *)sqlite3_column_text(statement, 1);
            NSString *hostString = [[NSString alloc]initWithUTF8String:host];
            NSLog(@"[internal] *** FOUND id = %i, host = %@", uniqueId, hostString);
            */
            
            shouldFilterHost = YES;
            break;
        }
        sqlite3_finalize(statement);
    }
    
    // NSLog(@"[internal] should filter host? %@", shouldFilterHost ? @"Yes" : @"No");
    
    return shouldFilterHost;
}

- (void)dealloc {
    sqlite3_close(database);
}

@end
