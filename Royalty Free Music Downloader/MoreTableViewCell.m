//
//  MoreTableViewCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "MoreTableViewCell.h"
#import "SkinManager.h"

@implementation MoreTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)configure {
    [super configure];
    
    if ([SkinManager iOS6Skin]) {
        self.imageView.alpha = 0.75;
    }
    else {
        self.imageView.alpha = 1;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, 56, 42);
    self.imageView.contentMode = UIViewContentModeCenter;
    self.textLabel.frame = CGRectMake(57, 0, (self.contentView.frame.size.width - 57), 43);
}

@end
