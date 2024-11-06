//
//  BookmarkFolderCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/13/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "BookmarkFolderCell.h"
#import "SkinManager.h"

@implementation BookmarkFolderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.textLabel.font = [UIFont systemFontOfSize:17];
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
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            self.textLabel.textColor = [SkinManager iOS7SkinBlueColor];
            self.textLabel.highlightedTextColor = self.textLabel.textColor;
        }
        else {
            self.textLabel.textColor = [UIColor colorWithRed:(46.0 / 255.0) green:(65.0 / 255.0) blue:(118.0 / 255.0) alpha:1];
            self.textLabel.highlightedTextColor = [UIColor whiteColor];
        }
        
        self.textLabel.shadowColor = nil;
        self.textLabel.shadowOffset = CGSizeMake(0, -1);
        self.textLabel.backgroundColor = [UIColor whiteColor];
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
