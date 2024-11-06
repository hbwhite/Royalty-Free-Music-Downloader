//
//  SingleAlbumSelectAllCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleAlbumSelectAllCell : UITableViewCell {
@public
    UIView *fullBackgroundView;
    UILabel *titleLabel;
@private
    UIView *topSeparatorView;
    UIView *bottomSeparatorView;
    UIView *leftTitleSeparatorView1;
    UIView *leftTitleSeparatorView2;
    UIView *rightTitleSeparatorView;
}

@property (nonatomic, strong) UIView *fullBackgroundView;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)configure;

@end
