//
//  IconCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "IconCell.h"
#import "SkinManager.h"

@implementation IconCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        self.textLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        self.textLabel.highlightedTextColor = [SkinManager iOS6SkinLightGrayColor];
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        self.imageView.alpha = 0.75;
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        self.textLabel.textColor = [UIColor blackColor];
        
        if ([SkinManager iOS7Skin]) {
            self.textLabel.highlightedTextColor = self.textLabel.textColor;
        }
        else {
            self.textLabel.highlightedTextColor = [UIColor whiteColor];
        }
        
        self.textLabel.shadowColor = nil;
        self.textLabel.shadowOffset = CGSizeMake(0, -1);
        
        self.imageView.alpha = 1;
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, 43, 43);
    self.imageView.contentMode = UIViewContentModeCenter;
    self.textLabel.frame = CGRectMake(50, 0, (self.contentView.frame.size.width - 50), 43);
    
    if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
        self.imageView.highlightedImage = self.imageView.image;
    }
}

@end
