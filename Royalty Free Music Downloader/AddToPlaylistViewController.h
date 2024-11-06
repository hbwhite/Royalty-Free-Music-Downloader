//
//  AddToPlaylistViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongSelectorDelegate.h"
#import "AddToPlaylistViewControllerDelegate.h"

@class MoreTableViewDataSource;

@interface AddToPlaylistViewController : UITabBarController <UITabBarControllerDelegate, UINavigationControllerDelegate, SongSelectorDelegate> {
@private
    id <AddToPlaylistViewControllerDelegate> __unsafe_unretained _addToPlaylistViewControllerDelegate;
    NSMutableArray *selectedFilesArray;
    MoreTableViewDataSource *moreTableViewDataSource;
    UIImageView *dividerImageView1;
    UIImageView *dividerImageView2;
    UIImageView *dividerImageView3;
    UIImageView *dividerImageView4;
}

- (id)initWithDelegate:(id <AddToPlaylistViewControllerDelegate>)addToPlaylistViewControllerDelegate;

@end
