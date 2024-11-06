//
//  PlaylistEditOptionsCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "PlaylistEditOptionsCell.h"
#import "SkinManager.h"
#import "UIImage+SafeStretchableImage.h"

@interface PlaylistEditOptionsCell ()

@property (nonatomic, strong) UIView *bottomSeparatorView;

@end

@implementation PlaylistEditOptionsCell

// Public
@synthesize editButton;
@synthesize clearButton;
@synthesize deleteButton;
@synthesize doneButton;

// Private
@synthesize bottomSeparatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        editButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, ((self.contentView.frame.size.width - 20) / 3.0), 33)];
        editButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);
        editButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        editButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [editButton setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        [editButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:editButton];
        
        clearButton = [[UIButton alloc]initWithFrame:CGRectMake((((self.contentView.frame.size.width - 20) / 3.0) + 10), 5, ((self.contentView.frame.size.width - 20) / 3.0), 33)];
        clearButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        clearButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [clearButton setTitle:NSLocalizedString(@"CLEAR", @"") forState:UIControlStateNormal];
        [clearButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:clearButton];
        
        deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(((((self.contentView.frame.size.width - 20) / 3.0) * 2) + 15), 5, ((self.contentView.frame.size.width - 20) / 3.0), 33)];
        deleteButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        deleteButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [deleteButton setTitle:NSLocalizedString(@"Delete", @"") forState:UIControlStateNormal];
        [deleteButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:deleteButton];
        
        doneButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 5, (self.contentView.frame.size.width - 100), 33)];
        doneButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        doneButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        doneButton.hidden = YES;
        [doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [doneButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:doneButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        [editButton setTitleColor:[SkinManager iOS6SkinDarkGrayColor] forState:UIControlStateNormal];
        [editButton setTitleColor:[editButton titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
        
        // This prevents duplicate separator views from being added to the cell, leaving vestigial separators that are unaccounted for.
        
        if (!bottomSeparatorView) {
            bottomSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, (self.frame.size.height - 1), self.frame.size.width, 1)];
            bottomSeparatorView.backgroundColor = [SkinManager iOS6SkinSeparatorColor];
            bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.contentView addSubview:bottomSeparatorView];
        }
        
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
        
        if (bottomSeparatorView) {
            [bottomSeparatorView removeFromSuperview];
            bottomSeparatorView = nil;
        }
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    if ([SkinManager iOS7Skin]) {
        editButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [editButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    else {
        editButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [editButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateNormal];
    }
    
    [clearButton setTitleColor:[editButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[editButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [doneButton setTitleColor:[editButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    
    [clearButton setTitleColor:[editButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [deleteButton setTitleColor:[editButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [doneButton setTitleColor:[editButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    
    [clearButton setBackgroundImage:[editButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:[editButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[editButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
}

- (void)setEditing:(BOOL)editing {
    if (editing) {
        editButton.hidden = YES;
        clearButton.hidden = YES;
        deleteButton.hidden = YES;
        doneButton.hidden = NO;
    }
    else {
        editButton.hidden = NO;
        clearButton.hidden = NO;
        deleteButton.hidden = NO;
        doneButton.hidden = YES;
    }
}

@end
