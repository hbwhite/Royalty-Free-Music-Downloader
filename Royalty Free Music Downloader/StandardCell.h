//
//  StandardCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/13/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandardCell : UITableViewCell {
@private
    UIView *topSeparatorView;
    UIView *bottomSeparatorView;
}

- (void)configure;

@end
