//
//  BrowserViewController.h
//  Browser
//
//  Created by Harrison White on 5/25/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
#import "AddBookmarkNavigationControllerDelegate.h"
#import "BookmarksNavigationControllerDelegate.h"

#define kBrowserSettingsDidChangeNotification @"kBrowserSettingsDidChangeNotification"

@class LegacyScrollViewDelegate;
@class ProgressTextField;
@class CompactSearchBar;
@class NowPlayingButton;
@class Reachability;

@interface BrowserViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, NSURLConnectionDataDelegate, UIWebViewDelegate, UIActionSheetDelegate, NJKWebViewProgressDelegate, AddBookmarkNavigationControllerDelegate, BookmarksNavigationControllerDelegate> {
@public
    NSString *pageTitle;
    NSURL *currentURL;
@private
    IBOutlet UIView *topBar;
    IBOutlet UILabel *titleLabel;
    IBOutlet UINavigationBar *addressBar;
    IBOutlet ProgressTextField *addressBarTextField;
    IBOutlet UIProgressView *progressView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *forwardButton;
    IBOutlet UIBarButtonItem *actionBarButtonItem;
    IBOutlet UIButton *actionButton;
    IBOutlet UIBarButtonItem *bookmarksBarButtonItem;
    IBOutlet UIButton *bookmarksButton;
    IBOutlet UIButton *tabBarToggleButton;
    IBOutlet UINavigationBar *rightBar;
    IBOutlet UINavigationBar *backgroundBar;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIView *shadowView;
    LegacyScrollViewDelegate *legacyScrollViewDelegate;
    UIWebView *webView;
    UIPopoverController *popoverController;
    UIActionSheet *downloadActionSheet;
    NSURLConnection *currentConnection;
    UIActionSheet *optionsActionSheet;
    NSMutableArray *urlsArray;
    NSURL *pendingURL;
    CGFloat previousYOffset;
    float previousZoomScale;
    BOOL topBarShown;
    BOOL loading;
    
    NowPlayingButton *nowPlayingButton;
    UIBarButtonItem *cancelButton;
    NJKWebViewProgress *progressProxy;
    Reachability *reachability;
}

@property (nonatomic, strong) NSString *pageTitle;
@property (nonatomic, strong) NSURL *currentURL;

- (void)loadWebView;

@end
