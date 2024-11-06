//
//  SwitchCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 10/22/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

@synthesize cellSwitch;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		cellSwitch = [[UISwitch alloc]init];
		self.accessoryView = cellSwitch;
        
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
