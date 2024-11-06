//
//  TextFieldCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 10/1/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import "TextFieldCell.h"
#import "SkinManager.h"

@implementation TextFieldCell

@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		textField = [[UITextField alloc]init];
        textField.frame = CGRectMake(10, 10, (self.contentView.frame.size.width - 20), 23);
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		textField.borderStyle = UITextBorderStyleNone;
		textField.font = [UIFont systemFontOfSize:18];
        textField.minimumFontSize = 12;
        textField.adjustsFontSizeToFitWidth = YES;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		textField.clearButtonMode = UITextFieldViewModeAlways;
        [self.contentView addSubview:textField];
		
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        textField.textColor = [SkinManager iOS6SkinDarkGrayColor];
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            textField.textColor = [UIColor blackColor];
        }
        else {
            textField.textColor = [UIColor colorWithRed:(46.0 / 255.0) green:(65.0 / 255.0) blue:(118.0 / 255.0) alpha:1];
        }
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
