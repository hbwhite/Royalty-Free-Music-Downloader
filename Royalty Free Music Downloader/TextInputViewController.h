//
//  TextInputViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextInputViewControllerDelegate.h"

@interface TextInputViewController : UITableViewController <UITextFieldDelegate> {
@public
    id <TextInputViewControllerDelegate> __unsafe_unretained delegate;
@private
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *doneButton;
    NSString *titleField;
    BOOL didAssignFirstResponder;
}

@property (nonatomic, unsafe_unretained) id <TextInputViewControllerDelegate> delegate;

@end
