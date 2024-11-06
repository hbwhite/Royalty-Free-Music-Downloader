//
//  MoreTableViewDataSource.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/13/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoreTableViewDataSource : NSObject <UITableViewDataSource> {
@private
    id <UITableViewDataSource> _originalDataSource;
    UITableView *_tableView;
}

- (id)initWithOriginalDataSource:(id <UITableViewDataSource>)originalDataSource tableView:(UITableView *)tableView;

@end
