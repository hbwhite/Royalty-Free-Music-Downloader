//
//  SearchControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/28/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@protocol SearchControllerDelegate <NSObject>

@required
- (UISearchBar *)searchControllerSearchBar;
- (UITableView *)searchControllerTableView;
- (UINavigationController *)searchControllerNavigationController;

@end
