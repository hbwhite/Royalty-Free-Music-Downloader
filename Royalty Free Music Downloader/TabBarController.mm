//
//  TabBarController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "TabBarController.h"
#import "BrowserViewController.h"
#import "DownloadsViewController.h"
#import "FilesViewController.h"
#import "PlaylistsViewController.h"
#import "ArtistsViewController.h"
#import "SongsViewController.h"
#import "AlbumsViewController.h"
#import "GenresViewController.h"
#import "SettingsViewController.h"
#import "NowPlayingButton.h"
#import "DownloadsTabBarItem.h"
#import "SkinManager.h"
#import "MoreTableViewDataSource.h"
#import "Modes.h"
#import "UIViewController+NibSelect.h"

// Migrated RootViewController Code

#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "CoverflowViewController.h"
#import "RemoveAdsNavigationController.h"
#import "SkinManager.h"
#import "File.h"
#import "UIViewController+SafeModal.h"

// iPhone

#define IPHONE_PORTRAIT_AD_HEIGHT_IN_PIXELS     50
#define IPHONE_LANDSCAPE_AD_HEIGHT_IN_PIXELS    32

// iPad

#define IPAD_PORTRAIT_AD_HEIGHT_IN_PIXELS       90
#define IPAD_LANDSCAPE_AD_HEIGHT_IN_PIXELS      90

// --

#define PLAYER_CONTROLS_HEIGHT_IN_PIXELS        96
#define PORTRAIT_TOOLBAR_HEIGHT_IN_PIXELS       44

static NSString *kRemoveAdsPurchasedKey         = @"Remove Ads Purchased";

static NSString *kPlayerViewShownKey            = @"Player View Shown";
static NSString *kCoverFlowEnabledKey           = @"Cover Flow Enabled";

static NSString *kApplicationURLStr             = @"http://itunes.apple.com/app/id665721040";

static NSString *kShareTextStr                  = @"I'm listening to %@ by %@";
static NSString *kShareTextURLStr               = @"I'm listening to %@ by %@ with %@";

static NSString *kShareTextUnknownArtistStr     = @"I'm listening to %@";
static NSString *kShareTextUnknownArtistURLStr  = @"I'm listening to %@ with %@";

// TabBarController

static NSString *kTabOrderKey                   = @"Tab Order";
static NSString *kSelectedTabBarItemIndexKey    = @"Selected Tab Bar Item Index";

static NSString *kBrowserStr                    = @"Browser";
static NSString *kDownloadsStr                  = @"Downloads";
static NSString *kFilesStr                      = @"Files";
static NSString *kSettingsStr                   = @"Settings";

@interface TabBarController ()

@property (nonatomic, strong) MoreTableViewDataSource *moreTableViewDataSource;
@property (nonatomic, strong) UIImageView *dividerImageView1;
@property (nonatomic, strong) UIImageView *dividerImageView2;
@property (nonatomic, strong) UIImageView *dividerImageView3;
@property (nonatomic, strong) UIImageView *dividerImageView4;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (readwrite) BOOL didRestorePreviousState;
@property (readwrite) BOOL didRunInitialSetup;

- (void)updateSkin;
- (void)removeAdsButtonPressed;
- (NSInteger)landscapeToolbarHeight;
- (GADAdSize)adSizeForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateNavigationBarFrame;
- (void)presentCoverflowViewController;

@end

@implementation TabBarController

// Public
@synthesize bannerViewContainer;
@synthesize currentTrack;
@synthesize bottomBar;
@synthesize bannerViewShown;

