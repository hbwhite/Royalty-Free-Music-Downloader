//
//  FilesEditBar.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "FilesEditBar.h"
#import "MSLabel.h"
#import "SkinManager.h"
#import "UIImage+SafeStretchableImage.h"

@interface FilesEditBar ()

@property (nonatomic, strong) UIImageView *nameButtonImageView;
@property (nonatomic, strong) UIImageView *dateButtonImageView;
@property (nonatomic, strong) UIImageView *sizeButtonImageView;
@property (nonatomic, strong) UIImageView *timeButtonImageView;

@property (readwrite) BOOL nameSelected;
@property (readwrite) BOOL dateSelected;
@property (readwrite) BOOL sizeSelected;
@property (readwrite) BOOL timeSelected;
@property (readwrite) BOOL ascending;

- (void)updateSkin;
- (void)setStandardButtonTitles;
- (void)updateArrowImages;

@end

@implementation FilesEditBar

// Public
@synthesize addFolderButton;
@synthesize moveButton;
@synthesize editButton;
@synthesize multiEditButton;

@synthesize nameButton;
@synthesize dateButton;
@synthesize sizeButton;
@synthesize timeButton;

// Private
@synthesize nameButtonImageView;
@synthesize dateButtonImageView;
@synthesize sizeButtonImageView;
@synthesize timeButtonImageView;

