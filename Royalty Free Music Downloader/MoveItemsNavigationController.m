//
//  MoveItemsNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "MoveItemsNavigationController.h"
#import "MoveItemsViewController.h"

@interface MoveItemsNavigationController ()

@property (nonatomic, strong) MoveItemsViewController *moveItemsViewController;

@end

@implementation MoveItemsNavigationController

// Public
@synthesize moveItemsNavigationControllerDelegate;

// Private
@synthesize moveItemsViewController;

- (id)initWithItems:(NSArray *)items {
    self = [super init];
    if (self) {
        // Initialization code
        
        moveItemsViewController = [[MoveItemsViewController alloc]initWithStyle:UITableViewStylePlain];
        moveItemsViewController.title = @"Move to...";
        moveItemsViewController.delegate = self;
        [moveItemsViewController.items setArray:items];
        
        self.viewControllers = [NSArray arrayWithObject:moveItemsViewController];
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)moveItemsViewControllerDidCancel {
    if (moveItemsNavigationControllerDelegate) {
        if ([moveItemsNavigationControllerDelegate respondsToSelector:@selector(moveItemsNavigationControllerDidCancel)]) {
            [moveItemsNavigationControllerDelegate moveItemsNavigationControllerDidCancel];
        }
    }
}

- (void)moveItemsViewControllerDidFinishMovingItems {
    if (moveItemsNavigationControllerDelegate) {
        if ([moveItemsNavigationControllerDelegate respondsToSelector:@selector(moveItemsNavigationControllerDidFinishMovingItems)]) {
            [moveItemsNavigationControllerDelegate moveItemsNavigationControllerDidFinishMovingItems];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