// Private
@synthesize moreTableViewDataSource;
@synthesize dividerImageView1;
@synthesize dividerImageView2;
@synthesize dividerImageView3;
@synthesize dividerImageView4;
@synthesize bannerView;
@synthesize didRestorePreviousState;
@synthesize didRunInitialSetup;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:nil];
    
    // Using a loop here helps to define different instances of UINavigationController while reusing the generic variable name "navigationController".
    for (int i = 0; i < 9; i++) {
        if (i == 0) {
            BrowserViewController *browserViewController = [[BrowserViewController alloc]initWithNibBaseName:@"BrowserViewController" bundle:nil];
            browserViewController.title = kBrowserStr;
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:browserViewController];
            navigationController.navigationBarHidden = YES;
            
            [viewControllers addObject:navigationController];
        }
        else if (i == 1) {
            DownloadsViewController *downloadsViewController = [[DownloadsViewController alloc]init];
            downloadsViewController.songSelectorDelegate = self;
            downloadsViewController.title = kDownloadsStr;
            
            DownloadsTabBarItem *downloadsTabBarItem = [[DownloadsTabBarItem alloc]initWithTitle:@"Downloads" image:nil tag:0];
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:downloadsViewController];
            navigationController.tabBarItem = downloadsTabBarItem;
            
            [viewControllers addObject:navigationController];
        }
        else if (i == 2) {
            FilesViewController *filesViewController = [[FilesViewController alloc]init];
            filesViewController.songSelectorDelegate = self;
            filesViewController.title = kFilesStr;
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:filesViewController];
            
            [viewControllers addObject:navigationController];
        }
        else if (i == 3) {
            PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc]init];
            playlistsViewController.songSelectorDelegate = self;
            playlistsViewController.title = NSLocalizedString(@"Playlists", @"");
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:playlistsViewController];
            
            [viewControllers addObject:navigationController];
        }
        else if (i == 4) {
            SongsViewController *songsViewController = [[SongsViewController alloc]init];
            songsViewController.songSelectorDelegate = self;
            songsViewController.title = NSLocalizedString(@"Songs", @"");
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:songsViewController];
            
            [viewControllers addObject:navigationController];
        }
        else if (i == 5) {
            ArtistsViewController *artistsViewController = [[ArtistsViewController alloc]init];
            artistsViewController.songSelectorDelegate = self;
            artistsViewController.title = NSLocalizedString(@"NO_CONTEXT_NAVTITLE_ARTISTS", @"");
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:artistsViewController];
            
            [viewControllers addObject:navigationController];
        }
        else if (i == 6) {
            AlbumsViewController *albumsViewController = [[AlbumsViewController alloc]init];
            albumsViewController.songSelectorDelegate = self;
            albumsViewController.title = NSLocalizedString(@"Albums", @"");
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:albumsViewController];
            
            [viewControllers addObject:navigationController];
        }
        else if (i == 7) {
            GenresViewController *genresViewController = [[GenresViewController alloc]init];
            genresViewController.songSelectorDelegate = self;
            genresViewController.title = NSLocalizedString(@"NO_CONTEXT_NAVTITLE_GENRES", @"");
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:genresViewController];
            
            [viewControllers addObject:navigationController];
        }
        else {
            SettingsViewController *settingsViewController = [[SettingsViewController alloc]init];
            settingsViewController.title = kSettingsStr;
            
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:settingsViewController];
            
            [viewControllers addObject:navigationController];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *currentTabOrderArray = [NSMutableArray arrayWithObjects:nil];
    for (int i = 0; i < [viewControllers count]; i++) {
        UITabBarItem *tabBarItem = [[viewControllers objectAtIndex:i]tabBarItem];
        tabBarItem.tag = i;
        [currentTabOrderArray addObject:[NSNumber numberWithInt:i]];
    }
    NSArray *customTabOrderArray = [defaults arrayForKey:kTabOrderKey];
    NSMutableArray *tabsArray = [NSMutableArray arrayWithObjects:nil];
    for (int i = 0; i < [viewControllers count]; i++) {
        NSInteger index = 0;
        if ([customTabOrderArray count] > i) {
            index = [[customTabOrderArray objectAtIndex:i]integerValue];
        }
        else {
            index = [[currentTabOrderArray objectAtIndex:i]integerValue];
        }
        UINavigationController *navigationController = [viewControllers objectAtIndex:index];
        [tabsArray addObject:navigationController];
    }
    self.viewControllers = tabsArray;
    
    id topView = self.moreNavigationController.topViewController.view;
    if ([topView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = topView;
        moreTableViewDataSource = [[MoreTableViewDataSource alloc]initWithOriginalDataSource:tableView.dataSource tableView:tableView];
        tableView.dataSource = moreTableViewDataSource;
    }
    
    NSInteger selectedIndex = [defaults integerForKey:kSelectedTabBarItemIndexKey];
    if (selectedIndex < [viewControllers count]) {
        self.selectedIndex = selectedIndex;
    }
    
    self.delegate = self;
    self.moreNavigationController.delegate = self;
    
    [SkinManager applySkinIfApplicable];
    
    [self updateSkin];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateSkin) name:kSkinDidChangeNotification object:nil];
}

