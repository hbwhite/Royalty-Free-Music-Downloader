//
//  StandardGroupedCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/13/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "StandardGroupedCell.h"
#import "SkinManager.h"

@implementation StandardGroupedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        self.textLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        self.textLabel.highlightedTextColor = [SkinManager iOS6SkinLightGrayColor];
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.textColor = [SkinManager iOS6SkinLightTextColor];
        self.detailTextLabel.highlightedTextColor = self.textLabel.highlightedTextColor;
        self.detailTextLabel.shadowColor = self.textLabel.shadowColor;
        self.detailTextLabel.shadowOffset = self.textLabel.shadowOffset;
        self.detailTextLabel.backgroundColor = self.textLabel.backgroundColor;
        
        self.imageView.alpha = 0.75;
        
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.shadowColor = nil;
        self.textLabel.shadowOffset = CGSizeMake(0, -1);
        self.textLabel.backgroundColor = [UIColor whiteColor];
        
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.detailTextLabel.shadowColor = nil;
        self.detailTextLabel.shadowOffset = CGSizeMake(0, -1);
        self.detailTextLabel.backgroundColor = [UIColor whiteColor];
        
        if ([SkinManager iOS7Skin]) {
            self.textLabel.highlightedTextColor = nil;
            self.detailTextLabel.highlightedTextColor = nil;
        }
        else {
            self.textLabel.highlightedTextColor = [UIColor whiteColor];
            self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        }
        
        self.imageView.alpha = 1;
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
        self.imageView.highlightedImage = self.imageView.image;
    }
}

@end
