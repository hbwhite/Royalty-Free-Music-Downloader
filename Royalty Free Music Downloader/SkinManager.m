//
//  SkinManager.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/8/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "SkinManager.h"
#import "AutoresizingViewController.h"
#import "TextInputViewController.h"
#import "TagEditorViewController.h"
#import "MultipleTagEditorViewController.h"
#import "EditBookmarkViewController.h"
#import "EditBookmarkFolderViewController.h"
#import "LoginViewController.h"
#import "RemoveAdsViewController.h"
#import "UIImage+SafeStretchableImage.h"

#define DEFAULT_SKIN_INDEX          0
#define IOS_6_SKIN_INDEX            1

// For whatever reason, you must loop through the desired classes instead of passing all of them at once to -appearanceWhenContainedIn:.
#define GROUPED_TABLE_VIEW_CLASSES  [NSArray arrayWithObjects:[AutoresizingViewController class], [TagEditorViewController class], [MultipleTagEditorViewController class], [TextInputViewController class], [EditBookmarkViewController class], [EditBookmarkFolderViewController class], [LoginViewController class], [RemoveAdsViewController class], nil]

static NSString *kSkinIndexKey      = @"Skin Index";

@interface SkinManager ()

+ (void)_applySkinWithIndex:(NSInteger)index;

@end

@implementation SkinManager

+ (NSInteger)skinIndex {
    return [[NSUserDefaults standardUserDefaults]integerForKey:kSkinIndexKey];
}

+ (BOOL)iOS6Skin {
    // Most of the appearance functions used by the iOS 6 skin are only available in iOS 5.0 or later, so the iOS 6 skin is disallowed on firmwares prior to iOS 5.0.
    // The system version is checked in case the NSUserDefaults of a device on a newer firmware are synced to a device with an older firmware.
    return (([self skinIndex] == IOS_6_SKIN_INDEX) && ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending));
}

+ (BOOL)iOS7 {
    return ([[[UIDevice currentDevice]systemVersion]compare:@"7.0"] != NSOrderedAscending);
}

+ (BOOL)iOS7Skin {
    return (([self skinIndex] == DEFAULT_SKIN_INDEX) && ([self iOS7]));
}

+ (UIColor *)defaultSkinTableViewSectionFooterTextColor {
    return [UIColor colorWithRed:(76.0 / 255.0) green:(86.0 / 255.0) blue:(108.0 / 255.0) alpha:1];
}

