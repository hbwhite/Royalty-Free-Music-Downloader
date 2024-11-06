//
//  FilesEditBar.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilesEditBar : UIView {
@public
    UIButton *addFolderButton;
    UIButton *moveButton;
    UIButton *editButton;
    UIButton *multiEditButton;
    
    UIButton *nameButton;
    UIButton *dateButton;
    UIButton *sizeButton;
    UIButton *timeButton;
@private
    UIImageView *nameButtonImageView;
    UIImageView *dateButtonImageView;
    UIImageView *sizeButtonImageView;
    UIImageView *timeButtonImageView;
    
    BOOL nameSelected;
    BOOL dateSelected;
    BOOL sizeSelected;
    BOOL timeSelected;
    BOOL _ascending;
}

@property (nonatomic, strong) UIButton *addFolderButton;
@property (nonatomic, strong) UIButton *moveButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *multiEditButton;

@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *dateButton;
@property (nonatomic, strong) UIButton *sizeButton;
@property (nonatomic, strong) UIButton *timeButton;

- (void)setEditing:(BOOL)editing;
- (void)setNameButtonAscending:(BOOL)ascending;
- (void)setDateButtonAscending:(BOOL)ascending;
- (void)setSizeButtonAscending:(BOOL)ascending;
- (void)setTimeButtonAscending:(BOOL)ascending;

@end
