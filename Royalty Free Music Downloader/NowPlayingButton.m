//
//  NowPlayingButton.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "NowPlayingButton.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "PlayerViewController.h"
#import "Player.h"
#import "MSLabel.h"
#import "SkinManager.h"
#import "UIViewController+NibSelect.h"
#import "UIImage+SafeStretchableImage.h"

@interface NowPlayingButton ()

- (void)updateSkin;
- (void)nowPlayingButtonPressed;

@end

@implementation NowPlayingButton

@synthesize nowPlayingContentButton;
@synthesize nowPlayingLabel;

- (id)init {
    self = [super init];
    if (self) {
        nowPlayingContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nowPlayingContentButton addTarget:self action:@selector(nowPlayingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        nowPlayingLabel = [[MSLabel alloc]init];
        nowPlayingLabel.numberOfLines = 0;
        nowPlayingLabel.lineBreakMode = NSLineBreakByWordWrapping;
        nowPlayingLabel.text = [NSLocalizedString(@"NOW_PLAYING_BUTTON_LABEL", @"") stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        nowPlayingLabel.backgroundColor = [UIColor clearColor];
        [nowPlayingContentButton addSubview:nowPlayingLabel];
        
        self.customView = nowPlayingContentButton;
        
        [self updateSkin];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateSkin) name:kSkinDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateSkin {
    if ([SkinManager iOS6Skin]) {
        nowPlayingContentButton.frame = nowPlayingContentButton.frame = CGRectMake(0, 0, 55, 30);
        [nowPlayingContentButton setBackgroundImage:[[UIImage imageNamed:@"Forward-6"]safeStretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
        [nowPlayingContentButton setBackgroundImage:[[UIImage imageNamed:@"Forward-Selected-6"]safeStretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateHighlighted];
        nowPlayingContentButton.showsTouchWhenHighlighted = NO;
        
        nowPlayingLabel.frame = CGRectMake(3, 3, 43, 30);
        nowPlayingLabel.lineHeight = 11;
        nowPlayingLabel.font = [UIFont boldSystemFontOfSize:10];
        nowPlayingLabel.shadowColor = [SkinManager iOS6SkinNowPlayingTextShadowColor];
        nowPlayingLabel.textAlignment = UITextAlignmentCenter;
        nowPlayingLabel.textColor = [UIColor whiteColor];
    }
    else {
        [nowPlayingContentButton setBackgroundImage:[UIImage skinImageNamed:@"Forward"] forState:UIControlStateNormal];
        
        if ([SkinManager iOS7Skin]) {
            nowPlayingContentButton.frame = CGRectMake(0, 0, 74, 30);
            [nowPlayingContentButton setBackgroundImage:[UIImage imageNamed:@"Forward-7"] forState:UIControlStateHighlighted];
            nowPlayingContentButton.showsTouchWhenHighlighted = YES;
            
            nowPlayingLabel.textAlignment = UITextAlignmentRight;
            nowPlayingLabel.textColor = [SkinManager iOS7SkinBlueColor];
        }
        else {
            nowPlayingContentButton.frame = CGRectMake(0, 0, 64, 30);
            [nowPlayingContentButton setBackgroundImage:[UIImage imageNamed:@"Forward-Selected"] forState:UIControlStateHighlighted];
            nowPlayingContentButton.showsTouchWhenHighlighted = NO;
            
            nowPlayingLabel.textAlignment = UITextAlignmentCenter;
            nowPlayingLabel.textColor = [UIColor whiteColor];
        }
        
        nowPlayingLabel.frame = CGRectMake(0, 3, 56, 30);
        nowPlayingLabel.lineHeight = 12;
        nowPlayingLabel.font = [UIFont boldSystemFontOfSize:11];
        nowPlayingLabel.shadowColor = nil;
    }
}

- (void)nowPlayingButtonPressed {
    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
    
    TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
    
    UIViewController *selectedViewController = tabBarController.selectedViewController;
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        // If there is no top view controller, the view controller has been pushed from the moreNavigationController.
        // If the tab bar controller is using the moreNavigationController, the playerViewController must be pushed using that navigation controller instead.
        if (((UINavigationController *)selectedViewController).topViewController) {
            [(UINavigationController *)selectedViewController pushViewController:playerViewController animated:YES];
        }
        else {
            [tabBarController.moreNavigationController pushViewController:playerViewController animated:YES];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
