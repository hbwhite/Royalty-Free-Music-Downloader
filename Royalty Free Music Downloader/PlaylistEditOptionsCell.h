//
//  PlaylistEditOptionsCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistEditOptionsCell : UITableViewCell {
@public
    UIButton *editButton;
    UIButton *clearButton;
    UIButton *deleteButton;
    UIButton *doneButton;
@private
    UIView *bottomSeparatorView;
}

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *doneButton;

- (void)configure;
- (void)setEditing:(BOOL)editing;

@end
