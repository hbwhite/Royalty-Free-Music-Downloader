//
//  SongsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisibilityViewController.h"
#import "SongsViewControllerDelegate.h"

@class File;
@class Artist;

@interface SongsViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
@public
    id <SongsViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSFetchedResultsController *fetchedResultsController;
    NSFetchedResultsController *editingFetchedResultsController;
    UILabel *songCountLabel;
}

@property (nonatomic, unsafe_unretained) id <SongsViewControllerDelegate> delegate;

@end
