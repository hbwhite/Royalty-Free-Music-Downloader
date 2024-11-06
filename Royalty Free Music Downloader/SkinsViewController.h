//
//  SkinsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoresizingViewController.h"

@interface SkinsViewController : AutoresizingViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
@private
    NSInteger skinIndex;
}

@end