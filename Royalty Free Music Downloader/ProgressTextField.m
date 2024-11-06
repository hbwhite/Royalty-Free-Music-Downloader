//
//  ProgressTextField.m
//  Browser
//
//  Created by Harrison White on 5/25/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "ProgressTextField.h"
#import "SkinManager.h"
#import "UIImage+SafeStretchableImage.h"

@interface ProgressTextField ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

- (void)updateSkin;

@end

@implementation ProgressTextField

// Public
@synthesize textField;
@synthesize actionButton;

// Private
@synthesize backgroundImageView;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        backgroundImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self addSubview:backgroundImageView];
        
        textField = [[UITextField alloc]initWithFrame:CGRectMake(7, 0, (self.frame.size.width - self.frame.size.height), self.frame.size.height)];
        textField.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:14];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.textAlignment = UITextAlignmentCenter;
        [self addSubview:textField];
        
        actionButton = [[UIButton alloc]initWithFrame:CGRectMake((self.frame.size.width - self.frame.size.height), 0, self.frame.size.height, self.frame.size.height)];
        actionButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight);
        [self addSubview:actionButton];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self updateSkin];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateSkin) name:kSkinDidChangeNotification object:nil];
    }
    return self;
}

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha {
    backgroundImageView.alpha = backgroundAlpha;
    actionButton.alpha = backgroundAlpha;
}

- (void)didBecomeFirstResponder {
    actionButton.hidden = YES;
    textField.frame = CGRectMake(7, 0, (self.frame.size.width - 7), self.frame.size.height);
}

- (void)didResignFirstResponder {
    actionButton.hidden = NO;
    textField.frame = CGRectMake(7, 0, (self.frame.size.width - self.frame.size.height), self.frame.size.height);
}

- (void)updateSkin {
    if ([SkinManager iOS7Skin]) {
        backgroundImageView.image = [[UIImage imageNamed:@"Address_Bar_Background-7"]safeStretchableImageWithLeftCapWidth:6 topCapHeight:14];
    }
    else {
        backgroundImageView.image = [[UIImage skinImageNamed:@"Address_Bar_Background"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:15];
    }
    
    [actionButton setImage:[UIImage skinImageNamed:@"Refresh"] forState:UIControlStateNormal];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
