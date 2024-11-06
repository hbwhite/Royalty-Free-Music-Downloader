//
//  AutoresizingViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoresizingViewController : UIViewController {
@private
    // This is necessary to use self.tableView in VisibilityViewController subclasses, which is necessary because the default UITableViewDataSource and UITableViewDelegate methods give the table view variable the name "tableView" as well.
    UITableView *_tableView;
}

@property (nonatomic, strong) UITableView *tableView;

@end