- (void)updateSkin {
    BOOL iOS6Skin = [SkinManager iOS6Skin];
    BOOL iOS5 = ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending);
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (iOS6Skin) {
            dividerImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(((self.tabBar.frame.size.width / 5.0) - 2), 0, 2, 49)];
            dividerImageView1.contentMode = UIViewContentModeRight;
            dividerImageView1.image = [UIImage imageNamed:@"Tab_Bar_Divider-6"];
            dividerImageView1.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [self.tabBar addSubview:dividerImageView1];
            
            dividerImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake((((self.tabBar.frame.size.width / 5.0) * 2) - 2), 0, 2, 49)];
            dividerImageView2.contentMode = UIViewContentModeRight;
            dividerImageView2.image = [UIImage imageNamed:@"Tab_Bar_Divider-6"];
            dividerImageView2.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [self.tabBar addSubview:dividerImageView2];
            
            dividerImageView3 = [[UIImageView alloc]initWithFrame:CGRectMake((((self.tabBar.frame.size.width / 5.0) * 3) - 2), 0, 2, 49)];
            dividerImageView3.contentMode = UIViewContentModeRight;
            dividerImageView3.image = [UIImage imageNamed:@"Tab_Bar_Divider-6"];
            dividerImageView3.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [self.tabBar addSubview:dividerImageView3];
            
            dividerImageView4 = [[UIImageView alloc]initWithFrame:CGRectMake((((self.tabBar.frame.size.width / 5.0) * 4) - 2), 0, 2, 49)];
            dividerImageView4.contentMode = UIViewContentModeRight;
            dividerImageView4.image = [UIImage imageNamed:@"Tab_Bar_Divider-6"];
            dividerImageView4.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [self.tabBar addSubview:dividerImageView4];
        }
        else {
            [dividerImageView1 removeFromSuperview];
            [dividerImageView2 removeFromSuperview];
            [dividerImageView3 removeFromSuperview];
            [dividerImageView4 removeFromSuperview];
        }
    }
    
    for (int i = 0; i < [self.viewControllers count]; i++) {
        UITabBarItem *item = [[self.viewControllers objectAtIndex:i]tabBarItem];
        
        NSString *imageName = nil;
        
        switch (item.tag) {
            case 0:
                imageName = @"Browser";
                break;
            case 1:
                imageName = @"Downloads";
                break;
            case 2:
                imageName = @"File";
                break;
            case 3:
                imageName = @"Playlists";
                break;
            case 4:
                imageName = @"Songs";
                break;
            case 5:
                imageName = @"Artists";
                break;
            case 6:
                imageName = @"Albums";
                break;
            case 7:
                imageName = @"Genres";
                break;
            case 8:
                imageName = @"Settings";
                break;
        }
        
        item.image = [UIImage iOS7SkinImageNamed:imageName];
        
        if (iOS6Skin) {
            UIImage *image = [UIImage skinImageNamed:imageName];
            [item setFinishedSelectedImage:image withFinishedUnselectedImage:image];
        }
        else if ([item respondsToSelector:@selector(setFinishedSelectedImage:withFinishedUnselectedImage:)]) {
            [item setFinishedSelectedImage:nil withFinishedUnselectedImage:nil];
        }
    }
    
    if ((iOS6Skin) || ([SkinManager iOS7Skin])) {
        UIImage *image = [UIImage skinImageNamed:@"More"];
        UITabBarItem *moreTabBarItem = [[UITabBarItem alloc]initWithTitle:@"More" image:image tag:0];
        if (iOS5) {
            [moreTabBarItem setFinishedSelectedImage:image withFinishedUnselectedImage:image];
        }
        self.moreNavigationController.tabBarItem = moreTabBarItem;
    }
    else {
        self.moreNavigationController.tabBarItem = nil;
    }
    
    // iOS 7 appearance fix.
    if ([self.tabBar respondsToSelector:@selector(setTranslucent:)]) {
        [self.tabBar setTranslucent:NO];
    }
}

#pragma mark Song selector delegate

