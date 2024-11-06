//
//  ShuffleCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 4/8/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StandardCell.h"

@interface ShuffleCell : StandardCell {
@private
    UIImageView *shuffleImageView;
}

- (void)configure;

@end
