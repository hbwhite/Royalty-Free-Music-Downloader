//
//  SwitchCell.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 10/22/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StandardGroupedCell.h"

@interface SwitchCell : StandardGroupedCell {
	UISwitch *cellSwitch;
}

@property (nonatomic, strong) UISwitch *cellSwitch;

@end
