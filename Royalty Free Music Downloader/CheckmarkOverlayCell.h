//
//  CheckmarkOverlayCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StandardCell.h"

@interface CheckmarkOverlayCell : StandardCell {
    UIView *checkmarkOverlayView;
    UIImageView *checkmarkOverlayImageView;
}

@property (nonatomic, strong) UIView *checkmarkOverlayView;
@property (nonatomic, strong) UIImageView *checkmarkOverlayImageView;

@end
