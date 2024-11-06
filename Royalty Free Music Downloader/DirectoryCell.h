//
//  DirectoryCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StandardCell.h"

@interface DirectoryCell : StandardCell {
    NSInteger tier;
}

@property (nonatomic) NSInteger tier;

@end
