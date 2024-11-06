//
//  PasscodeSettingsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/17/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoresizingViewController.h"
#import "LoginNavigationControllerDelegate.h"

@interface PasscodeSettingsViewController : AutoresizingViewController <UITableViewDataSource, UITableViewDelegate, LoginNavigationControllerDelegate> {
@private
    BOOL disablingPasscode;
}

- (void)switchValueChanged:(id)sender;

@end
