//
//  MyTopRatedViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"

@class File;
@class Artist;

@interface MyTopRatedViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
@private
    NSFetchedResultsController *fetchedResultsController;
    UILabel *songCountLabel;
}

@end