- (kMode)songSelectorMode {
    return kModeMain;
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSInteger index = tabBarController.selectedIndex;
    
    if (index < 4) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:index forKey:kSelectedTabBarItemIndexKey];
        [defaults synchronize];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    if ([SkinManager iOS6Skin]) {
        for (int i = 0; i < [self.view.subviews count]; i++) {
            UIView *subview = [self.view.subviews objectAtIndex:i];
            if ([subview isKindOfClass:NSClassFromString(@"UITabBarCustomizeView")]) {
                NSInteger navigationBarHeight = 44;
                
                for (int j = 0; j < [subview.subviews count]; j++) {
                    UIView *subSubview = [subview.subviews objectAtIndex:j];
                    if ([subSubview isKindOfClass:[UINavigationBar class]]) {
                        navigationBarHeight = subSubview.frame.size.height;
                        break;
                    }
                }
                
                UIImageView *configureGradientImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, navigationBarHeight, subview.frame.size.width, (subview.frame.size.height - navigationBarHeight))];
                configureGradientImageView.image = [UIImage imageNamed:@"Configure_Gradient-6"];
                [subview insertSubview:configureGradientImageView atIndex:0];
                break;
            }
        }
    }
}

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
	if (changed) {
		NSMutableArray *tabOrderArray = [NSMutableArray arrayWithObjects:nil];
		for (int i = 0; i < [viewControllers count]; i++) {
			UIViewController *viewController = [viewControllers objectAtIndex:i];
			[tabOrderArray addObject:[NSNumber numberWithInteger:viewController.tabBarItem.tag]];
		}
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:tabOrderArray forKey:kTabOrderKey];
        [defaults synchronize];
	}
}

#pragma mark Navigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.moreNavigationController.delegate = nil;
    
    UINavigationItem *navigationItem = self.moreNavigationController.navigationBar.topItem;
    navigationItem.leftBarButtonItem = navigationItem.rightBarButtonItem;
    
    NowPlayingButton *nowPlayingButton = [[NowPlayingButton alloc]init];
    navigationItem.rightBarButtonItem = nowPlayingButton;
}

#pragma mark -

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([SkinManager iOS6Skin]) {
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
                dividerImageView1.hidden = NO;
                dividerImageView2.hidden = NO;
                dividerImageView3.hidden = NO;
                dividerImageView4.hidden = NO;
            }
            else {
                dividerImageView1.hidden = YES;
                dividerImageView2.hidden = YES;
                dividerImageView3.hidden = YES;
                dividerImageView4.hidden = YES;
            }
        }
    }
}

#pragma mark RootViewController migrated code

- (void)removeAds {
    bannerView.delegate = nil;
    
    // This prevents ads from being refreshed in the background.
    bannerView.hidden = YES;
    
    [bannerViewContainer removeFromSuperview];
    
    bannerViewShown = NO;
    [[NSNotificationCenter defaultCenter]postNotificationName:kAdDidHideNotification object:nil];
}

- (void)removeAdsButtonPressed {
    RemoveAdsNavigationController *removeAdsNavigationController = [[RemoveAdsNavigationController alloc]init];
    removeAdsNavigationController.removeAdsNavigationControllerDelegate = self;
    [self safelyPresentModalViewController:removeAdsNavigationController animated:YES completion:nil];
}

- (void)removeAdsNavigationControllerDidFinish {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)tagEditorNavigationControllerDidCancel {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)tagEditorNavigationControllerDidFinishEditingTags {
    PlayerViewController *playerViewController = nil;
    
    // The selected view controller can be the PlayerViewController if the PlayerViewController is pushed from the more navigation controller.
    // For this reason, the class of self.selectedViewController must be checked to avoid calling -topViewController on it if it is the PlayerViewController.
    UIViewController *selectedViewController = self.selectedViewController;
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        if ([((UINavigationController *)selectedViewController).topViewController isKindOfClass:[PlayerViewController class]]) {
            playerViewController = (PlayerViewController *)((UINavigationController *)selectedViewController).topViewController;
        }
        else if ((self.moreNavigationController) && (self.moreNavigationController.topViewController) && ([self.moreNavigationController.topViewController isKindOfClass:[PlayerViewController class]])) {
            // This will be the case if the PlayerViewController is pushed from a view controller that is pushed from the more navigation controller.
            playerViewController = (PlayerViewController *)self.moreNavigationController.topViewController;
        }
    }
    else if ([selectedViewController isKindOfClass:[PlayerViewController class]]) {
        // This will be the case if the PlayerViewController is pushed from the more navigation controller.
        playerViewController = (PlayerViewController *)selectedViewController;
    }
    
    if (playerViewController) {
        [playerViewController didFinishEditingTags];
    }
    
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)multipleTagEditorNavigationControllerDidCancel {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)multipleTagEditorNavigationControllerDidFinishEditingTags {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)sleepTimerNavigationControllerDidFinish {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            [self shareCurrentTrackViaFacebook];
        }
        else if (buttonIndex == 1) {
            [self shareCurrentTrackViaTwitter];
        }
    }
    else if (buttonIndex == 0) {
        if (actionSheet.tag == 1) {
            [self shareCurrentTrackViaTwitter];
        }
        else if (actionSheet.tag == 2) {
            [self shareCurrentTrackViaFacebook];
        }
    }
}

