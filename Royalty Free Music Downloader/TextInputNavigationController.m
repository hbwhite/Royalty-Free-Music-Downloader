//
//  TextInputNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "TextInputNavigationController.h"
#import "TextInputViewController.h"

@interface TextInputNavigationController ()

@property (nonatomic, strong) TextInputViewController *textInputViewController;

@end

@implementation TextInputNavigationController

// Public
@synthesize textInputNavigationControllerDelegate;

// Private
@synthesize textInputViewController;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        
        textInputViewController = [[TextInputViewController alloc]initWithStyle:UITableViewStyleGrouped];
        textInputViewController.delegate = self;
        
        self.viewControllers = [NSArray arrayWithObject:textInputViewController];
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (NSString *)textInputViewControllerNavigationBarTitle {
    return [textInputNavigationControllerDelegate textInputNavigationControllerNavigationBarTitle];
}

- (NSString *)textInputViewControllerHeader {
    return [textInputNavigationControllerDelegate textInputNavigationControllerHeader];
}

- (NSString *)textInputViewControllerPlaceholder {
    return [textInputNavigationControllerDelegate textInputNavigationControllerPlaceholder];
}

- (NSString *)textInputViewControllerDefaultText {
    return [textInputNavigationControllerDelegate textInputNavigationControllerDefaultText];
}

- (void)textInputViewControllerDidCancel {
    if (textInputNavigationControllerDelegate) {
        if ([textInputNavigationControllerDelegate respondsToSelector:@selector(textInputNavigationControllerDidCancel)]) {
            [textInputNavigationControllerDelegate textInputNavigationControllerDidCancel];
        }
    }
}

- (void)textInputViewControllerDidReceiveTextInput:(NSString *)text {
    if (textInputNavigationControllerDelegate) {
        if ([textInputNavigationControllerDelegate respondsToSelector:@selector(textInputNavigationControllerDidReceiveTextInput:)]) {
            [textInputNavigationControllerDelegate textInputNavigationControllerDidReceiveTextInput:text];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
