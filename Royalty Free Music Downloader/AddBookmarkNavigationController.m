//
//  AddBookmarkNavigationController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "AddBookmarkNavigationController.h"
#import "EditBookmarkViewController.h"
#import "BookmarkFolder.h"
#import "UIViewController+SafeModal.h"

@interface AddBookmarkNavigationController ()

@property (nonatomic, strong) EditBookmarkViewController *editBookmarkViewController;

@end

@implementation AddBookmarkNavigationController

// Public
@synthesize addBookmarkNavigationControllerDelegate;

// Private
@synthesize editBookmarkViewController;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        
        editBookmarkViewController = [[EditBookmarkViewController alloc]initWithStyle:UITableViewStyleGrouped];
        editBookmarkViewController.title = @"Add Bookmark";
        editBookmarkViewController.delegate = self;
        
        self.viewControllers = [NSArray arrayWithObject:editBookmarkViewController];
        
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

- (kEditBookmarkViewControllerMode)editBookmarkViewControllerMode {
    return kEditBookmarkViewControllerModeAddBookmark;
}

- (NSString *)editBookmarkViewControllerBookmarkName {
    return [addBookmarkNavigationControllerDelegate addBookmarkNavigationControllerBookmarkName];
}

- (NSString *)editBookmarkViewControllerBookmarkURL {
    return [addBookmarkNavigationControllerDelegate addBookmarkNavigationControllerBookmarkURL];
}

- (void)editBookmarkViewControllerDidCancel {
    if (addBookmarkNavigationControllerDelegate) {
        if ([addBookmarkNavigationControllerDelegate respondsToSelector:@selector(addBookmarkNavigationControllerDidCancel)]) {
            [addBookmarkNavigationControllerDelegate addBookmarkNavigationControllerDidCancel];
        }
    }
}

- (void)editBookmarkViewControllerDidChooseBookmarkName:(NSString *)bookmarkName url:(NSString *)url parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder {
    if (addBookmarkNavigationControllerDelegate) {
        if ([addBookmarkNavigationControllerDelegate respondsToSelector:@selector(addBookmarkNavigationControllerDidChooseBookmarkName:url:parentBookmarkFolder:)]) {
            [addBookmarkNavigationControllerDelegate addBookmarkNavigationControllerDidChooseBookmarkName:bookmarkName url:url parentBookmarkFolder:parentBookmarkFolder];
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
