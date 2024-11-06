//
//  AddressCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/19/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressCell : UITableViewCell {
    UILabel *instructionsLabel;
    UILabel *addressLabel;
}

@property (nonatomic, strong) UILabel *instructionsLabel;
@property (nonatomic, strong) UILabel *addressLabel;

- (void)configure;

@end
