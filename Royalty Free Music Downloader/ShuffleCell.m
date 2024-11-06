//
//  ShuffleCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 4/8/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "ShuffleCell.h"
#import "SkinManager.h"
#import "UIImage+SkinImage.h"

@interface ShuffleCell ()

@property (nonatomic, strong) UIImageView *shuffleImageView;

@end

@implementation ShuffleCell

@synthesize shuffleImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        shuffleImageView = [[UIImageView alloc]init];
        shuffleImageView.contentMode = UIViewContentModeCenter;
        
        // For some reason, the normal image doesn't display unless it is added directly to the cell's view (not its content view).
        [self addSubview:shuffleImageView];
    }
    return self;
}

- (void)configure {
    [super configure];
    
    shuffleImageView.image = [UIImage skinImageNamed:@"Shuffle"];
    
    if ([SkinManager iOS7Skin]) {
        shuffleImageView.highlightedImage = shuffleImageView.image;
    }
    else {
        shuffleImageView.highlightedImage = [UIImage skinImageNamed:@"Shuffle-Selected"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    shuffleImageView.frame = CGRectMake((self.textLabel.frame.origin.x + [self.textLabel.text sizeWithFont:self.textLabel.font].width + 10), 14, 20, 15);
}

@end
