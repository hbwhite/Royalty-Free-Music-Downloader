//
//  DownloadsTabBarItem.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 4/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadsTabBarItem : UITabBarItem <NSFetchedResultsControllerDelegate> {
@private
    NSFetchedResultsController *fetchedResultsController;
}

@end
