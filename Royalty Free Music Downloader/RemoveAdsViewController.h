//
//  RemoveAdsViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "RemoveAdsViewControllerDelegate.h"

@class MBProgressHUD;

@interface RemoveAdsViewController : UITableViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
@public
    id <RemoveAdsViewControllerDelegate> __unsafe_unretained delegate;
@private
    MBProgressHUD *hud;
    UIAlertView *successAlert;
    SKProductsRequest *request;
    SKProduct *adFreeUpgradeProduct;
    BOOL didCancel;
}

@property (nonatomic, unsafe_unretained) id <RemoveAdsViewControllerDelegate> delegate;

@end
