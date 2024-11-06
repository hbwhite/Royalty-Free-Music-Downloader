//
//  MultipleTagEditorNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipleTagEditorNavigationControllerDelegate.h"
#import "MultipleTagEditorViewControllerDelegate.h"

@class MultipleTagEditorViewController;
@class File;

@interface MultipleTagEditorNavigationController : UINavigationController <MultipleTagEditorViewControllerDelegate> {
@public
    id <MultipleTagEditorNavigationControllerDelegate> __unsafe_unretained multipleTagEditorNavigationControllerDelegate;
@private
    MultipleTagEditorViewController *multipleTagEditorViewController;
}

@property (nonatomic, unsafe_unretained) id <MultipleTagEditorNavigationControllerDelegate> multipleTagEditorNavigationControllerDelegate;

- (id)initWithFiles:(NSArray *)filesArray;

@end
