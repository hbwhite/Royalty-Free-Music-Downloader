//
//  TextInputViewControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/18/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@protocol TextInputViewControllerDelegate <NSObject>

@required
- (NSString *)textInputViewControllerNavigationBarTitle;
- (NSString *)textInputViewControllerHeader;
- (NSString *)textInputViewControllerPlaceholder;
- (NSString *)textInputViewControllerDefaultText;

@optional
- (void)textInputViewControllerDidCancel;
- (void)textInputViewControllerDidReceiveTextInput:(NSString *)text;

@end
