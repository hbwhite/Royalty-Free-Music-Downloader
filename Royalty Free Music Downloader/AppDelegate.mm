//
//  AppDelegate.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarController.h"
#import "LoginNavigationController.h"
#import "FilePaths.h"
#import "DataManager.h"
#import "Downloader.h"
#import "Player.h"
#import "PlayerState.h"
#import "PlayerViewController.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "UIImage+SafeStretchableImage.h"

// AdBlocker
#import "AdBlocker.h"

#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FacebookSDK.h>

#define PASSCODE_REQUIREMENT_DELAY_SECONDS_ARRAY        [NSArray arrayWithObjects:@"60", @"300", @"900", @"3600", @"14400", nil]

static NSString *kRecoveryModeKey                       = @"Recovery Mode";

// These keys will be overwritten by Defaults.plist.
static NSString *kSimplePasscodeKey                     = @"Simple Passcode";
static NSString *kPasscodeRequirementDelayIndexKey      = @"Passcode Requirement Delay Index";

// These keys must be manually deleted.
static NSString *kPasscodeKey                           = @"Passcode";
static NSString *kLastAccessedTimeKey                   = @"Last Accessed Time";
static NSString *kPermittedLoginAccessTimeKey			= @"Permitted Login Access Time";
static NSString *kPermittedAuthenticationAccessTimeKey	= @"Permitted Authentication Access Time";

static NSString *kDefaultsSetKey                        = @"Defaults Set";
static NSString *kWelcomeAlertShownKey                  = @"Welcome Alert Shown";

static NSString *kSavePlaybackTimeKey                   = @"Save Playback Time";

static NSString *kVersion1_1DefaultsSetKey              = @"Version 1.1 Defaults Set";
static NSString *kSkinIndexKey                          = @"Skin Index";
static NSString *kBlockAdsKey                           = @"Block Ads";
static NSString *kDownloadNotificationsKey              = @"Download Notifications";
static NSString *kDownloadAttemptsKey                   = @"Download Attempts";

static NSString *kRemoveAdsPurchasedKey                 = @"Remove Ads Purchased";

@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize hudViewController;

// See the note below regarding Christmas.
// @synthesize splashInterstitial;
// @synthesize splashInterstitialViewController;

