//
//  TextFieldDetailCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/24/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldDetailCell : UITableViewCell {
    UILabel *detailLabel;
    UITextField *textField;
}

@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UITextField *textField;

- (void)configure;

@end
