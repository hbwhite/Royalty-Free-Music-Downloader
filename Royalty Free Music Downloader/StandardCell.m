//
//  StandardCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/13/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "StandardCell.h"
#import "SkinManager.h"

@interface StandardCell ()

@property (nonatomic, strong) UIView *topSeparatorView;
@property (nonatomic, strong) UIView *bottomSeparatorView;

@end

@implementation StandardCell

// Private
@synthesize topSeparatorView;
@synthesize bottomSeparatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS7Skin]) {
        self.textLabel.highlightedTextColor = nil;
        self.detailTextLabel.highlightedTextColor = nil;
    }
    else {
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        
        // self.textLabel.font = [UIFont boldSystemFontOfSize:18];
        // self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    
    self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    
    // This prevents duplicate separator views from being added to the cell, leaving vestigial separators that are unaccounted for.
    
    if ([SkinManager iOS6Skin]) {
        if (!topSeparatorView) {
            topSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
            topSeparatorView.backgroundColor = [UIColor whiteColor];
            topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self insertSubview:topSeparatorView atIndex:0];
        }
        
        if (!bottomSeparatorView) {
            bottomSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, (self.frame.size.height - 1), self.frame.size.width, 1)];
            bottomSeparatorView.backgroundColor = [SkinManager iOS6SkinSeparatorColor];
            bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:bottomSeparatorView];
        }
        
        self.textLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.textColor = [SkinManager iOS6SkinLightTextColor];
        self.detailTextLabel.shadowColor = self.textLabel.shadowColor;
        self.detailTextLabel.shadowOffset = self.textLabel.shadowOffset;
        self.detailTextLabel.backgroundColor = self.textLabel.backgroundColor;
        
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        if (topSeparatorView) {
            [topSeparatorView removeFromSuperview];
            topSeparatorView = nil;
        }
        if (bottomSeparatorView) {
            [bottomSeparatorView removeFromSuperview];
            bottomSeparatorView = nil;
        }
        
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.shadowColor = nil;
        self.textLabel.shadowOffset = CGSizeMake(0, -1);
        self.textLabel.backgroundColor = [UIColor whiteColor];
        
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.detailTextLabel.shadowColor = nil;
        self.detailTextLabel.shadowOffset = CGSizeMake(0, -1);
        self.detailTextLabel.backgroundColor = [UIColor whiteColor];
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animate {
    if ([SkinManager iOS6Skin]) {
        if (highlighted) {
            self.textLabel.shadowColor = [UIColor clearColor];
        }
        else {
            self.textLabel.shadowColor = [UIColor whiteColor];
        }
        
        self.detailTextLabel.shadowColor = self.textLabel.shadowColor;
    }
    [super setHighlighted:highlighted animated:animate];
}

@end
