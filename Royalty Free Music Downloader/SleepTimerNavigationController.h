//
//  SleepTimerNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SleepTimerNavigationControllerDelegate.h"
#import "SleepTimerViewControllerDelegate.h"

@class SleepTimerViewController;

@interface SleepTimerNavigationController : UINavigationController <SleepTimerViewControllerDelegate> {
@public
    id <SleepTimerNavigationControllerDelegate> __unsafe_unretained sleepTimerNavigationControllerDelegate;
@private
    SleepTimerViewController *sleepTimerViewController;
}

@property (nonatomic, unsafe_unretained) id <SleepTimerNavigationControllerDelegate> sleepTimerNavigationControllerDelegate;

@end