@synthesize backgroundTask;
@synthesize didAuthenticate;
@synthesize shouldUpdateLibrary;
@synthesize isRunningInBackground;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Crashlytics startWithAPIKey:@"b3b0890536b2f1c276ac4dc7b96af5f3d428fdd2"];
    
    window = [[ResponderWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    // Override point for customization after application launch.
    
    // By default, the window's background color is black. I believe light gray is more visually appealing.
    window.backgroundColor = [UIColor lightGrayColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (([defaults boolForKey:kRecoveryModeKey]) || (![defaults boolForKey:kDefaultsSetKey])) {
        if ([defaults boolForKey:kRecoveryModeKey]) {
            [[NSFileManager defaultManager]removeItemAtPath:kDataStorageFoundationDirectoryPathStr error:nil];
            
            [defaults removeObjectForKey:kPasscodeKey];
            [defaults removeObjectForKey:kLastAccessedTimeKey];
            [defaults removeObjectForKey:kPermittedLoginAccessTimeKey];
            [defaults removeObjectForKey:kPermittedAuthenticationAccessTimeKey];
        }
        
        [defaults setValuesForKeysWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Defaults" ofType:@"plist"]]];
        
        // Automatically update users of older devices to the iOS 6 skin.
        if ([[[UIDevice currentDevice]systemVersion]compare:@"7.0"] == NSOrderedAscending) {
            [defaults setInteger:1 forKey:kSkinIndexKey];
        }
        
        [defaults synchronize];
    }
    
    if (![defaults boolForKey:kVersion1_1DefaultsSetKey]) {
        // Automatically update legacy users to the iOS 6 skin.
        if ([[[UIDevice currentDevice]systemVersion]compare:@"7.0"] == NSOrderedAscending) {
            [defaults setInteger:1 forKey:kSkinIndexKey];
        }
        
        [defaults setBool:YES forKey:kBlockAdsKey];
        [defaults setBool:YES forKey:kDownloadNotificationsKey];
        [defaults setInteger:5 forKey:kDownloadAttemptsKey];
        [defaults setBool:YES forKey:kVersion1_1DefaultsSetKey];
        [defaults synchronize];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:kDataStorageFoundationDirectoryPathStr]) {
        [fileManager createDirectoryAtPath:kDataStorageFoundationDirectoryPathStr withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:kDataStorageDirectoryPathStr]) {
        [fileManager createDirectoryAtPath:kDataStorageDirectoryPathStr withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:kTemporaryDownloadDirectoryPathStr]) {
        [fileManager createDirectoryAtPath:kTemporaryDownloadDirectoryPathStr withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:kArtworkDirectoryPathStr]) {
        [fileManager createDirectoryAtPath:kArtworkDirectoryPathStr withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:kThumbnailsDirectoryPathStr]) {
        [fileManager createDirectoryAtPath:kThumbnailsDirectoryPathStr withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    [AdBlocker sharedAdBlocker];
    
    DataManager *dataManager = [DataManager sharedDataManager];
    
    // The shouldUpdateLibrary variable is used for consistency.
    shouldUpdateLibrary = ([dataManager fileCount] <= 0);
    
    if (shouldUpdateLibrary) {
        hudViewController = [[UIViewController alloc]init];
        hudViewController.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    }
    else {
        // Prepare the tab bar controller if it isn't going to update the library so the login controller won't hang before it is dismissed (if it is presented).
        tabBarController = [[TabBarController alloc]init];
    }
    
    [window makeKeyAndVisible];
    
    // Modal view controllers must be presented after -makeKeyAndVisible is called on the main window.
    // Because these functions can indirectly present a modal view controller, they are called after -makeKeyAndVisible.
    
    // Christmas is coming. Christmas is a time for giving and kindness. I think my free users put up with enough advertising, so I have decided not to use interstitial ads.
    
    // if ([[NSUserDefaults standardUserDefaults]boolForKey:kRemoveAdsPurchasedKey]) {
        if (shouldUpdateLibrary) {
            window.rootViewController = hudViewController;
        }
        else {
            [self makeTabBarControllerRoot];
        }
    /*
    }
    else {
        // The default image is completely black, so this is unnecessary as long as the background color of the splash interstitial view controller is set to black as well.
        // However, I have included this for the sake of consistency, should the default image change at some point in the future.
        UIImage *defaultImage = nil;
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if ([[UIScreen mainScreen]bounds].size.height == 568) {
                defaultImage = [UIImage imageNamed:@"Default-568h"];
            }
            else {
                defaultImage = [UIImage imageNamed:@"Default"];
            }
        }
        else {
            BOOL iOS7 = ([[[UIDevice currentDevice]systemVersion]compare:@"7.0"] != NSOrderedAscending);
            
            UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
            if (UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
                if (UIDeviceOrientationIsPortrait(orientation)) {
                    if (iOS7) {
                        defaultImage = [UIImage imageNamed:@"Default-7-Portrait"];
                    }
                    else {
                        defaultImage = [UIImage imageNamed:@"Default-Portrait"];
                    }
                }
                else {
                    if (iOS7) {
                        defaultImage = [UIImage imageNamed:@"Default-7-Landscape"];
                    }
                    else {
                        defaultImage = [UIImage imageNamed:@"Default-Landscape"];
                    }
                }
            }
            else {
                if (iOS7) {
                    defaultImage = [UIImage imageNamed:@"Default-7-Portrait"];
                }
                else {
                    defaultImage = [UIImage imageNamed:@"Default-Portrait"];
                }
            }
        }
        
        splashInterstitial = [[GADInterstitial alloc]init];
        splashInterstitial.adUnitID = kSplashInterstitialID;
        splashInterstitial.delegate = self;
        
        // Hiding the status bar while the interstitial is shown prevents the frame of the UI from initially being set incorrectly.
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        GADRequest *request = [GADRequest request];
        
        
        #warning Don't forget to remove the test ad code.
        request.testing = YES;
        
        // iPhone Simulator, iPhone 5G 6.1, and iPod 5G 6.1, respectively.
        request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, @"5a3bf0c1c4cd5d45abb79b5e48609b7f", @"277c0c65fa53bd022d7ac498f558bd15", nil];
        
        
        [splashInterstitial loadRequest:request];
        
        // UIImageView *defaultImageView = [[UIImageView alloc]initWithImage:defaultImage];
        
        splashInterstitialViewController = [[UIViewController alloc]init];
        splashInterstitialViewController.view.backgroundColor = [UIColor blackColor];
        // [splashInterstitialViewController.view addSubview:defaultImageView];
        
        window.rootViewController = splashInterstitialViewController;
        
        // Google's default interstitial timeout delay is 7 seconds. While it doesn't serve the same purpose as the following function, it does provide a useful frame of reference, so I chose 7 seconds as the timeout delay here.
        // If the ad server is unreachable, the app will hang as it tries to load an interstitial, so it must be canceled if one cannot be loaded within 7 seconds of the app launching.
        [self performSelector:@selector(cancelSplashInterstitialIfApplicable) withObject:nil afterDelay:7];
    }
    */
    
    // The database cannot be mutated while a fetch is being performed. Therefore, this is run before the view controllers are loaded to prevent both of these things from happening simultaneously.
    if (shouldUpdateLibrary) {
        [[DataManager sharedDataManager]runInitialLibraryUpdate];
    }
    else {
        [self runPostLibraryUpdateSetup];
    }
    
    return YES;
}

// See the above note regarding Christmas.
/*
- (void)cancelSplashInterstitialIfApplicable {
    if (splashInterstitial) {
        if (!splashInterstitial.isReady) {
            splashInterstitial.delegate = nil;
            
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            
            if ([[DataManager sharedDataManager]backgroundOperationIsActive]) {
                window.rootViewController = hudViewController;
            }
            else {
                [self makeTabBarControllerRoot];
            }
        }
    }
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [splashInterstitial presentFromRootViewController:splashInterstitialViewController];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    if ([[DataManager sharedDataManager]backgroundOperationIsActive]) {
        window.rootViewController = hudViewController;
    }
    else {
        [self makeTabBarControllerRoot];
    }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    // This prevents a modal view controller error that occurs when the view controller is changed immediately, preventing the interstitial modal view controller from being dismissed.
    // Also, this prevents the interstitial modal view controller from preventing the UI from rotating on devices running iOS 4.3 (and possibly others).
    // In addition, this prevents the status bar from changing styles (due to the aforementioned issue) when the app is closed and re-opened while in the player view.
    // This also prevents a deallocation crash that can occur in the same situation at a later point in time when the app attempts to deallocate the aforementioned modal view controller.
    [splashInterstitialViewController safelyDismissModalViewControllerAnimated:NO completion:nil];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    if ([[DataManager sharedDataManager]backgroundOperationIsActive]) {
        window.rootViewController = hudViewController;
    }
    else {
        [self makeTabBarControllerRoot];
    }
}
*/

- (void)runPostLibraryUpdateSetup {
    // Initialize the downloader.
    [Downloader sharedDownloader];
    
    // Initialize the player.
    // If this is run after the basic setup is run, a strange bug can occur in which the app hangs indefinitely while the sharedPlayer singleton isn't being assigned.
    // This bug may be due to the fact that -sharedPlayer is called on different threads by NSNotificationCenter when the now playing file changes and it posts the corresponding notification.
    [Player sharedPlayer];
    
    if (shouldUpdateLibrary) {
        tabBarController = [[TabBarController alloc]init];
        
        // Don't override the splash interstitial view controller.
        
        // See the above note regarding Christmas.
        // if (![window.rootViewController isEqual:splashInterstitialViewController]) {
            [self makeTabBarControllerRoot];
        // }
    }
    
    // The responder window must become the first responder before it can receive remote control and shake events.
    [window becomeFirstResponder];
}

- (void)makeTabBarControllerRoot {
    // The status bar is set to "Black Opaque" when the app launches to stand out from the black splash screen.
    // Because the navigation bars in the main portion of the app are white, the status bar must be updated when they are shown to reflect the change in color.
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
    window.rootViewController = tabBarController;
    
    // This must be called after the tab bar controller has been added to the window hierarchy above.
    if (![self presentLoginControllerIfApplicable]) {
        didAuthenticate = YES;
        
        // This is set here in case the app is terminated without warning later.
        [self logLastAccessedTime];
    }
}

- (BOOL)presentLoginControllerIfApplicable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kPasscodeKey]) {
		NSInteger passcodeRequirementDelayIndex = [defaults integerForKey:kPasscodeRequirementDelayIndexKey];
		if ((passcodeRequirementDelayIndex == 0) || ((CFAbsoluteTimeGetCurrent() - [defaults doubleForKey:kLastAccessedTimeKey]) >= [[PASSCODE_REQUIREMENT_DELAY_SECONDS_ARRAY objectAtIndex:(passcodeRequirementDelayIndex - 1)]integerValue])) {
			LoginNavigationController *loginNavigationController = nil;
            
            // The second segment type is irrelevant in this case.
			if ([defaults boolForKey:kSimplePasscodeKey]) {
                loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:kLoginViewTypeFourDigit secondSegmentType:kLoginViewTypeFourDigit loginType:kLoginTypeLogin];
			}
			else {
                loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:kLoginViewTypeTextField secondSegmentType:kLoginViewTypeTextField loginType:kLoginTypeLogin];
			}
            
            loginNavigationController.loginNavigationControllerDelegate = self;
            
            if ([tabBarController safeModalViewController]) {
                [tabBarController safelyDismissModalViewControllerAnimated:NO completion:nil];
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    while ([tabBarController safeModalViewController]);
                    
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [tabBarController safelyPresentModalViewController:loginNavigationController animated:NO completion:nil];
                    });
                });
            }
            else {
                [tabBarController safelyPresentModalViewController:loginNavigationController animated:NO completion:nil];
            }
            
            // This hides the tab bar controller on the iPad when the user is logging in, since the login view only covers part of the screen.
            tabBarController.view.alpha = 0;
            
            return YES;
		}
	}
    return NO;
}

