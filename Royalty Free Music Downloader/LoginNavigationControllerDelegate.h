//
//  LoginNavigationControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@protocol LoginNavigationControllerDelegate <NSObject>

@optional
- (void)loginNavigationControllerDidAuthenticate;
- (void)loginNavigationControllerDidFinish;

@end