- (void)shareCurrentTrackViaFacebook {
    NSURL *url = [NSURL URLWithString:kApplicationURLStr];
    
    NSString *artistName = currentTrack.artistName;
    if ((!artistName) || ((artistName) && ([[artistName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] <= 0))) {
        artistName = currentTrack.albumArtistName;
    }
    
    BOOL unknownArtist = ((!artistName) || ((artistName) && ([[artistName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] <= 0)));
    
    NSString *initialText = nil;
    
    if (unknownArtist) {
        initialText = [NSString stringWithFormat:kShareTextUnknownArtistStr, currentTrack.title];
    }
    else {
        initialText = [NSString stringWithFormat:kShareTextStr, currentTrack.title, currentTrack.artistName];
    }
    
    if (NSClassFromString(@"SLComposeViewController")) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:initialText];
        
        if (![composeViewController addURL:url]) {
            if (unknownArtist) {
                [composeViewController setInitialText:[NSString stringWithFormat:kShareTextUnknownArtistURLStr, currentTrack.title, kApplicationURLStr]];
            }
            else {
                [composeViewController setInitialText:[NSString stringWithFormat:kShareTextURLStr, currentTrack.title, currentTrack.artistName, kApplicationURLStr]];
            }
        }
        
        [self safelyPresentModalViewController:composeViewController animated:YES completion:nil];
    }
    else {
        [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                 initialText:initialText
                                                       image:nil
                                                         url:url
                                                     handler:nil];
    }
}

- (void)shareCurrentTrackViaTwitter {
    NSURL *url = [NSURL URLWithString:kApplicationURLStr];
    
    NSString *artistName = currentTrack.artistName;
    if ((!artistName) || ((artistName) && ([[artistName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] <= 0))) {
        artistName = currentTrack.albumArtistName;
    }
    
    BOOL unknownArtist = ((!artistName) || ((artistName) && ([[artistName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] <= 0)));
    
    NSString *initialText = nil;
    
    if (unknownArtist) {
        initialText = [NSString stringWithFormat:kShareTextUnknownArtistStr, currentTrack.title];
    }
    else {
        initialText = [NSString stringWithFormat:kShareTextStr, currentTrack.title, currentTrack.artistName];
    }
    
    if (NSClassFromString(@"SLComposeViewController")) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:initialText];
        
        if (![composeViewController addURL:url]) {
            if (unknownArtist) {
                [composeViewController setInitialText:[NSString stringWithFormat:kShareTextUnknownArtistURLStr, currentTrack.title, kApplicationURLStr]];
            }
            else {
                [composeViewController setInitialText:[NSString stringWithFormat:kShareTextURLStr, currentTrack.title, currentTrack.artistName, kApplicationURLStr]];
            }
        }
        
        [self safelyPresentModalViewController:composeViewController animated:YES completion:nil];
    }
    else {
        TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc]init];
        [tweetComposeViewController setInitialText:initialText];
        
        if (![tweetComposeViewController addURL:url]) {
            [tweetComposeViewController setInitialText:[NSString stringWithFormat:kShareTextURLStr, currentTrack.title, currentTrack.artistName, kApplicationURLStr]];
        }
        
        [self safelyPresentModalViewController:tweetComposeViewController animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (!didRestorePreviousState) {
        didRestorePreviousState = YES;
        
        // The bottom bar will not hide if the PlayerViewController is pushed when the tab bar is initialized, so it must be pushed here.
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kPlayerViewShownKey]) {
            PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
            [(UINavigationController *)self.selectedViewController pushViewController:playerViewController animated:NO];
        }
    }
    
    [self updateNavigationBarFrame];
    [self updateBannerViewFrames:NO];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!didRunInitialSetup) {
        didRunInitialSetup = YES;
        
        // The banner view must be set up in -viewDidAppear: because if it is set up earlier (such as in -viewDidLoad or -viewWillAppear:) when the app is launched in the landscape orientation, it will never load any ads and display the error "Must set the rootViewController property of GADBannerView before calling loadRequest:", even though the rootViewController property has already been set correctly.
        if (![[NSUserDefaults standardUserDefaults]boolForKey:kRemoveAdsPurchasedKey]) {
            GADAdSize adSize = [self adSizeForOrientation:self.interfaceOrientation];
            bannerView = [[GADBannerView alloc]initWithAdSize:adSize];
            bannerView.adUnitID = kAdUnitID;
            bannerView.delegate = self;
            bannerView.rootViewController = self;
            
            GADRequest *request = [GADRequest request];
            
            /*
#warning Don't forget to remove the test ad code.
            request.testing = YES;
            
            // iPhone Simulator, iPhone 5G 6.1, and iPod 5G 6.1, respectively.
            request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, @"5a3bf0c1c4cd5d45abb79b5e48609b7f", @"277c0c65fa53bd022d7ac498f558bd15", nil];
            */
            
            [bannerView loadRequest:request];
            
            bannerViewContainer = [[UIView alloc]initWithFrame:bannerView.bounds];
            [bannerViewContainer addSubview:bannerView];
            [self updateBannerViewFrames:NO];
            [self.view addSubview:bannerViewContainer];
        }
    }
    
    // The banner view frame should be updated after the banner view has been initialized, so I have moved these functions to run after the initial setup code above.
    
    // For some reason, elements don't always display properly if they are updated when -viewWillAppear: is called, so they have to be updated here instead.
    [self updateNavigationBarFrame];
    [self updateBannerViewFrames:NO];
    [super viewDidAppear:animated];
}

