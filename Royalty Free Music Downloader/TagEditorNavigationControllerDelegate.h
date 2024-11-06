//
//  TagEditorNavigationControllerDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/23/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@protocol TagEditorNavigationControllerDelegate <NSObject>

@optional
- (void)tagEditorNavigationControllerDidCancel;
- (void)tagEditorNavigationControllerDidFinishEditingTags;

@end
