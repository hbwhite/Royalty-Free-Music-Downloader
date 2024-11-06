//
//  TextFieldCheckmarkDetailCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/24/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldCheckmarkDetailCell : UITableViewCell {
    UIButton *checkmarkButton;
    UILabel *detailLabel;
    UITextField *textField;
}

@property (nonatomic, strong) UIButton *checkmarkButton;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UITextField *textField;

- (void)configure;
- (void)setCheckmarkVisible:(BOOL)visible;

@end
