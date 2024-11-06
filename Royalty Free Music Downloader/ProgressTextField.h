//
//  ProgressTextField.h
//  Browser
//
//  Created by Harrison White on 5/25/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressTextField : UIView {
@public
    UITextField *textField;
    UIButton *actionButton;
@private
    UIImageView *backgroundImageView;
}

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *actionButton;

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha;
- (void)didBecomeFirstResponder;
- (void)didResignFirstResponder;

@end
