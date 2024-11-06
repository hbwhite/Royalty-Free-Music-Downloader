//
//  TextViewCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/4/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewCell : UITableViewCell {
    UITextView *textView;
}

@property (nonatomic, strong) UITextView *textView;

- (void)configure;

@end
