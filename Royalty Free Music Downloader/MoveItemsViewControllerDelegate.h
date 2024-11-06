//
//  MoveItemsViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/23/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@protocol MoveItemsViewControllerDelegate <NSObject>

@optional
- (void)moveItemsViewControllerDidCancel;
- (void)moveItemsViewControllerDidFinishMovingItems;

@end
