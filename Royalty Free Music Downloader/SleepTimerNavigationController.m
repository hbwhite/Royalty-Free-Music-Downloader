//
//  SleepTimerNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "SleepTimerNavigationController.h"
#import "SleepTimerViewController.h"
#import "UIViewController+NibSelect.h"

@interface SleepTimerNavigationController ()

@property (nonatomic, strong) SleepTimerViewController *sleepTimerViewController;

@end

@implementation SleepTimerNavigationController

// Public
@synthesize sleepTimerNavigationControllerDelegate;

// Private
@synthesize sleepTimerViewController;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        
        sleepTimerViewController = [[SleepTimerViewController alloc]initWithNibBaseName:@"SleepTimerViewController" bundle:nil];
        sleepTimerViewController.title = @"Sleep Timer";
        sleepTimerViewController.delegate = self;
        
        self.viewControllers = [NSArray arrayWithObject:sleepTimerViewController];
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)sleepTimerViewControllerDidFinish {
    if (sleepTimerNavigationControllerDelegate) {
        if ([sleepTimerNavigationControllerDelegate respondsToSelector:@selector(sleepTimerNavigationControllerDidFinish)]) {
            [sleepTimerNavigationControllerDelegate sleepTimerNavigationControllerDidFinish];
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
