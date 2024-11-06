//
//  UITableView+Extensions.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "UITableView+SafeReload.h"

// These extensions fix a bug that can occur when a text field within a UITableViewCell refuses to resign as the first responder when the cell is reloaded.

@implementation UITableView (SafeReload)

- (void)safelyReloadData {
    for (int i = 0; i < [self numberOfSections]; i++) {
        for (int j = 0; j < [self numberOfRowsInSection:i]; j++) {
            [[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]]endEditing:YES];
        }
    }
    
    [self reloadData];
}

- (void)safelyReloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    for (NSIndexPath *indexPath in indexPaths) {
        [[self cellForRowAtIndexPath:indexPath]endEditing:YES];
    }
    
    [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)safelyReloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    for (int i = [sections firstIndex]; i != NSNotFound; i = [sections indexGreaterThanIndex:i]) {
        for (int j = 0; j < [self numberOfRowsInSection:i]; j++) {
            [[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]]endEditing:YES];
        }
    }
    
    [self reloadSections:sections withRowAnimation:animation];
}

@end
