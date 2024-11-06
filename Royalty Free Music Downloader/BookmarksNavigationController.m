//
//  BookmarksNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "BookmarksNavigationController.h"
#import "BookmarksViewController.h"
#import "BookmarkFolder.h"
#import "UIViewController+SafeModal.h"

@interface BookmarksNavigationController ()

@property (nonatomic, strong) BookmarksViewController *bookmarksViewController;

@end

@implementation BookmarksNavigationController

// Public
@synthesize bookmarksNavigationControllerDelegate;

// Private
@synthesize bookmarksViewController;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        
        bookmarksViewController = [[BookmarksViewController alloc]initWithStyle:UITableViewStylePlain];
        bookmarksViewController.title = @"Bookmarks";
        bookmarksViewController.delegate = self;
        
        self.viewControllers = [NSArray arrayWithObject:bookmarksViewController];
        
        self.toolbarHidden = NO;
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

// This allows the keyboard to be automatically dismissed on the iPad.
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (BookmarkFolder *)bookmarksViewControllerParentBookmarkFolder {
    return nil;
}

- (void)bookmarksViewControllerDoneButtonPressed {
    if (bookmarksNavigationControllerDelegate) {
        if ([bookmarksNavigationControllerDelegate respondsToSelector:@selector(bookmarksNavigationControllerDidFinish)]) {
            [bookmarksNavigationControllerDelegate bookmarksNavigationControllerDidFinish];
        }
    }
}

- (void)bookmarksViewControllerDidSelectBookmarkForURL:(NSURL *)url {
    if (bookmarksNavigationControllerDelegate) {
        if ([bookmarksNavigationControllerDelegate respondsToSelector:@selector(bookmarksNavigationControllerDidSelectBookmarkForURL:)]) {
            [bookmarksNavigationControllerDelegate bookmarksNavigationControllerDidSelectBookmarkForURL:url];
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