- (NSInteger)landscapeToolbarHeight {
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 32;
    }
    else {
        return 44;
    }
}

- (void)updateBannerViewFrames:(BOOL)animated {
    if (![[NSUserDefaults standardUserDefaults]boolForKey:kRemoveAdsPurchasedKey]) {
        bannerView.adSize = [self adSizeForOrientation:self.interfaceOrientation];
        
        NSInteger viewHeight = self.view.frame.size.height;
        if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
            viewHeight = self.view.frame.size.width;
        }
        
        NSInteger bottomMarginHeight = 0;
        switch (bottomBar) {
            case kBottomBarTabBar:
                bottomMarginHeight = self.tabBar.frame.size.height;
                break;
            case kBottomBarTabBarWithPortraitToolbar:
                bottomMarginHeight = (self.tabBar.frame.size.height + PORTRAIT_TOOLBAR_HEIGHT_IN_PIXELS);
                break;
            case kBottomBarTabBarWithLandscapeToolbar:
                bottomMarginHeight = (self.tabBar.frame.size.height + [self landscapeToolbarHeight]);
                break;
            case kBottomBarPortraitToolbar:
                bottomMarginHeight = PORTRAIT_TOOLBAR_HEIGHT_IN_PIXELS;
                break;
            case kBottomBarLandscapeToolbar:
                bottomMarginHeight = [self landscapeToolbarHeight];
                break;
            case kBottomBarPlayerControls:
                bottomMarginHeight = PLAYER_CONTROLS_HEIGHT_IN_PIXELS;
                break;
        }
        
        CGRect bannerViewContainerFrame = CGRectMake(0, (viewHeight - (bottomMarginHeight + bannerView.frame.size.height)), bannerView.frame.size.width, bannerView.frame.size.height);
        
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                bannerViewContainer.frame = bannerViewContainerFrame;
            }];
        }
        else {
            bannerViewContainer.frame = bannerViewContainerFrame;
        }
    }
}

// Define a common function for choosing an ad size based on the device's
// orientation.
- (GADAdSize)adSizeForOrientation:(UIInterfaceOrientation)orientation {
    // This improves mediation support.
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return kGADAdSizeSmartBannerPortrait;
    }
    else {
        return kGADAdSizeSmartBannerLandscape;
    }
    
    /*
     // Landscape.
     // Only some networks support a thin landscape size
     // (480x32 on iPhone or 1024x90 on iPad).
     if (UIInterfaceOrientationIsLandscape(orientation)) {
     return kGADAdSizeSmartBannerLandscape;
     }
     // Portrait.
     // Most networks support banner (320x50) and Leaderboard (728x90)
     // sizes.
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
     return kGADAdSizeLeaderboard;
     } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
     return kGADAdSizeBanner;
     }
     // Unknown idiom.
     return kGADAdSizeBanner;
     */
}

