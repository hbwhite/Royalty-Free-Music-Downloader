//
//  ResponderWindow.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 4/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "ResponderWindow.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "PlayerViewController.h"
#import "Player.h"
#import "UIViewController+NibSelect.h"

static NSString *kShakeToShuffleKey = @"Shake to Shuffle";

@implementation ResponderWindow

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            Player *player = [Player sharedPlayer];
            
            if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
                [player togglePlaybackState];
            }
            else if (event.subtype == UIEventSubtypeRemoteControlPlay) {
                [player play];
            }
            else if (event.subtype == UIEventSubtypeRemoteControlPause) {
                [player pause];
            }
            else if (event.subtype == UIEventSubtypeRemoteControlStop) {
                [player stop];
            }
            else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
                [player skipToPreviousTrack];
            }
            else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
                [player skipToNextTrack];
            }
        });
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kShakeToShuffleKey]) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                Player *player = [Player sharedPlayer];
                if ([player playing]) {
                    [player shuffle];
                    
                    BOOL playerViewControllerPresented = NO;
                    
                    TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
                    
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
            });
        }
    }
}

@end