@synthesize nameSelected;
@synthesize dateSelected;
@synthesize sizeSelected;
@synthesize timeSelected;
@synthesize ascending = _ascending;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        addFolderButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, ((self.frame.size.width - 25) * 0.25), 33)];
        addFolderButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);
        addFolderButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        addFolderButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        addFolderButton.titleLabel.minimumFontSize = 9;
        [addFolderButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:addFolderButton];
        
        moveButton = [[UIButton alloc]initWithFrame:CGRectMake((((self.frame.size.width - 25) * 0.25) + 10), 5, ((self.frame.size.width - 25) * 0.25), 33)];
        moveButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        moveButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [moveButton setTitle:@"Move" forState:UIControlStateNormal];
        [moveButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:moveButton];
        
        editButton = [[UIButton alloc]initWithFrame:CGRectMake((((self.frame.size.width - 25) * 0.5) + 15), 5, ((self.frame.size.width - 25) * 0.25), 33)];
        editButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        editButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [editButton setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        [editButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:editButton];
        
        multiEditButton = [[UIButton alloc]initWithFrame:CGRectMake((((self.frame.size.width - 25) * 0.75) + 20), 5, ((self.frame.size.width - 25) * 0.25), 33)];
        multiEditButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        multiEditButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        multiEditButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        multiEditButton.titleLabel.minimumFontSize = 9;
        // Spaces are used here to automatically create left and right margins for the button label.
        [multiEditButton setTitle:[NSString stringWithFormat:@" Multi %@ ", NSLocalizedString(@"Edit", @"")] forState:UIControlStateNormal];
        [multiEditButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:multiEditButton];
        
        nameButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, ((self.frame.size.width - 25) * 0.25), 33)];
        nameButton.hidden = YES;
        nameButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);
        nameButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [nameButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        nameButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(6, 11, 11, 10)];
        [nameButton addSubview:nameButtonImageView];
        
        [self addSubview:nameButton];
        
        dateButton = [[UIButton alloc]initWithFrame:CGRectMake((((self.frame.size.width - 25) * 0.25) + 10), 5, ((self.frame.size.width - 25) * 0.25), 33)];
        dateButton.hidden = YES;
        dateButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        dateButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [dateButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        dateButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(6, 11, 11, 10)];
        [dateButton addSubview:dateButtonImageView];
        
        [self addSubview:dateButton];
        
        sizeButton = [[UIButton alloc]initWithFrame:CGRectMake((((self.frame.size.width - 25) * 0.5) + 15), 5, ((self.frame.size.width - 25) * 0.25), 33)];
        sizeButton.hidden = YES;
        sizeButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        sizeButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [sizeButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        sizeButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(6, 11, 11, 10)];
        [sizeButton addSubview:sizeButtonImageView];
        
        [self addSubview:sizeButton];
        
        timeButton = [[UIButton alloc]initWithFrame:CGRectMake((((self.frame.size.width - 25) * 0.75) + 20), 5, ((self.frame.size.width - 25) * 0.25), 33)];
        timeButton.hidden = YES;
        timeButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        timeButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [timeButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        timeButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(6, 11, 11, 10)];
        [timeButton addSubview:timeButtonImageView];
        
        [self addSubview:timeButton];
        
        [self setStandardButtonTitles];
        
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
        [addFolderButton setTitleColor:[SkinManager iOS6SkinDarkGrayColor] forState:UIControlStateNormal];
        [addFolderButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            [addFolderButton setTitleColor:[SkinManager iOS7SkinBlueColor] forState:UIControlStateNormal];
            [addFolderButton setTitleColor:[SkinManager iOS7SkinHighlightedBlueColor] forState:UIControlStateHighlighted];
        }
        else {
            [addFolderButton setTitleColor:[UIColor colorWithWhite:(38.0 / 255.0) alpha:1] forState:UIControlStateNormal];
            [addFolderButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
        }
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    [moveButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [editButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [multiEditButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [nameButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [dateButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [sizeButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [timeButton setTitleColor:[addFolderButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    
    [moveButton setTitleColor:[addFolderButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [editButton setTitleColor:[addFolderButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [multiEditButton setTitleColor:[addFolderButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [nameButton setTitleColor:[addFolderButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [dateButton setTitleColor:[addFolderButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [sizeButton setTitleColor:[addFolderButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [timeButton setTitleColor:[addFolderButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    
    if ([SkinManager iOS7Skin]) {
        addFolderButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        [addFolderButton setBackgroundImage:nil forState:UIControlStateNormal];
        [addFolderButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    }
    else {
        addFolderButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        
        [addFolderButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateNormal];
        [addFolderButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button-Selected"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateHighlighted];
    }
    
    if ([SkinManager iOS7]) {
        [addFolderButton setTitle:@"Add Folder" forState:UIControlStateNormal];
    }
    else {
        // Spaces are used here to automatically create left and right margins for the button label.
        [addFolderButton setTitle:@" Add Folder " forState:UIControlStateNormal];
    }
    
    [moveButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [editButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [multiEditButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [nameButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [dateButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [sizeButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [timeButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    
    moveButton.titleLabel.font = addFolderButton.titleLabel.font;
    editButton.titleLabel.font = addFolderButton.titleLabel.font;
    multiEditButton.titleLabel.font = addFolderButton.titleLabel.font;
    nameButton.titleLabel.font = addFolderButton.titleLabel.font;
    dateButton.titleLabel.font = addFolderButton.titleLabel.font;
    sizeButton.titleLabel.font = addFolderButton.titleLabel.font;
    timeButton.titleLabel.font = addFolderButton.titleLabel.font;
    
    [moveButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [editButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [multiEditButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [nameButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [dateButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [sizeButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [timeButton setBackgroundImage:[addFolderButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    
    [self updateArrowImages];
}

- (void)setStandardButtonTitles {
    [nameButton setTitle:@"Name" forState:UIControlStateNormal];
    nameButtonImageView.image = nil;
    nameSelected = NO;
    
    [dateButton setTitle:@"Date" forState:UIControlStateNormal];
    dateButtonImageView.image = nil;
    dateSelected = NO;
    
    [sizeButton setTitle:@"Size" forState:UIControlStateNormal];
    sizeButtonImageView.image = nil;
    sizeSelected = NO;
    
    [timeButton setTitle:@"Time" forState:UIControlStateNormal];
    timeButtonImageView.image = nil;
    timeSelected = NO;
}

- (void)setEditing:(BOOL)editing {
    if (editing) {
        addFolderButton.hidden = YES;
        moveButton.hidden = YES;
        editButton.hidden = YES;
        multiEditButton.hidden = YES;
        
        nameButton.hidden = NO;
        dateButton.hidden = NO;
        sizeButton.hidden = NO;
        timeButton.hidden = NO;
    }
    else {
        addFolderButton.hidden = NO;
        moveButton.hidden = NO;
        editButton.hidden = NO;
        multiEditButton.hidden = NO;
        
        nameButton.hidden = YES;
        dateButton.hidden = YES;
        sizeButton.hidden = YES;
        timeButton.hidden = YES;
    }
}

- (void)setNameButtonAscending:(BOOL)ascending {
    [self setStandardButtonTitles];
    
    [nameButton setTitle:@"    Name" forState:UIControlStateNormal];
    
    nameSelected = YES;
    self.ascending = ascending;
    [self updateArrowImages];
}

- (void)setDateButtonAscending:(BOOL)ascending {
    [self setStandardButtonTitles];
    
    [dateButton setTitle:@"    Date" forState:UIControlStateNormal];
    
    dateSelected = YES;
    self.ascending = ascending;
    [self updateArrowImages];
}

- (void)setSizeButtonAscending:(BOOL)ascending {
    [self setStandardButtonTitles];
    
    [sizeButton setTitle:@"    Size" forState:UIControlStateNormal];
    
    sizeSelected = YES;
    self.ascending = ascending;
    [self updateArrowImages];
}

- (void)setTimeButtonAscending:(BOOL)ascending {
    [self setStandardButtonTitles];
    
    [timeButton setTitle:@"    Time" forState:UIControlStateNormal];
    
    timeSelected = YES;
    self.ascending = ascending;
    [self updateArrowImages];
}

- (void)updateArrowImages {
    UIImage *arrowImage = nil;
    if (self.ascending) {
        arrowImage = [UIImage skinImageNamed:@"Ascending"];
    }
    else {
        arrowImage = [UIImage skinImageNamed:@"Descending"];
    }
    
    if (nameSelected) {
        nameButtonImageView.image = arrowImage;
    }
    else if (dateSelected) {
        dateButtonImageView.image = arrowImage;
    }
    else if (sizeSelected) {
        sizeButtonImageView.image = arrowImage;
    }
    else if (timeSelected) {
        timeButtonImageView.image = arrowImage;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