- (void)loginNavigationControllerDidAuthenticate {
    didAuthenticate = YES;
    
    // This is set here in case the app is terminated without warning later.
    [self logLastAccessedTime];
}

- (void)loginNavigationControllerDidFinish {
    // See the above note regarding logging in on the iPad.
    [UIView animateWithDuration:0.25 animations:^{
        tabBarController.view.alpha = 1;
    }];
    
    [tabBarController safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return (url != nil);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![FBAppCall handleOpenURL:url sourceApplication:sourceApplication]) {
        DataManager *dataManager = [DataManager sharedDataManager];
        
        // This prevents double importing.
        if (![dataManager backgroundOperationIsActive]) {
            File *file = [dataManager importItemAtPathIfApplicable:[url path]];
            if (file) {
                Player *player = [Player sharedPlayer];
                [player setPlaylistItems:[NSArray arrayWithObject:file]];
                [player setCurrentFileWithIndex:0];
                
                // This prevents pushing two PlayerViewControllers in a row.
                
                BOOL playerViewControllerPresented = NO;
                
                // The selected view controller can be the PlayerViewController if the PlayerViewController is pushed from the more navigation controller.
                // For this reason, the class of self.selectedViewController must be checked to avoid calling -topViewController on it if it is the PlayerViewController.
                UIViewController *selectedViewController = tabBarController.selectedViewController;
                if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
                    if ([((UINavigationController *)selectedViewController).topViewController isKindOfClass:[PlayerViewController class]]) {
                        playerViewControllerPresented = YES;
                    }
                    else if ((tabBarController.moreNavigationController) && (tabBarController.moreNavigationController.topViewController) && ([tabBarController.moreNavigationController.topViewController isKindOfClass:[PlayerViewController class]])) {
                        // This will be the case if the PlayerViewController is pushed from a view controller that is pushed from the more navigation controller.
                        playerViewControllerPresented = YES;
                    }
                }
                else if ([selectedViewController isKindOfClass:[PlayerViewController class]]) {
                    // This will be the case if the PlayerViewController is pushed from the more navigation controller.
                    playerViewControllerPresented = YES;
                }
                
                if (!playerViewControllerPresented) {
                    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
                    [(UINavigationController *)tabBarController.selectedViewController pushViewController:playerViewController animated:YES];
                }
            }
        }
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:kWelcomeAlertShownKey]) {
        [defaults setBool:YES forKey:kWelcomeAlertShownKey];
        [defaults synchronize];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    isRunningInBackground = YES;
    
    if (backgroundTask) {
        [application endBackgroundTask:backgroundTask];
    }
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
        backgroundTask = 0;
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    isRunningInBackground = YES;
    
    if (didAuthenticate) {
        [self logLastAccessedTime];
        [self presentLoginControllerIfApplicable];
    }
    
    if (backgroundTask) {
        [application endBackgroundTask:backgroundTask];
    }
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
        backgroundTask = 0;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    if (backgroundTask) {
        [application endBackgroundTask:backgroundTask];
        backgroundTask = 0;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    isRunningInBackground = NO;
    
    // On iOS 4.3, the Facebook API is unstable and periodically throws the error "-[__NSCFDictionary setObject:forKey:]: attempt to insert nil value (key: body)"
    if ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending) {
        // FBSample logic
        // We need to properly handle activation of the application with regards to SSO
        //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
        [FBAppCall handleDidBecomeActive];
        
        [FBSettings setDefaultAppID:@"1484167308481213"];
        [FBAppEvents activateApp];
    }
    
    if (backgroundTask) {
        [application endBackgroundTask:backgroundTask];
        backgroundTask = 0;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    if (didAuthenticate) {
        [self logLastAccessedTime];
    }
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kSavePlaybackTimeKey]) {
        Player *player = [Player sharedPlayer];
        PlayerState *playerState = [player playerState];
        playerState.playbackTime = [NSNumber numberWithDouble:[player currentPlaybackTime]];
        [[DataManager sharedDataManager]saveContext];
    }
    
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
    
    [application endBackgroundTask:backgroundTask];
}

- (void)logLastAccessedTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:CFAbsoluteTimeGetCurrent() forKey:kLastAccessedTimeKey];
    [defaults synchronize];
}

@end
