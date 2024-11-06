//
//  RemoveAdsNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "RemoveAdsNavigationController.h"
#import "RemoveAdsViewController.h"

@interface RemoveAdsNavigationController ()

@property (nonatomic, strong) RemoveAdsViewController *removeAdsViewController;

@end

@implementation RemoveAdsNavigationController

// Public
@synthesize removeAdsNavigationControllerDelegate;

// Private
@synthesize removeAdsViewController;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        
        removeAdsViewController = [[RemoveAdsViewController alloc]initWithStyle:UITableViewStyleGrouped];
        removeAdsViewController.title = @"Remove Ads";
        removeAdsViewController.delegate = self;
        
        self.viewControllers = [NSArray arrayWithObject:removeAdsViewController];
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)removeAdsViewControllerDidFinish {
    if (removeAdsNavigationControllerDelegate) {
        if ([removeAdsNavigationControllerDelegate respondsToSelector:@selector(removeAdsNavigationControllerDidFinish)]) {
            [removeAdsNavigationControllerDelegate removeAdsNavigationControllerDidFinish];
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
