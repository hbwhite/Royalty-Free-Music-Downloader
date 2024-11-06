//
//  IconDetailCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/19/11.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconDetailCell : UITableViewCell {
	UILabel *detailLabel;
}

@property (nonatomic, strong) UILabel *detailLabel;

- (void)configure;

@end
