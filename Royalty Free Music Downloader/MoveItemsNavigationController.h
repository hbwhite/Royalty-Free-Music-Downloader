//
//  MoveItemsNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveItemsNavigationControllerDelegate.h"
#import "MoveItemsViewControllerDelegate.h"

@class MoveItemsViewController;

@interface MoveItemsNavigationController : UINavigationController <MoveItemsViewControllerDelegate> {
@public
    id <MoveItemsNavigationControllerDelegate> __unsafe_unretained moveItemsNavigationControllerDelegate;
@private
    MoveItemsViewController *moveItemsViewController;
}

@property (nonatomic, unsafe_unretained) id <MoveItemsNavigationControllerDelegate> moveItemsNavigationControllerDelegate;

- (id)initWithItems:(NSArray *)items;

@end
