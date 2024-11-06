//
//  SettingsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import "AutoresizingViewController.h"
#import "RemoveAdsNavigationControllerDelegate.h"
#import "LoginNavigationControllerDelegate.h"

@class TTTUnitOfInformationFormatter;

#define kGroupByAlbumArtistPreferenceDidChangeNotification  @"Group By Album Artist Preference Did Change"

@interface SettingsViewController : AutoresizingViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, RemoveAdsNavigationControllerDelegate, LoginNavigationControllerDelegate> {
@private
    TTTUnitOfInformationFormatter *formatter;
    NSNumberFormatter *percentFormatter;
}

@end