- (void)updateNavigationBarFrame {
    CGSize boundsSize = self.view.bounds.size;
    UINavigationBar *navigationBar = ((UINavigationController *)self.selectedViewController).navigationBar;
	CGSize navigationBarSize = [navigationBar sizeThatFits:boundsSize];
	navigationBar.frame = CGRectMake(navigationBar.frame.origin.x, navigationBar.frame.origin.y, navigationBarSize.width, navigationBarSize.height);
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    // The banner view container frame is based on the frame of the mediatedAdView, which isn't always set immediately.
    // To prevent frame inconsistencies, the frames are updated here as well.
    [self updateBannerViewFrames:NO];
    
    bannerViewContainer.hidden = NO;
    bannerViewShown = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:kAdDidShowNotification object:nil];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    bannerViewContainer.hidden = YES;
    bannerViewShown = NO;
    [[NSNotificationCenter defaultCenter]postNotificationName:kAdDidHideNotification object:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateNavigationBarFrame];
    [self updateBannerViewFrames:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // self.interfaceOrientation is inaccurate in -didRotateFromInterfaceOrientation: on devices running iOS 4.3, so rotation must be handled in -shouldAutorotateToInterfaceOrientation: instead.
    if ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending) {
        // Due to a strange bug in iOS, if the app is in landscape mode (with the cover flow modal view controller presented) when the user switches apps, then if the app is restored in portrait mode, it will report the landscape orientation as both the fromInterfaceOrientation and self.interfaceOrientation.
        // Because this function is only called when those two variables are different, this condition is treated as a rotation to UIInterfaceOrientationPortrait.
        if (self.interfaceOrientation == fromInterfaceOrientation) {
            [self handleRotationToInterfaceOrientation:UIInterfaceOrientationPortrait];
        }
        else {
            [self handleRotationToInterfaceOrientation:self.interfaceOrientation];
        }
    }
}

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        if ([self safeModalViewController]) {
            if ([[self safeModalViewController]isKindOfClass:[CoverflowViewController class]]) {
                [self safelyDismissModalViewControllerAnimated:YES completion:nil];
            }
        }
    }
    else if ([[NSUserDefaults standardUserDefaults]boolForKey:kCoverFlowEnabledKey]) {
        // The cover flow view controller should only be presented when the player view controller is visible.
        // If this is not the case, iPad users will have to disable the cover flow feature to use the main portion of the app in landscape mode.
        if (![self safeModalViewController]) {
            // The selected view controller can be the PlayerViewController if the PlayerViewController is pushed from the more navigation controller.
            // For this reason, the class of self.selectedViewController must be checked to avoid calling -topViewController on it if it is the PlayerViewController.
            UIViewController *selectedViewController = self.selectedViewController;
            if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
                if ([((UINavigationController *)selectedViewController).topViewController isKindOfClass:[PlayerViewController class]]) {
                    [self presentCoverflowViewController];
                }
                else if ((self.moreNavigationController) && (self.moreNavigationController.topViewController) && ([self.moreNavigationController.topViewController isKindOfClass:[PlayerViewController class]])) {
                    // This will be the case if the PlayerViewController is pushed from a view controller that is pushed from the more navigation controller.
                    [self presentCoverflowViewController];
                }
            }
            else if ([selectedViewController isKindOfClass:[PlayerViewController class]]) {
                // This will be the case if the PlayerViewController is pushed from the more navigation controller.
                [self presentCoverflowViewController];
            }
        }
    }
}

- (void)presentCoverflowViewController {
    CoverflowViewController *coverflowViewController = [[CoverflowViewController alloc]initWithNibBaseName:@"CoverflowViewController" bundle:nil];
    [coverflowViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self safelyPresentModalViewController:coverflowViewController animated:YES completion:nil];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // self.interfaceOrientation is inaccurate in -didRotateFromInterfaceOrientation: on devices running iOS 4.3, so rotation must be handled in -shouldAutorotateToInterfaceOrientation: instead.
    if ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] == NSOrderedAscending) {
        [self handleRotationToInterfaceOrientation:interfaceOrientation];
    }
    
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// iOS 6 Rotation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
