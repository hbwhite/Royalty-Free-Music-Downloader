//
//  DirectoryCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "DirectoryCell.h"

@implementation DirectoryCell

@synthesize tier;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake((self.imageView.frame.origin.x + (tier * 20)), self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.textLabel.frame = CGRectMake((self.textLabel.frame.origin.x + (tier * 20)), self.textLabel.frame.origin.y, (self.textLabel.frame.size.width - (tier * 20)), self.textLabel.frame.size.height);
}

@end
