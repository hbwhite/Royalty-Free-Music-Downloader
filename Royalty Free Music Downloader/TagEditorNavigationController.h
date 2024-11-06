//
//  TagEditorNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagEditorNavigationControllerDelegate.h"
#import "TagEditorViewControllerDelegate.h"

@class TagEditorViewController;
@class File;

@interface TagEditorNavigationController : UINavigationController <TagEditorViewControllerDelegate> {
@public
    id <TagEditorNavigationControllerDelegate> __unsafe_unretained tagEditorNavigationControllerDelegate;
@private
    TagEditorViewController *tagEditorViewController;
}

@property (nonatomic, unsafe_unretained) id <TagEditorNavigationControllerDelegate> tagEditorNavigationControllerDelegate;

- (id)initWithFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex;

@end
