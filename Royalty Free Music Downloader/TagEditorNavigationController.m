//
//  TagEditorNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "TagEditorNavigationController.h"
#import "TagEditorViewController.h"
#import "File.h"

@interface TagEditorNavigationController ()

@property (nonatomic, strong) TagEditorViewController *tagEditorViewController;

@end

@implementation TagEditorNavigationController

// Public
@synthesize tagEditorNavigationControllerDelegate;

// Private
@synthesize tagEditorViewController;

- (id)initWithFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex {
    self = [super init];
    if (self) {
        // Initialization code
        
        tagEditorViewController = [[TagEditorViewController alloc]initWithFiles:filesArray fileIndex:currentFileIndex];
        tagEditorViewController.delegate = self;
        
        self.viewControllers = [NSArray arrayWithObject:tagEditorViewController];
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)tagEditorViewControllerDidCancel {
    if (tagEditorNavigationControllerDelegate) {
        if ([tagEditorNavigationControllerDelegate respondsToSelector:@selector(tagEditorNavigationControllerDidCancel)]) {
            [tagEditorNavigationControllerDelegate tagEditorNavigationControllerDidCancel];
        }
    }
}

- (void)tagEditorViewControllerDidFinishEditingTags {
    if (tagEditorNavigationControllerDelegate) {
        if ([tagEditorNavigationControllerDelegate respondsToSelector:@selector(tagEditorNavigationControllerDidFinishEditingTags)]) {
            [tagEditorNavigationControllerDelegate tagEditorNavigationControllerDidFinishEditingTags];
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
