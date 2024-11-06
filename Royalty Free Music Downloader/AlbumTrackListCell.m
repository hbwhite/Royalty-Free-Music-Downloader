//
//  AlbumTrackListCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/2/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "AlbumTrackListCell.h"
#import "SkinManager.h"

@interface AlbumTrackListCell ()

@property (nonatomic, strong) UIView *leftTitleSeparatorView;
@property (nonatomic, strong) UIView *rightTitleSeparatorView;

@end

@implementation AlbumTrackListCell

// Public
@synthesize trackNumberLabel;
@synthesize nowPlayingImageView;
@synthesize titleLabel;
@synthesize durationLabel;

// Private
@synthesize leftTitleSeparatorView;
@synthesize rightTitleSeparatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIColor *separatorViewColor = [UIColor colorWithRed:0.986 green:0.933 blue:0.994 alpha:0.13];
        
        trackNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 31, 44)];
        trackNumberLabel.textColor = [UIColor whiteColor];
        trackNumberLabel.backgroundColor = [UIColor clearColor];
        trackNumberLabel.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:trackNumberLabel];
        
        nowPlayingImageView = [[UIImageView alloc]initWithFrame:CGRectMake(36, 0, 10, 44)];
        nowPlayingImageView.hidden = YES;
        nowPlayingImageView.backgroundColor = [UIColor clearColor];
        nowPlayingImageView.contentMode = UIViewContentModeCenter;
        nowPlayingImageView.image = [UIImage imageNamed:@"Track_List_Playing"];
        nowPlayingImageView.highlightedImage = [UIImage imageNamed:@"Track_List_Playing-Selected"];
        [self.contentView addSubview:nowPlayingImageView];
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(63, 0, (self.contentView.frame.size.width - 108), 44)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:titleLabel];
        
        durationLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.contentView.frame.size.width - 44), 0, 40, 44)];
        durationLabel.textColor = [UIColor whiteColor];
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        // This is the maximum font size to display a duration with a single hours digit.
        durationLabel.minimumFontSize = 11;
        durationLabel.adjustsFontSizeToFitWidth = YES;
        
        durationLabel.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:durationLabel];
        
        if ([SkinManager iOS7Skin]) {
            trackNumberLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.font = [UIFont boldSystemFontOfSize:15];
            durationLabel.font = [UIFont systemFontOfSize:15];
            
            UIImageView *plainSelectedBackgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, 43)];
            plainSelectedBackgroundView.image = [UIImage imageNamed:@"Table_View_Cell_Background_Light-Selected"];
            self.selectedBackgroundView = plainSelectedBackgroundView;
        }
        else {
            trackNumberLabel.font = [UIFont boldSystemFontOfSize:15];
            titleLabel.font = [UIFont boldSystemFontOfSize:15];
            durationLabel.font = [UIFont boldSystemFontOfSize:15];
            
            if (![SkinManager iOS7]) {
                leftTitleSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(53, 0, 1, 44)];
                leftTitleSeparatorView.backgroundColor = separatorViewColor;
                [self.contentView addSubview:leftTitleSeparatorView];
                
                rightTitleSeparatorView = [[UIView alloc]initWithFrame:CGRectMake((self.contentView.frame.size.width - 45), 0, 1, 44)];
                rightTitleSeparatorView.backgroundColor = separatorViewColor;
                rightTitleSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [self.contentView addSubview:rightTitleSeparatorView];
            }
        }
    }
    return self;
}

@end
