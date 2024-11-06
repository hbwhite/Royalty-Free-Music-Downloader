//
//  UpdateLibraryCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/19/11.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "UpdateLibraryCell.h"
#import "SkinManager.h"

@interface UpdateLibraryCell ()

@property (nonatomic, strong) UIImageView *updateImageView;

@end

@implementation UpdateLibraryCell

// Private
@synthesize updateImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		updateImageView = [[UIImageView alloc]init];
        updateImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:updateImageView];
		
        self.textLabel.textAlignment = UITextAlignmentCenter;
		self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        self.textLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        self.textLabel.highlightedTextColor = [SkinManager iOS6SkinLightGrayColor];
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        updateImageView.alpha = 0.75;
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.shadowColor = nil;
        self.textLabel.shadowOffset = CGSizeMake(0, -1);
        
        if ([SkinManager iOS7Skin]) {
            self.textLabel.highlightedTextColor = self.textLabel.textColor;
        }
        else {
            self.textLabel.highlightedTextColor = [UIColor whiteColor];
        }
        
        updateImageView.alpha = 1;
        self.backgroundColor = [UIColor whiteColor];
    }
    
    updateImageView.image = [UIImage iOS7SkinImageNamed:@"Update"];
    
    if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
        updateImageView.highlightedImage = updateImageView.image;
    }
    else {
        updateImageView.highlightedImage = [UIImage imageNamed:@"Update-Selected"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    updateImageView.frame = CGRectMake(0, 0, 43, 43);
    updateImageView.contentMode = UIViewContentModeCenter;
}

@end