+ (UIColor *)defaultSkinSearchBarPlaceholderTextColor {
    return [UIColor colorWithWhite:(179.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS6SkinDarkGrayColor {
    return [UIColor colorWithWhite:(71.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS6SkinLightGrayColor {
    return [UIColor colorWithRed:(116.0 / 255.0) green:(117.0 / 255.0) blue:(118.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS6SkinLightTextColor {
    return [UIColor colorWithWhite:(137.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS6SkinTableViewBackgroundColor {
    return [UIColor colorWithRed:(233.0 / 255.0) green:(234.0 / 255.0) blue:(236.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS6SkinTableViewSectionHeaderTextColor {
    return [UIColor colorWithWhite:(89.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS6SkinTableViewSectionHeaderShadowColor {
    return [UIColor colorWithRed:(224.0 / 255.0) green:(224.0 / 255.0) blue:(225.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS6SkinTableViewSectionIndexTrackingBackgroundColor {
    // iOS6SkinLightGrayColor with reduced alpha
    return [UIColor colorWithRed:(116.0 / 255.0) green:(117.0 / 255.0) blue:(118.0 / 255.0) alpha:0.7];
}

+ (UIColor *)iOS6SkinNowPlayingTextShadowColor {
    return [UIColor colorWithRed:(46.0 / 255.0) green:(45.0 / 255.0) blue:(46.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS6SkinSeparatorColor {
    return [UIColor colorWithWhite:(189.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS7SkinBlueColor {
    return [UIColor colorWithRed:0 green:(122.0 / 255.0) blue:1 alpha:1];
}

+ (UIColor *)iOS7SkinHighlightedBlueColor {
    return [UIColor colorWithRed:0 green:(122.0 / 255.0) blue:1 alpha:0.3];
}

+ (UIColor *)iOS7SkinTableViewSectionFooterTextColor {
    return [UIColor colorWithRed:(109.0 / 255.0) green:(109.0 / 255.0) blue:(114.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS7SkinSearchBarPlaceholderTextColor {
    return [UIColor colorWithRed:(142.0 / 255.0) green:(142.0 / 255.0) blue:(147.0 / 255.0) alpha:1];
}

+ (UIColor *)iOS7SkinTableViewBackgroundColor {
    return [UIColor colorWithRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(244.0 / 255.0) alpha:1];
}

+ (void)applySkinIfApplicable {
    if ([UITableViewCell respondsToSelector:@selector(appearance)]) {
        // Universal setting
        for (int i = 0; i < [GROUPED_TABLE_VIEW_CLASSES count]; i++) {
            [[UITableViewCell appearanceWhenContainedIn:[GROUPED_TABLE_VIEW_CLASSES objectAtIndex:i], nil]setSelectedBackgroundView:nil];
        }
    }
    
    if (([self iOS6Skin]) || ([self iOS7Skin])) {
        [self _applySkinWithIndex:[self skinIndex]];
    }
}

+ (void)applySkinWithIndex:(NSInteger)index {
    // Separating these functions prevents the app from unnecessarily posting the kSkinDidChangeNotification when it is first launched.
    [self _applySkinWithIndex:index];
    [[NSNotificationCenter defaultCenter]postNotificationName:kSkinDidChangeNotification object:nil];
}

+ (void)_applySkinWithIndex:(NSInteger)index {
    if (index == IOS_6_SKIN_INDEX) {
        if (![self iOS7]) {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        }
        
        NSDictionary *universalTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[SkinManager iOS6SkinDarkGrayColor], UITextAttributeTextColor, [UIColor whiteColor], UITextAttributeTextShadowColor, [NSValue valueWithCGSize:CGSizeMake(0, 1)], UITextAttributeTextShadowOffset, nil];
        
        if ([UINavigationBar respondsToSelector:@selector(appearance)]) {
            id appearance = [UINavigationBar appearance];
            
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Navigation_Bar_Background-6"]safeStretchableImageWithLeftCapWidth:0 topCapHeight:22] forBarMetrics:UIBarMetricsDefault];
            [appearance setTitleTextAttributes:universalTitleTextAttributes];
            
            if ([appearance respondsToSelector:@selector(setBarTintColor:)]) {
                [appearance setBarTintColor:[UIColor whiteColor]];
            }
            
            if ([appearance respondsToSelector:@selector(setShadowImage:)]) {
                [appearance setShadowImage:[UIImage imageNamed:@"Navigation_Bar_Shadow-6"]];
            }
            
            // iOS 7 appearance fix.
            if ([appearance respondsToSelector:@selector(setBackIndicatorImage:)]) {
                [appearance setBackIndicatorImage:[UIImage imageNamed:@"Transparency"]];
            }
            if ([appearance respondsToSelector:@selector(setBackIndicatorTransitionMaskImage:)]) {
                [appearance setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"Transparency"]];
            }
        }
        if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
            id appearance = [UIBarButtonItem appearance];
            [appearance setTintColor:[SkinManager iOS6SkinDarkGrayColor]];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Bar_Button_Item-6"]safeStretchableImageWithLeftCapWidth:6 topCapHeight:30] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Bar_Button_Item-6"]safeStretchableImageWithLeftCapWidth:6 topCapHeight:30] forState:UIControlStateNormal barMetrics:UIBarMetricsDefaultPrompt];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Bar_Button_Item-Landscape-6"]safeStretchableImageWithLeftCapWidth:4 topCapHeight:10] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Bar_Button_Item-Landscape-6"]safeStretchableImageWithLeftCapWidth:4 topCapHeight:10] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhonePrompt];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Bar_Button_Item-Selected-6"]safeStretchableImageWithLeftCapWidth:5 topCapHeight:30] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Bar_Button_Item-Selected-6"]safeStretchableImageWithLeftCapWidth:5 topCapHeight:30] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefaultPrompt];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Bar_Button_Item-Landscape-Selected-6"]safeStretchableImageWithLeftCapWidth:3 topCapHeight:10] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Bar_Button_Item-Landscape-Selected-6"]safeStretchableImageWithLeftCapWidth:3 topCapHeight:10] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhonePrompt];
            [appearance setBackButtonBackgroundImage:[[UIImage imageNamed:@"Navigation_Bar_Back_Button-6"]safeStretchableImageWithLeftCapWidth:15 topCapHeight:30] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [appearance setBackButtonBackgroundImage:[[UIImage imageNamed:@"Navigation_Bar_Back_Button-Selected-6"]safeStretchableImageWithLeftCapWidth:14 topCapHeight:30] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            
            NSMutableDictionary *customAttributes = [NSMutableDictionary dictionaryWithDictionary:universalTitleTextAttributes];
            [customAttributes setValuesForKeysWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:12], UITextAttributeFont, nil]];
            
            [appearance setTitleTextAttributes:customAttributes forState:UIControlStateNormal];
            [appearance setTitleTextAttributes:customAttributes forState:UIControlStateHighlighted];
            
            NSDictionary *disabledTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[SkinManager iOS6SkinLightGrayColor], UITextAttributeTextColor, [UIColor whiteColor], UITextAttributeTextShadowColor, [NSValue valueWithCGSize:CGSizeMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont boldSystemFontOfSize:12], UITextAttributeFont, nil];
            [appearance setTitleTextAttributes:disabledTitleTextAttributes forState:UIControlStateDisabled];
        }
        if ([UISearchBar respondsToSelector:@selector(appearance)]) {
            id appearance = [UISearchBar appearance];
            [appearance setBackgroundImage:[UIImage imageNamed:@"Search_Bar_Background-6"]];
            [appearance setSearchFieldBackgroundImage:[[UIImage imageNamed:@"Search_Field_Background-6"]safeStretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
            [appearance setImage:[UIImage imageNamed:@"Search-6"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
            [appearance setImage:[UIImage imageNamed:@"Search_Clear-6"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
        }
        if ([UILabel respondsToSelector:@selector(appearanceWhenContainedIn:)]) {
            [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil]setTextColor:[SkinManager iOS6SkinLightGrayColor]];
            
            for (int i = 0; i < [GROUPED_TABLE_VIEW_CLASSES count]; i++) {
                [[UILabel appearanceWhenContainedIn:[GROUPED_TABLE_VIEW_CLASSES objectAtIndex:i], nil]setTextColor:[SkinManager iOS6SkinDarkGrayColor]];
            }
        }
        if ([UITableViewCell respondsToSelector:@selector(appearance)]) {
            UIImageView *plainSelectedBackgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, 43)];
            plainSelectedBackgroundView.image = [UIImage imageNamed:@"Table_View_Cell_Background_Light-Selected"];
            
            id plainAppearance = [UITableViewCell appearance];
            [plainAppearance setSelectedBackgroundView:plainSelectedBackgroundView];
            [plainAppearance setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            for (int i = 0; i < [GROUPED_TABLE_VIEW_CLASSES count]; i++) {
                id groupedAppearance = [UITableViewCell appearanceWhenContainedIn:[GROUPED_TABLE_VIEW_CLASSES objectAtIndex:i], nil];
                [groupedAppearance setSelectionStyle:UITableViewCellSelectionStyleGray];
            }
        }
        if ([UIToolbar respondsToSelector:@selector(appearance)]) {
            id appearance = [UIToolbar appearance];
            [appearance setBackgroundImage:[UIImage imageNamed:@"Navigation_Bar_Background-6"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            
            if ([appearance respondsToSelector:@selector(setShadowImage:forToolbarPosition:)]) {
                [appearance setShadowImage:[UIImage imageNamed:@"Navigation_Bar_Shadow-6"] forToolbarPosition:UIToolbarPositionAny];
            }
        }
        if ([UITabBar respondsToSelector:@selector(appearance)]) {
            id appearance = [UITabBar appearance];
            [appearance setBackgroundImage:[[UIImage imageNamed:@"Tab_Bar_Background-6"]safeStretchableImageWithLeftCapWidth:160 topCapHeight:24]];
            [appearance setSelectionIndicatorImage:[UIImage imageNamed:@"Tab-Selected-6"]];
            
            if ([appearance respondsToSelector:@selector(setBarTintColor:)]) {
                [appearance setBarTintColor:[UIColor whiteColor]];
            }
            
            // Slightly ghetto but it works.
            if ([UITabBar instancesRespondToSelector:@selector(setTintColor:)]) {
                // Darkest Color
                // [appearance setTintColor:[UIColor colorWithWhite:(68.0 / 255.0) alpha:1]];
                
                // Mid-Range Color
                [appearance setTintColor:[UIColor colorWithRed:(113.0 / 255.0) green:(114.0 / 255.0) blue:(113.0 / 255.0) alpha:1]];
            }
            
            if ([appearance respondsToSelector:@selector(setShadowImage:)]) {
                [appearance setShadowImage:[UIImage imageNamed:@"Tab_Bar_Shadow-6"]];
            }
        }
        if ([UITabBarItem respondsToSelector:@selector(appearance)]) {
            [[UITabBarItem appearance]setTitleTextAttributes:universalTitleTextAttributes forState:UIControlStateNormal];
        }
        if ([UISwitch respondsToSelector:@selector(appearance)]) {
            [[UISwitch appearance]setOnTintColor:[SkinManager iOS6SkinLightGrayColor]];
        }
    }
    else {
        // A blank NSDictionary must be passed instead of nil to prevent the title color from automatically being set to gray on devices running iOS 5.1.1 (and possibly others).
        // For safety, this is passed everywhere nil would be passed for a text attribute NSDictionary.
        NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:nil];
        
        if (![self iOS7]) {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        }
        
        if ([UINavigationBar respondsToSelector:@selector(appearance)]) {
            id appearance = [UINavigationBar appearance];
            
            [appearance setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            [appearance setTitleTextAttributes:titleTextAttributes];
            
            if ([appearance respondsToSelector:@selector(setBarTintColor:)]) {
                [appearance setBarTintColor:nil];
            }
            
            if ([appearance respondsToSelector:@selector(setShadowImage:)]) {
                [appearance setShadowImage:nil];
            }
            
            // iOS 7 appearance fix.
            if ([appearance respondsToSelector:@selector(setBackIndicatorImage:)]) {
                [appearance setBackIndicatorImage:nil];
            }
            if ([appearance respondsToSelector:@selector(setBackIndicatorTransitionMaskImage:)]) {
                [appearance setBackIndicatorTransitionMaskImage:nil];
            }
        }
        if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
            // iOS 7 does not respond properly when nil is passed as the background image, so a transparent image must be used instead.
            UIImage *barButtonItemBackgroundImage = nil;
            if ([self iOS7]) {
                barButtonItemBackgroundImage = [UIImage imageNamed:@"Transparency"];
            }
            
            id appearance = [UIBarButtonItem appearance];
            
            // This will restore the default tint color.
            [appearance setTintColor:nil];
            
            [appearance setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [appearance setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefaultPrompt];
            [appearance setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [appearance setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhonePrompt];
            [appearance setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [appearance setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefaultPrompt];
            [appearance setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            [appearance setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhonePrompt];
            
            [appearance setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [appearance setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            
            [appearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
            [appearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateHighlighted];
            [appearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateDisabled];
        }
        if ([UISearchBar respondsToSelector:@selector(appearance)]) {
            UIImage *searchFieldBackgroundImage = nil;
            if ([self iOS7]) {
                searchFieldBackgroundImage = [[UIImage imageNamed:@"Search_Field_Background-7"]safeStretchableImageWithLeftCapWidth:6 topCapHeight:14];
            }
            
            id appearance = [UISearchBar appearance];
            [appearance setBackgroundImage:nil];
            [appearance setSearchFieldBackgroundImage:searchFieldBackgroundImage forState:UIControlStateNormal];
            [appearance setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
            [appearance setImage:nil forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
        }
        if ([UILabel respondsToSelector:@selector(appearanceWhenContainedIn:)]) {
            UIColor *searchBarPlaceholderTextColor = nil;
            UIColor *sectionFooterTextColor = nil;
            
            if ([self iOS7]) {
                searchBarPlaceholderTextColor = [self iOS7SkinSearchBarPlaceholderTextColor];
                sectionFooterTextColor = [self iOS7SkinTableViewSectionFooterTextColor];
            }
            else {
                searchBarPlaceholderTextColor = [self defaultSkinSearchBarPlaceholderTextColor];
                sectionFooterTextColor = [self defaultSkinTableViewSectionFooterTextColor];
            }
            
            [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil]setTextColor:searchBarPlaceholderTextColor];
            
            for (int i = 0; i < [GROUPED_TABLE_VIEW_CLASSES count]; i++) {
                [[UILabel appearanceWhenContainedIn:[GROUPED_TABLE_VIEW_CLASSES objectAtIndex:i], nil]setTextColor:sectionFooterTextColor];
            }
        }
        if ([UITableViewCell respondsToSelector:@selector(appearance)]) {
            id plainAppearance = [UITableViewCell appearance];
            [plainAppearance setSelectedBackgroundView:nil];
            [plainAppearance setSelectionStyle:UITableViewCellSelectionStyleBlue];
            
            for (int i = 0; i < [GROUPED_TABLE_VIEW_CLASSES count]; i++) {
                id groupedAppearance = [UITableViewCell appearanceWhenContainedIn:[GROUPED_TABLE_VIEW_CLASSES objectAtIndex:i], nil];
                [groupedAppearance setSelectionStyle:UITableViewCellSelectionStyleBlue];
            }
        }
        if ([UIToolbar respondsToSelector:@selector(appearance)]) {
            id appearance = [UIToolbar appearance];
            [appearance setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            
            if ([appearance respondsToSelector:@selector(setShadowImage:forToolbarPosition:)]) {
                [appearance setShadowImage:nil forToolbarPosition:UIToolbarPositionAny];
            }
        }
        if ([UITabBar respondsToSelector:@selector(appearance)]) {
            id appearance = [UITabBar appearance];
            [appearance setBackgroundImage:nil];
            [appearance setSelectionIndicatorImage:nil];
            
            if ([appearance respondsToSelector:@selector(setBarTintColor:)]) {
                [appearance setBarTintColor:nil];
            }
            
            // Slightly ghetto but it works.
            if ([UITabBar instancesRespondToSelector:@selector(setTintColor:)]) {
                [appearance setTintColor:nil];
            }
            
            if ([appearance respondsToSelector:@selector(setShadowImage:)]) {
                [appearance setShadowImage:nil];
            }
        }
        if ([UITabBarItem respondsToSelector:@selector(appearance)]) {
            [[UITabBarItem appearance]setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
        }
        if ([UISwitch respondsToSelector:@selector(appearance)]) {
            if ([self iOS7]) {
                 [[UISwitch appearance]setOnTintColor:[self iOS7SkinBlueColor]];
            }
            else {
                [[UISwitch appearance]setOnTintColor:nil];
            }
        }
    }
}

@end
