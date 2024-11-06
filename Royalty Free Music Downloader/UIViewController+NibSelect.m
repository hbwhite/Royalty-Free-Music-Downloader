//
//  UIViewController+NibSelect.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/21/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "UIViewController+NibSelect.h"

// iPhone
static NSString *kiPhoneNibFileNameSuffixStr    = @"_iPhone";
static NSString *kiPhone568NibFileNameSuffixStr = @"_iPhone568";

// iPad
static NSString *kiPadNibFileNameSuffixStr      = @"_iPad";

@implementation UIViewController (NibSelect)

- (id)initWithNibBaseName:(NSString *)nibBaseName bundle:(NSBundle *)nibBundleOrNil {
    NSString *nibName = nil;
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([[UIScreen mainScreen]bounds].size.height == 568) {
            nibName = [nibBaseName stringByAppendingString:kiPhone568NibFileNameSuffixStr];
        }
        else {
            nibName = [nibBaseName stringByAppendingString:kiPhoneNibFileNameSuffixStr];
        }
    }
    else {
        nibName = [nibBaseName stringByAppendingString:kiPadNibFileNameSuffixStr];
    }
    
    return [self initWithNibName:nibName bundle:nibBundleOrNil];
}

@end
