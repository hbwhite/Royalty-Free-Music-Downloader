//
//  DetailCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/19/11.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "DetailCell.h"
#import "SkinManager.h"

@implementation DetailCell

@synthesize detailLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		detailLabel = [[UILabel alloc]init];
        detailLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth);
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.textAlignment = UITextAlignmentRight;        
		[self.contentView addSubview:detailLabel];
		
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
        
        detailLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        detailLabel.highlightedTextColor = [SkinManager iOS6SkinLightGrayColor];
        detailLabel.shadowColor = [UIColor whiteColor];
        detailLabel.shadowOffset = CGSizeMake(0, 1);
        
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.textLabel.shadowColor = nil;
        self.textLabel.shadowOffset = CGSizeMake(0, -1);
        
        if ([SkinManager iOS7Skin]) {
            self.textLabel.highlightedTextColor = self.textLabel.textColor;
            detailLabel.textColor = [SkinManager iOS7SkinBlueColor];
            detailLabel.highlightedTextColor = detailLabel.textColor;
        }
        else {
            self.textLabel.highlightedTextColor = [UIColor whiteColor];
            detailLabel.textColor = [UIColor colorWithRed:(46.0 / 255.0) green:(65.0 / 255.0) blue:(118.0 / 255.0) alpha:1];
            detailLabel.highlightedTextColor = [UIColor whiteColor];
        }
        
        detailLabel.shadowColor = nil;
        detailLabel.shadowOffset = CGSizeMake(0, -1);
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize textSize = [self.textLabel.text sizeWithFont:self.textLabel.font];
    detailLabel.frame = CGRectMake((textSize.width + 20), 0, (self.contentView.frame.size.width - (textSize.width + self.accessoryView.frame.size.width + 30)), 43);
}

@end
