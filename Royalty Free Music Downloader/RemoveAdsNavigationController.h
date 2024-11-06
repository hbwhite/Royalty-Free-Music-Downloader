//
//  RemoveAdsNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoveAdsNavigationControllerDelegate.h"
#import "RemoveAdsViewControllerDelegate.h"

@class RemoveAdsViewController;

@interface RemoveAdsNavigationController : UINavigationController <RemoveAdsViewControllerDelegate> {
@public
    id <RemoveAdsNavigationControllerDelegate> __unsafe_unretained removeAdsNavigationControllerDelegate;
@private
    RemoveAdsViewController *removeAdsViewController;
}

@property (nonatomic, unsafe_unretained) id <RemoveAdsNavigationControllerDelegate> removeAdsNavigationControllerDelegate;

@end
