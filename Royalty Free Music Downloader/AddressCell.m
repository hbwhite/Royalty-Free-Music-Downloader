//
//  AddressCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/19/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "AddressCell.h"
#import "SkinManager.h"

@implementation AddressCell

@synthesize instructionsLabel;
@synthesize addressLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // A height of 95 is expected.
        instructionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, (self.contentView.frame.size.width - 40), 50)];
        instructionsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        instructionsLabel.font = [UIFont systemFontOfSize:17];
        instructionsLabel.numberOfLines = 0;
        instructionsLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:instructionsLabel];
        
        addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, (self.contentView.frame.size.width - 40), 40)];
        addressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        addressLabel.font = [UIFont boldSystemFontOfSize:17];
        addressLabel.textAlignment = UITextAlignmentCenter;
        addressLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:addressLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        instructionsLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        instructionsLabel.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    addressLabel.textColor = instructionsLabel.textColor;
}

@end
