//
//  PasscodeRequirementDelayViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/11/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoresizingViewController.h"

@interface PasscodeRequirementDelayViewController : AutoresizingViewController <UITableViewDataSource, UITableViewDelegate> {
	NSInteger selectedRow;
}

@property (nonatomic) NSInteger selectedRow;

@end
