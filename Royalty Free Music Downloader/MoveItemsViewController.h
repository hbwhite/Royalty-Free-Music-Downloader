//
//  MoveItemsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveItemsViewControllerDelegate.h"

@class MoveDirectory;

@interface MoveItemsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
@public
    id <MoveItemsViewControllerDelegate> __unsafe_unretained delegate;
    NSMutableArray *directories;
    NSMutableArray *items;
@private
    MoveDirectory *selectedDirectory;
}

@property (nonatomic, unsafe_unretained) id <MoveItemsViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *directories;
@property (nonatomic, strong) NSMutableArray *items;

@end
