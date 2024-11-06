//
//  UITableView+SafeReload.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (SafeReload)

- (void)safelyReloadData;
- (void)safelyReloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)safelyReloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

@end
