//
//  AppDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponderWindow.h"
#import "LoginNavigationControllerDelegate.h"

// See the note in the implementation file regarding Christmas.
// #import "GADInterstitial.h"

#define kAdUnitID               @"ca-app-pub-6373150690281793/2979333952"
// #define kSplashInterstitialID   @""

#define kAdDidShowNotification  @"Ad Did Show"
#define kAdDidHideNotification  @"Ad Did Hide"

@class TabBarController;
@class GADInterstitial;

@interface AppDelegate : UIResponder <UIApplicationDelegate, /* GADInterstitialDelegate, */ LoginNavigationControllerDelegate> {
    ResponderWindow *window;
    TabBarController *tabBarController;
    UIViewController *hudViewController;
    
    // GADInterstitial *splashInterstitial;
    // UIViewController *splashInterstitialViewController;
    
    UIBackgroundTaskIdentifier backgroundTask;
    BOOL didAuthenticate;
    BOOL shouldUpdateLibrary;
    BOOL isRunningInBackground;
}

@property (nonatomic, strong) ResponderWindow *window;
@property (nonatomic, strong) TabBarController *tabBarController;
@property (nonatomic, strong) UIViewController *hudViewController;

// @property (nonatomic, strong) GADInterstitial *splashInterstitial;
// @property (nonatomic, strong) UIViewController *splashInterstitialViewController;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (readwrite) BOOL didAuthenticate;
@property (readwrite) BOOL shouldUpdateLibrary;
@property (readwrite) BOOL isRunningInBackground;

// - (void)cancelSplashInterstitialIfApplicable;
- (void)runPostLibraryUpdateSetup;
- (void)makeTabBarControllerRoot;
- (BOOL)presentLoginControllerIfApplicable;
- (void)logLastAccessedTime;

@end
