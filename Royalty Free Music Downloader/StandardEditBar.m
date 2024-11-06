//
//  StandardEditBar.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "StandardEditBar.h"
#import "SkinManager.h"
#import "UIImage+SafeStretchableImage.h"

@interface StandardEditBar ()

- (void)updateSkin;

@end

@implementation StandardEditBar

@synthesize editButton;
@synthesize multiEditButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        editButton = [[UIButton alloc]initWithFrame:CGRectMake(((self.frame.size.width - 300) / 3.0), 5, 150, 33)];
        editButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);
        editButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [editButton setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        [editButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        multiEditButton = [[UIButton alloc]initWithFrame:CGRectMake(((((self.frame.size.width - 300) / 3.0) * 2) + 150), 5, 150, 33)];
        multiEditButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        multiEditButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [multiEditButton setTitle:[@"Multi " stringByAppendingString:NSLocalizedString(@"Edit", @"")] forState:UIControlStateNormal];
        [multiEditButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self addSubview:editButton];
        [self addSubview:multiEditButton];
        
        UIView *separatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 43, self.frame.size.width, 1)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        separatorView.backgroundColor = [UIColor colorWithWhite:(217.0 / 255.0) alpha:1];
        [self addSubview:separatorView];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self updateSkin];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateSkin) name:kSkinDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateSkin {
    if ([SkinManager iOS6Skin]) {
        [editButton setTitleColor:[SkinManager iOS6SkinDarkGrayColor] forState:UIControlStateNormal];
        [editButton setTitleColor:[editButton titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            [editButton setTitleColor:[SkinManager iOS7SkinBlueColor] forState:UIControlStateNormal];
            [editButton setTitleColor:[SkinManager iOS7SkinHighlightedBlueColor] forState:UIControlStateHighlighted];
        }
        else {
            [editButton setTitleColor:[UIColor colorWithWhite:(38.0 / 255.0) alpha:1] forState:UIControlStateNormal];
            [editButton setTitleColor:[editButton titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
        }
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    [multiEditButton setTitleColor:[editButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [multiEditButton setTitleColor:[editButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    
    if ([SkinManager iOS7Skin]) {
        editButton.titleLabel.font = [UIFont systemFontOfSize:17];
        multiEditButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        [editButton setBackgroundImage:nil forState:UIControlStateNormal];
        [editButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    }
    else {
        editButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        multiEditButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        
        [editButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateNormal];
        [editButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button-Selected"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateHighlighted];
    }
    
    [multiEditButton setBackgroundImage:[editButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [multiEditButton setBackgroundImage:[editButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
