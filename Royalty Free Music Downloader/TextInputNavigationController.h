//
//  TextInputNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextInputNavigationControllerDelegate.h"
#import "TextInputViewControllerDelegate.h"

@class TextInputViewController;

@interface TextInputNavigationController : UINavigationController <TextInputViewControllerDelegate> {
@public
    id <TextInputNavigationControllerDelegate> __unsafe_unretained textInputNavigationControllerDelegate;
@private
    TextInputViewController *textInputViewController;
}

@property (nonatomic, unsafe_unretained) id <TextInputNavigationControllerDelegate> textInputNavigationControllerDelegate;

@end
