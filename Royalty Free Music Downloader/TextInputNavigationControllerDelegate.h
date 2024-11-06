//
//  TextInputNavigationControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@protocol TextInputNavigationControllerDelegate <NSObject>

@required
- (NSString *)textInputNavigationControllerNavigationBarTitle;
- (NSString *)textInputNavigationControllerHeader;
- (NSString *)textInputNavigationControllerPlaceholder;
- (NSString *)textInputNavigationControllerDefaultText;

@optional
- (void)textInputNavigationControllerDidCancel;
- (void)textInputNavigationControllerDidReceiveTextInput:(NSString *)text;

@end
