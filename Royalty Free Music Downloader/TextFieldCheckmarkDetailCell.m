//
//  TextFieldCheckmarkDetailCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/24/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "TextFieldCheckmarkDetailCell.h"
#import "SkinManager.h"

@implementation TextFieldCheckmarkDetailCell

@synthesize checkmarkButton;
@synthesize detailLabel;
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        checkmarkButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        checkmarkButton.imageView.contentMode = UIViewContentModeCenter;
        
        if (![SkinManager iOS7Skin]) {
            [checkmarkButton setImage:[UIImage imageNamed:@"Checkmark-Selected"] forState:UIControlStateHighlighted];
        }
        
        [self.contentView addSubview:checkmarkButton];
        
        detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(54, 0, 80, 44)];
        detailLabel.textAlignment = UITextAlignmentRight;
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        detailLabel.font = [UIFont boldSystemFontOfSize:14];
        detailLabel.adjustsFontSizeToFitWidth = YES;
        detailLabel.minimumFontSize = 12;
        [self.contentView addSubview:detailLabel];
        
        textField = [[UITextField alloc]initWithFrame:CGRectMake(144, 0, 176, 44)];
        textField.returnKeyType = UIReturnKeyDone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.backgroundColor = [UIColor clearColor];
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textField.font = [UIFont boldSystemFontOfSize:14];
        textField.adjustsFontSizeToFitWidth = YES;
        textField.minimumFontSize = 12;
        [self.contentView addSubview:textField];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        detailLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        detailLabel.shadowColor = [UIColor whiteColor];
        detailLabel.shadowOffset = CGSizeMake(0, 1);
        
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            detailLabel.textColor = [SkinManager iOS7SkinBlueColor];
        }
        else {
            detailLabel.textColor = [UIColor colorWithRed:(46.0 / 255.0) green:(65.0 / 255.0) blue:(118.0 / 255.0) alpha:1];
        }
        
        detailLabel.shadowColor = nil;
        detailLabel.shadowOffset = CGSizeMake(0, -1);
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setCheckmarkVisible:(BOOL)visible {
    if (visible) {
        [checkmarkButton setImage:[UIImage iOS7SkinImageNamed:@"Checkmark"] forState:UIControlStateNormal];
    }
    else {
        [checkmarkButton setImage:[UIImage iOS7SkinImageNamed:@"Checkmark-Missing"] forState:UIControlStateNormal];
    }
}

@end
