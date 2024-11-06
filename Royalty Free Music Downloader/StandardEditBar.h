//
//  StandardEditBar.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandardEditBar : UIView {
    UIButton *editButton;
    UIButton *multiEditButton;
}

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *multiEditButton;

@end
