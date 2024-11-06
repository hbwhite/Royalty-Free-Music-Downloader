//
//  TabBarController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "SongSelectorDelegate.h"
#import "TagEditorNavigationControllerDelegate.h"
#import "MultipleTagEditorNavigationControllerDelegate.h"
#import "SleepTimerNavigationControllerDelegate.h"
#import "RemoveAdsNavigationControllerDelegate.h"

#import "GADBannerView.h"

@class TabBarController;
@class GADBannerView;
@class File;

enum {
    kBottomBarTabBar = 0,
    kBottomBarTabBarWithPortraitToolbar,
    kBottomBarTabBarWithLandscapeToolbar,
    kBottomBarPortraitToolbar,
    kBottomBarLandscapeToolbar,
    kBottomBarPlayerControls
};
typedef NSUInteger kBottomBar;

@class MoreTableViewDataSource;

@interface TabBarController : UITabBarController <UITabBarControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, SongSelectorDelegate, TagEditorNavigationControllerDelegate, MultipleTagEditorNavigationControllerDelegate, SleepTimerNavigationControllerDelegate, RemoveAdsNavigationControllerDelegate, GADBannerViewDelegate> {
@public
    UIView *bannerViewContainer;
    File *currentTrack;
    kBottomBar bottomBar;
    BOOL bannerViewShown;
@private
    MoreTableViewDataSource *moreTableViewDataSource;
    UIImageView *dividerImageView1;
    UIImageView *dividerImageView2;
    UIImageView *dividerImageView3;
    UIImageView *dividerImageView4;
    GADBannerView *bannerView;
    BOOL didRestorePreviousState;
    BOOL didRunInitialSetup;
}

@property (nonatomic, strong) UIView *bannerViewContainer;
@property (nonatomic, strong) File *currentTrack;
@property (nonatomic) kBottomBar bottomBar;
@property (readwrite) BOOL bannerViewShown;

- (void)removeAds;
- (void)updateBannerViewFrames:(BOOL)animated;

@end
