//
//  HomepageViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoresizingViewController.h"

enum {
    kHomepageOptionNone = 0,
    kHomepageOptionFAQ,
    kHomepageOptionBlankPage
};
typedef NSUInteger kHomepageOption;

@interface HomepageViewController : AutoresizingViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
@private
    NSString *currentPageTitle;
    NSString *currentPageURL;
    kHomepageOption homepageOption;
}

@end
