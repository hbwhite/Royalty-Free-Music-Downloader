//
//  LoginNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/1/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "LoginNavigationController.h"
#import "LoginViewController.h"
#import "UIViewController+NibSelect.h"

@interface LoginNavigationController ()

@property (nonatomic, strong) LoginViewController *loginViewController;

@end

@implementation LoginNavigationController

// Public
@synthesize loginNavigationControllerDelegate;

// Private
@synthesize loginViewController;

- (id)initWithFirstSegmentType:(kLoginViewType)firstSegmentType secondSegmentType:(kLoginViewType)secondSegmentType loginType:(kLoginType)loginType {
    self = [super init];
    if (self) {
        // Initialization code
        
        // iOS 7 appearance fix.
        self.navigationBar.translucent = NO;
        
        loginViewController = [[LoginViewController alloc]initWithNibBaseName:@"LoginViewController" bundle:nil];
        loginViewController.delegate = self;
        loginViewController.firstSegmentLoginViewType = firstSegmentType;
        loginViewController.secondSegmentLoginViewType = secondSegmentType;
        loginViewController.loginType = loginType;
        
        self.viewControllers = [NSArray arrayWithObject:loginViewController];
        
        switch (loginType) {
            case kLoginTypeLogin:
                self.navigationBar.topItem.title = @"Royalty Free Music Downloader";
                break;
            case kLoginTypeAuthenticate:
                self.navigationBar.topItem.title = @"Enter Passcode";
                break;
            case kLoginTypeChangePasscode:
                self.navigationBar.topItem.title = @"Change Passcode";
                break;
            case kLoginTypeCreatePasscode:
                self.navigationBar.topItem.title = @"Create Passcode";
                break;
        }
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    loginViewController.finished = YES;
    [super viewWillDisappear:animated];
}

- (void)loginViewControllerDidAuthenticate {
    if (loginNavigationControllerDelegate) {
        if ([loginNavigationControllerDelegate respondsToSelector:@selector(loginNavigationControllerDidAuthenticate)]) {
            [loginNavigationControllerDelegate loginNavigationControllerDidAuthenticate];
        }
    }
}

- (void)loginViewControllerDidFinish {
    if (loginNavigationControllerDelegate) {
        if ([loginNavigationControllerDelegate respondsToSelector:@selector(loginNavigationControllerDidFinish)]) {
            [loginNavigationControllerDelegate loginNavigationControllerDidFinish];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
}

// iOS 6 Rotation Methods

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

@end
