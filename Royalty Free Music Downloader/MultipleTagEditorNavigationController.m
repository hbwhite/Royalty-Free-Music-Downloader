//
//  MultipleTagEditorNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "MultipleTagEditorNavigationController.h"
#import "MultipleTagEditorViewController.h"
#import "File.h"

@interface MultipleTagEditorNavigationController ()

@property (nonatomic, strong) MultipleTagEditorViewController *multipleTagEditorViewController;

@end

@implementation MultipleTagEditorNavigationController

// Public
@synthesize multipleTagEditorNavigationControllerDelegate;

// Private
@synthesize multipleTagEditorViewController;

- (id)initWithFiles:(NSArray *)filesArray {
    self = [super init];
    if (self) {
        // Initialization code
        
        multipleTagEditorViewController = [[MultipleTagEditorViewController alloc]initWithFiles:filesArray];
        multipleTagEditorViewController.title = @"Edit Tags";
        multipleTagEditorViewController.delegate = self;
        
        self.viewControllers = [NSArray arrayWithObject:multipleTagEditorViewController];
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)multipleTagEditorViewControllerDidCancel {
    if (multipleTagEditorNavigationControllerDelegate) {
        if ([multipleTagEditorNavigationControllerDelegate respondsToSelector:@selector(multipleTagEditorNavigationControllerDidCancel)]) {
            [multipleTagEditorNavigationControllerDelegate multipleTagEditorNavigationControllerDidCancel];
        }
    }
}

- (void)multipleTagEditorViewControllerDidFinishEditingTags {
    if (multipleTagEditorNavigationControllerDelegate) {
        if ([multipleTagEditorNavigationControllerDelegate respondsToSelector:@selector(multipleTagEditorNavigationControllerDidFinishEditingTags)]) {
            [multipleTagEditorNavigationControllerDelegate multipleTagEditorNavigationControllerDidFinishEditingTags];
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
