//
//  BrowserViewController.m
//  Browser
//
//  Created by Harrison White on 5/25/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "BrowserViewController.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "UserAgentViewController.h"
#import "AddBookmarkNavigationController.h"
#import "BookmarksNavigationController.h"
#import "ProgressTextField.h"
#import "NowPlayingButton.h"
#import "DataManager.h"
#import "Downloader.h"
#import "LegacyScrollViewDelegate.h"
#import "Bookmark.h"
#import "Reachability.h"
#import "MSLabel.h"
#import "SkinManager.h"
#import "FilePaths.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "UIImage+SafeStretchableImage.h"

#import "AdBlocker.h"

// This is a system key that should not be changed.
static NSString *kUserAgentKey          = @"UserAgent";

static NSString *kUserAgentIndexKey     = @"User Agent Index";
static NSString *kCustomUserAgentKey    = @"Custom User Agent";

static NSString *kiPhoneUserAgentStr    = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Mobile/8J2";
static NSString *kiPadUserAgentStr      = @"Mozilla/5.0 (iPad; U; CPU OS 4_2 like Mac OS X; ru-ru) AppleWebKit/533.17.9 (KHTML, like Gecko) Mobile/8C134";
static NSString *kFirefoxUserAgentStr   = @"Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20110506 Firefox/4.0.1";

static NSString *kBlockAdsKey           = @"Block Ads";
static NSString *kHomepageKey           = @"Homepage";
static NSString *kFAQURLStr             = @"http://www.harrisonapps.com/royaltyfreemusic/";

@interface BrowserViewController ()

@property (nonatomic, strong) IBOutlet UIView *topBar;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UINavigationBar *addressBar;
@property (nonatomic, strong) IBOutlet ProgressTextField *addressBarTextField;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *forwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong) IBOutlet UIButton *actionButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *bookmarksBarButtonItem;
@property (nonatomic, strong) IBOutlet UIButton *bookmarksButton;
@property (nonatomic, strong) IBOutlet UIButton *tabBarToggleButton;
@property (nonatomic, strong) IBOutlet UINavigationBar *rightBar;
@property (nonatomic, strong) IBOutlet UINavigationBar *backgroundBar;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIView *shadowView;
@property (nonatomic, strong) LegacyScrollViewDelegate *legacyScrollViewDelegate;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIActionSheet *downloadActionSheet;
@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) UIActionSheet *optionsActionSheet;
@property (nonatomic, strong) NSMutableArray *urlsArray;
@property (nonatomic, strong) NSURL *pendingURL;
@property (nonatomic) CGFloat previousYOffset;
@property (nonatomic) float previousZoomScale;
@property (readwrite) BOOL topBarShown;
@property (readwrite) BOOL loading;

@property (nonatomic, strong) NowPlayingButton *nowPlayingButton;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) Reachability *reachability;

@property (nonatomic, strong) NSFetchedResultsController *pagesFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *browserStateFetchedResultsController;

- (IBAction)rightButtonPressed;
- (IBAction)backButtonPressed;
- (IBAction)forwardButtonPressed;
- (IBAction)actionButtonPressed;
- (IBAction)bookmarksButtonPressed;
- (IBAction)tabBarToggleButtonPressed;
- (UIScrollView *)scrollView;
- (void)showTopBar;
- (void)hideTopBar;
- (void)_hideTopBar;
/*
- (void)adDidShow;
- (void)adDidHide;
*/
- (void)updateFrames;

@end

@implementation BrowserViewController

// Public
@synthesize pageTitle;
@synthesize currentURL;

// Private
@synthesize topBar;
@synthesize titleLabel;
@synthesize addressBar;
@synthesize addressBarTextField;
@synthesize progressView;
@synthesize backButton;
@synthesize forwardButton;
@synthesize actionBarButtonItem;
@synthesize actionButton;
@synthesize bookmarksBarButtonItem;
@synthesize bookmarksButton;
@synthesize tabBarToggleButton;
@synthesize rightBar;
@synthesize backgroundBar;
@synthesize toolbar;
@synthesize shadowView;
@synthesize legacyScrollViewDelegate;
@synthesize webView;
@synthesize popoverController;
@synthesize downloadActionSheet;
@synthesize currentConnection;
@synthesize optionsActionSheet;
@synthesize urlsArray;
@synthesize pendingURL;
@synthesize previousYOffset;
@synthesize previousZoomScale;
@synthesize topBarShown;
@synthesize loading;

@synthesize nowPlayingButton;
@synthesize progressProxy;
@synthesize reachability;

@synthesize pagesFetchedResultsController;
@synthesize browserStateFetchedResultsController;

- (IBAction)rightButtonPressed {
    [self exitSearchMode];
    
    if ([addressBarTextField.textField isFirstResponder]) {
        [addressBarTextField.textField resignFirstResponder];
        [self updateURL];
    }
}

- (IBAction)backButtonPressed {
    [webView goBack];
    
    currentURL = webView.request.URL;
    [self updateURL];
}

- (IBAction)forwardButtonPressed {
    [webView goForward];
    
    currentURL = webView.request.URL;
    [self updateURL];
}

- (IBAction)actionButtonPressed {
    if (optionsActionSheet) {
        [optionsActionSheet dismissWithClickedButtonIndex:optionsActionSheet.cancelButtonIndex animated:YES];
        optionsActionSheet = nil;
    }
    else {
        optionsActionSheet = [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                              destructiveButtonTitle:[NSString stringWithFormat:@"Download All (%i)", [urlsArray count]]
                              otherButtonTitles:@"Add Bookmark", @"Set as Home Page", nil];
        optionsActionSheet.tag = 2;
        optionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [optionsActionSheet showInView:self.tabBarController.view];
        }
        else {
            [optionsActionSheet showFromBarButtonItem:actionBarButtonItem animated:YES];
        }
    }
}

- (IBAction)bookmarksButtonPressed {
    BookmarksNavigationController *bookmarksNavigationController = [[BookmarksNavigationController alloc]init];
    bookmarksNavigationController.bookmarksNavigationControllerDelegate = self;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self safelyPresentModalViewController:bookmarksNavigationController animated:YES completion:nil];
    }
    else {
        if ((popoverController) && (popoverController.popoverVisible)) {
            [popoverController dismissPopoverAnimated:YES];
        }
        else {
            popoverController = [[UIPopoverController alloc]initWithContentViewController:bookmarksNavigationController];
            [popoverController presentPopoverFromBarButtonItem:bookmarksBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
    }
}

- (void)bookmarksNavigationControllerDidFinish {
    if ((popoverController) && (popoverController.popoverVisible)) {
        [popoverController dismissPopoverAnimated:YES];
    }
    
    if ([self safeModalViewController]) {
        [self safelyDismissModalViewControllerAnimated:YES completion:nil];
    }
}

- (void)bookmarksNavigationControllerDidSelectBookmarkForURL:(NSURL *)url {
    currentURL = url;
    [self loadWebView];
    
    if ((popoverController) && (popoverController.popoverVisible)) {
        [popoverController dismissPopoverAnimated:YES];
    }
    
    if ([self safeModalViewController]) {
        [self safelyDismissModalViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)tabBarToggleButtonPressed {
    if (self.hidesBottomBarWhenPushed) {
        [self showTabBar];
    }
    else {
        [self hideTabBar];
    }
}

- (void)hideTabBar {
    // This is ghetto but it's the most universal and safe method I've been able to find.
    self.hidesBottomBarWhenPushed = YES;
    UIViewController *viewController = [[UIViewController alloc]init];
    [self.navigationController pushViewController:viewController animated:NO];
    [self.navigationController popViewControllerAnimated:NO];
    
    // iPads using the default skin will use the iOS 6 skin images in the browser because the toolbars on the iPad are gray by default.
    if (([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) || (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin]))) {
        [tabBarToggleButton setImage:[UIImage skinImageNamed:@"Show_Tab_Bar"] forState:UIControlStateNormal];
    }
    else {
        [tabBarToggleButton setImage:[UIImage imageNamed:@"Show_Tab_Bar-6"] forState:UIControlStateNormal];
    }
    
    [self updateFrames];
}

- (void)showTabBar {
    // This is ghetto but it's the most universal and safe method I've been able to find.
    self.hidesBottomBarWhenPushed = NO;
    UIViewController *viewController = [[UIViewController alloc]init];
    [self.navigationController pushViewController:viewController animated:NO];
    [self.navigationController popViewControllerAnimated:NO];
    
    // iPads using the default skin will use the iOS 6 skin images in the browser because the toolbars on the iPad are gray by default.
    if (([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) || (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin]))) {
        [tabBarToggleButton setImage:[UIImage skinImageNamed:@"Hide_Tab_Bar"] forState:UIControlStateNormal];
    }
    else {
        [tabBarToggleButton setImage:[UIImage imageNamed:@"Hide_Tab_Bar-6"] forState:UIControlStateNormal];
    }
    
    [self updateFrames];
}

- (UIScrollView *)scrollView {
    if ([webView respondsToSelector:@selector(scrollView)]) {
        return [webView scrollView];
    }
    else {
        // The scrollView property of UIWebView is only available in iOS 5 or later.
        // Although it is a private property on earlier firmwares, the method below should always successfully access it.
        // This allows the app to target firmwares earlier than iOS 5.
        
        for (UIScrollView *scrollView in webView.subviews) {
            if ([scrollView isKindOfClass:[UIScrollView class]]) {
                return scrollView;
            }
        }
    }
    return nil;
}

- (void)showTopBar {
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
    topBarShown = YES;
    [UIView animateWithDuration:0.25 animations:^{
        [self scrollViewDidScroll:[self scrollView]];
    }];
}

- (void)hideTopBar {
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_hideTopBar) withObject:nil afterDelay:0.5];
}

- (void)_hideTopBar {
    topBarShown = NO;
    if (![addressBarTextField.textField isFirstResponder]) {
        [UIView animateWithDuration:0.25 animations:^{
            [self scrollViewDidScroll:[self scrollView]];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    [self updateFrames];
    
    if (![SkinManager iOS7]) {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // For some reason, elements don't always display properly if they are updated when -viewWillAppear: is called, so they have to be updated here instead.
    [self updateFrames];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (![SkinManager iOS7]) {
        if (![SkinManager iOS6Skin]) {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        }
    }
    
    TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
    tabBarController.bottomBar = kBottomBarTabBar;
    [tabBarController updateBannerViewFrames:YES];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // This is necessary for the view to be laid out correctly on iOS 7.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(browserSettingsDidChange) name:kBrowserSettingsDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(reachabilityChanged) name:kReachabilityChangedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateSkin) name:kSkinDidChangeNotification object:nil];
    
    // For some reason, notifications are sometimes sent to the BrowserViewController even though the observer has been removed in NSNotificationCenter, causing the deallocated webView to be accessed and, in turn, crashing the app. Because this seems to be a system problem, I have disabled this code here.
    /*
    [notificationCenter addObserver:self selector:@selector(adDidShow) name:kAdDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(adDidHide) name:kAdDidHideNotification object:nil];
    */
    
    urlsArray = [[NSMutableArray alloc]init];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shadowViewTapped)];
    [shadowView addGestureRecognizer:tapGestureRecognizer];
    
    UITextField *textField = addressBarTextField.textField;
    textField.delegate = self;
    textField.placeholder = @"Search or enter an address";
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    if ([SkinManager iOS7]) {
        textField.keyboardType = UIKeyboardTypeWebSearch;
    }
    else {
        textField.keyboardType = UIKeyboardTypeDefault;
    }
    
    textField.returnKeyType = UIReturnKeyGo;
    
    [self updateURL];
    
    [addressBarTextField.actionButton addTarget:self action:@selector(addressBarTextFieldActionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    progressView.frame = CGRectMake(0, (topBar.frame.size.height - 2), topBar.frame.size.width, 2);
    
    if ([progressView respondsToSelector:@selector(setTrackImage:)]) {
        if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
            [progressView setTrackImage:[UIImage imageNamed:@"Transparency"]];
        }
        else {
            [progressView setTrackImage:[UIImage imageNamed:@"Browser_Track-Minimum"]];
        }
    }
    
    if ([progressView respondsToSelector:@selector(setProgressImage:)]) {
        [progressView setProgressImage:[UIImage skinImageNamed:@"Browser_Track-Maximum"]];
    }
    
    nowPlayingButton = [[NowPlayingButton alloc]init];
    nowPlayingButton.nowPlayingContentButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    nowPlayingButton.nowPlayingLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    rightBar.topItem.rightBarButtonItem = nowPlayingButton;
    
    cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exitSearchMode)];
    
    [[self reachability]startNotifier];
    
    progressProxy = [[NJKWebViewProgress alloc]init];
    progressProxy.webViewProxyDelegate = self;
    progressProxy.progressDelegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger userAgentIndex = [defaults integerForKey:kUserAgentIndexKey];
    if (userAgentIndex > 0) {
        NSString *customUserAgent = nil;
        
        if (userAgentIndex == 1) {
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                customUserAgent = kiPadUserAgentStr;
            }
            else {
                customUserAgent = kiPhoneUserAgentStr;
            }
        }
        else if (userAgentIndex == 2) {
            customUserAgent = kFirefoxUserAgentStr;
        }
        else {
            customUserAgent = [defaults objectForKey:kCustomUserAgentKey];
        }
        
        NSDictionary *customUserAgentDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:customUserAgent, kUserAgentKey, nil];
        [defaults registerDefaults:customUserAgentDictionary];
        [defaults synchronize];
    }
    
    // Don't load the homepage if the user has chosen to view the Help / Info page from the settings section before the BrowserViewController has been initialized.
    if (!currentURL) {
        NSString *homepageURL = [[NSUserDefaults standardUserDefaults]objectForKey:kHomepageKey];
        if (homepageURL) {
            currentURL = [NSURL URLWithString:homepageURL];
        }
        else {
            currentURL = [NSURL URLWithString:kFAQURLStr];
        }
        
        // This updates the URL in case the home page cannot be loaded when the app is first launched.
        [self updateURL];
    }
    
    [self setUpWebView];
    
    [self updateSkin];
}

- (void)updateSkin {
    titleLabel.hidden = [SkinManager iOS7];
    
    // iPads using the default skin will use the iOS 6 skin images in the browser because the toolbars on the iPad are gray by default.
    if (([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) || (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin]))) {
        [backButton setImage:[UIImage skinImageNamed:@"Browser-Back"] forState:UIControlStateNormal];
        [forwardButton setImage:[UIImage skinImageNamed:@"Browser-Forward"] forState:UIControlStateNormal];
        [actionButton setImage:[UIImage skinImageNamed:@"Action-Toolbar"] forState:UIControlStateNormal];
        
        if (self.hidesBottomBarWhenPushed) {
            [tabBarToggleButton setImage:[UIImage skinImageNamed:@"Show_Tab_Bar"] forState:UIControlStateNormal];
        }
        else {
            [tabBarToggleButton setImage:[UIImage skinImageNamed:@"Hide_Tab_Bar"] forState:UIControlStateNormal];
        }
    }
    else {
        [backButton setImage:[UIImage imageNamed:@"Browser-Back-6"] forState:UIControlStateNormal];
        [forwardButton setImage:[UIImage imageNamed:@"Browser-Forward-6"] forState:UIControlStateNormal];
        [actionButton setImage:[UIImage imageNamed:@"Action-Toolbar-6"] forState:UIControlStateNormal];
        
        if (self.hidesBottomBarWhenPushed) {
            [tabBarToggleButton setImage:[UIImage imageNamed:@"Show_Tab_Bar-6"] forState:UIControlStateNormal];
        }
        else {
            [tabBarToggleButton setImage:[UIImage imageNamed:@"Hide_Tab_Bar-6"] forState:UIControlStateNormal];
        }
    }
    
    if ([SkinManager iOS7Skin]) {
        [backButton setImage:[UIImage imageNamed:@"Browser-Back-Disabled-7"] forState:UIControlStateDisabled];
        [forwardButton setImage:[UIImage imageNamed:@"Browser-Forward-Disabled-7"] forState:UIControlStateDisabled];
    }
    else {
        [backButton setImage:nil forState:UIControlStateDisabled];
        [forwardButton setImage:nil forState:UIControlStateDisabled];
    }
    
    if ([SkinManager iOS6Skin]) {
        [bookmarksButton setImage:[UIImage imageNamed:@"Bookmark-Gray"] forState:UIControlStateNormal];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            [bookmarksButton setImage:[UIImage imageNamed:@"Bookmark-7"] forState:UIControlStateNormal];
        }
        else {
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [bookmarksButton setImage:[UIImage imageNamed:@"Bookmark-White"] forState:UIControlStateNormal];
            }
            else {
                [bookmarksButton setImage:[UIImage imageNamed:@"Bookmark-Gray"] forState:UIControlStateNormal];
            }
        }
    }
}

// For some reason, notifications are sometimes sent to the BrowserViewController even though the observer has been removed in NSNotificationCenter, causing the deallocated webView to be accessed and, in turn, crashing the app. Because this seems to be a system problem, I have disabled this code here.
/*
- (void)adDidShow {
    webView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - ([[[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewContainer]frame].size.height + toolbar.frame.size.height)));
}

- (void)adDidHide {
    webView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - toolbar.frame.size.height));
}
*/

- (Reachability *)reachability {
    if (!reachability) {
        reachability = [Reachability reachabilityForInternetConnection];
    }
    return reachability;
}

- (void)browserSettingsDidChange {
    [webView removeFromSuperview];
    webView = nil;
    
    [self setUpWebView];
}

- (void)setUpWebView {
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - toolbar.frame.size.height))];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    webView.backgroundColor = [UIColor whiteColor];
    webView.scalesPageToFit = YES;
    webView.delegate = progressProxy;
    
    UIScrollView *scrollView = [self scrollView];
    if (scrollView) {
        UIEdgeInsets contentInset = scrollView.contentInset;
        contentInset.top = topBar.frame.size.height;
        
        // Because the web view frame isn't adjusted for the presence or absence of banner ads, there must be a margin at the bottom in case there is a banner ad (which would otherwise obscure the web view).
        contentInset.bottom = 50;
        
        scrollView.contentInset = contentInset;
        
        if ([webView respondsToSelector:@selector(scrollView)]) {
            scrollView.delegate = self;
        }
        else {
            if (!legacyScrollViewDelegate) {
                legacyScrollViewDelegate = [[LegacyScrollViewDelegate alloc]init];
            }
            
            legacyScrollViewDelegate.originalDelegate = scrollView.delegate;
            legacyScrollViewDelegate.replacedDelegate = self;
            
            scrollView.delegate = legacyScrollViewDelegate;
        }
        
        scrollView.bounces = YES;
        scrollView.alwaysBounceHorizontal = NO;
        scrollView.alwaysBounceVertical = YES;
        
        // This ensures that the top bar is completely shown when the app is first launched.
        scrollView.contentOffset = CGPointMake(0, -62);
    }
    
    [self.view insertSubview:webView belowSubview:shadowView];
    
    previousZoomScale = 1;
    
    [self loadWebView];
}

- (void)addressBarTextFieldActionButtonPressed {
    if (loading) {
        [self stopLoading];
    }
    else {
        // -reload is not always reliable, as it will only reload the existing data if a web page was only partially downloaded.
        [self loadWebView];
    }
}

- (void)updateFrames {
    CGSize boundsSize = self.view.bounds.size;
	CGSize toolbarSize = [toolbar sizeThatFits:boundsSize];
    toolbar.frame = CGRectMake(0, (self.view.frame.size.height - toolbarSize.height), toolbarSize.width, toolbarSize.height);
    
    if (![addressBar isFirstResponder]) {
        NSInteger xOffset = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 12 : 0;
        addressBar.frame = CGRectMake(xOffset, addressBar.frame.origin.y, (topBar.frame.size.width - (rightBar.frame.size.width + xOffset)), addressBar.frame.size.height);
    }
    
    // This ensures that the top bar frames are correct, especially after hiding or showing the tab bar.
    [self scrollViewDidScroll:[self scrollView]];
    
    TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        if (self.hidesBottomBarWhenPushed) {
            tabBarController.bottomBar = kBottomBarPortraitToolbar;
        }
        else {
            tabBarController.bottomBar = kBottomBarTabBarWithPortraitToolbar;
        }
    }
    else {
        if (self.hidesBottomBarWhenPushed) {
            tabBarController.bottomBar = kBottomBarLandscapeToolbar;
        }
        else {
            tabBarController.bottomBar = kBottomBarTabBarWithLandscapeToolbar;
        }
    }
    [tabBarController updateBannerViewFrames:YES];
    
    // For some reason, notifications are sometimes sent to the BrowserViewController even though the observer has been removed in NSNotificationCenter, causing the deallocated webView to be accessed and, in turn, crashing the app. Because this seems to be a system problem, I have disabled this code here.
    /*
    if ([[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewShown]) {
        [self adDidShow];
    }
    else {
        [self adDidHide];
    }
    */
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (webView.loading) {
        [self stopLoading];
    }
    
    // Due to a bug in iOS 7, -scrollRectToVisible: must be used instead of -setContentOffset:.
    [[self scrollView]scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [addressBarTextField didBecomeFirstResponder];
    addressBarTextField.textField.textAlignment = UITextAlignmentLeft;
    addressBarTextField.textField.text = [currentURL absoluteString];
    
    [UIView animateWithDuration:0.25 animations:^{
        [topBar sendSubviewToBack:backgroundBar];
        
        NSInteger xOffset = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 12 : 0;
        addressBar.frame = CGRectMake(xOffset, addressBar.frame.origin.y, (topBar.frame.size.width - (rightBar.frame.size.width + xOffset)), addressBar.frame.size.height);
    }];
    
    [self enterSearchMode];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [addressBarTextField didResignFirstResponder];
    addressBarTextField.textField.textAlignment = UITextAlignmentCenter;
    [self updateURL];
    
    [UIView animateWithDuration:0.25 animations:^{
        NSInteger xOffset = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 12 : 0;
        addressBar.frame = CGRectMake(xOffset, addressBar.frame.origin.y, (topBar.frame.size.width - (rightBar.frame.size.width + xOffset)), addressBar.frame.size.height);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *text = textField.text;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    if (([detector numberOfMatchesInString:text options:0 range:NSMakeRange(0, [text length])] == 1) &&
        (NSEqualRanges([detector rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, [text length])], NSMakeRange(0, [text length])))) {
        
        NSURL *url = [NSURL URLWithString:text];
        if ([[url scheme]length] <= 0) {
            text = [@"http://" stringByAppendingString:text];
        }
        currentURL = [NSURL URLWithString:text];
    }
    else {
        NSArray *preferredLanguageCodes = [NSLocale preferredLanguages];
        if ([preferredLanguageCodes count] > 0) {
            text = [NSString stringWithFormat:@"https://www.google.com/search?q=%@&ie=UTF-8&oe=UTF-8&hl=%@", [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [preferredLanguageCodes objectAtIndex:0]];
        }
        else {
            text = [NSString stringWithFormat:@"https://www.google.com/search?q=%@&ie=UTF-8&oe=UTF-8", [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        currentURL = [NSURL URLWithString:text];
    }
    
    [self updateURL];
    [self loadWebView];
    
    [self exitSearchMode];
    
    return NO;
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)enterSearchMode {
    rightBar.topItem.rightBarButtonItem = cancelButton;
    
    [[self scrollView]setScrollEnabled:NO];
    [UIView animateWithDuration:0.25 animations:^{
        shadowView.alpha = 0.5;
    }];
}

- (void)exitSearchMode {
    rightBar.topItem.rightBarButtonItem = nowPlayingButton;
    
    if ([addressBarTextField.textField isFirstResponder]) {
        [addressBarTextField.textField resignFirstResponder];
    }
    
    [[self scrollView]setScrollEnabled:YES];
    
    // This updates the frames of the elements.
    [self scrollViewDidScroll:[self scrollView]];
    
    if (shadowView.alpha > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            shadowView.alpha = 0;
        }];
    }
}

- (void)shadowViewTapped {
    [self exitSearchMode];
}

#pragma mark -
#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // If a link is clicked and the web view redirects to a blank page (with the address "about:blank"), the web view will never open the link.
    // This prevents this from happening by blocking requests to pages with the address "about:blank".
    if ([[[[request URL]absoluteString]lowercaseString]isEqualToString:@"about:blank"]) {
        return NO;
    }
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kBlockAdsKey]) {
        NSString *host = [[request URL]host];
        if (host) {
            NSArray *components = [[host lowercaseString]componentsSeparatedByString:@"."];
            NSInteger componentCount = [components count];
            
            // As far as I know, all websites must have a top-level domain, and since TLDs begin with a ".", there must be at least two components in a valid domain component array.
            for (int i = (componentCount - 2); i >= 0; i--) {
                NSString *formattedHost = [[components subarrayWithRange:NSMakeRange(i, (componentCount - i))]componentsJoinedByString:@"."];
                if ([[AdBlocker sharedAdBlocker]shouldFilterHost:formattedHost]) {
                    return NO;
                }
            }
        }
    }
    
    /*
    // This prevents mp3skull from redirecting to the App Store (there were many user complaints about this as many people thought it was part of the app, not the website).
    if ([[[[request URL]scheme]lowercaseString]isEqualToString:@"itms-appss"]) {
        if (navigationType == UIWebViewNavigationTypeOther) {
            return NO;
        }
    }
    */
    
    NSArray *audioExtensionsArray = [NSArray arrayWithObjects:@"m4a", @"m4r", @"m4b", @"m4p", @"mp4", @"3g2", @"aac", @"wav", @"aif", @"aifc", @"aiff", @"mp3", nil];
    NSArray *archiveExtensionsArray = [NSArray arrayWithObjects:@"rar", @"cbr", @"zip", nil];
    
    NSString *extension = [[request.URL pathExtension]lowercaseString];
    
    if ([audioExtensionsArray containsObject:extension]) {
        pendingURL = request.URL;
        
        if (downloadActionSheet) {
            [downloadActionSheet dismissWithClickedButtonIndex:downloadActionSheet.cancelButtonIndex animated:NO];
        }
        
        downloadActionSheet = [[UIActionSheet alloc]
                               initWithTitle:[request.URL absoluteString]
                               delegate:self
                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                               destructiveButtonTitle:@"Download"
                               otherButtonTitles:nil];
        downloadActionSheet.tag = 0;
        [downloadActionSheet showInView:self.tabBarController.view];
        
        return NO;
    }
    else if ([archiveExtensionsArray containsObject:extension]) {
        pendingURL = request.URL;
        
        if (downloadActionSheet) {
            [downloadActionSheet dismissWithClickedButtonIndex:downloadActionSheet.cancelButtonIndex animated:NO];
        }
        
        downloadActionSheet = [[UIActionSheet alloc]
                                initWithTitle:[request.URL absoluteString]
                                delegate:self
                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                destructiveButtonTitle:@"Download"
                                otherButtonTitles:nil];
        downloadActionSheet.tag = 1;
        [downloadActionSheet showInView:self.tabBarController.view];
        
        return NO;
    }
    
    // This prevents page resources from showing up in the address bar.
    if (navigationType != UIWebViewNavigationTypeOther) {
        // If a link is clicked or the user navigates backward or forward, -loadWebView cannot update the title, so it must be updated here.
        titleLabel.text = @"Loading";
        
        currentURL = [request URL];
        [self updateURL];
    }
    
    if ([[[[request URL]scheme]lowercaseString]hasPrefix:@"http"]) {
        if (currentConnection) {
            [currentConnection cancel];
        }
        currentConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
    }
    
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [connection cancel];
    
    NSArray *audioMIMETypes = [NSArray arrayWithObjects:
                               @"audio/3gpp2",
                               @"audio/aac",
                               @"audio/aiff",
                               @"audio/mp3",
                               @"audio/mp4",
                               @"audio/mpeg",
                               @"audio/mpeg3",
                               @"audio/wav",
                               @"audio/x-aac",
                               @"audio/x-aiff",
                               @"audio/x-caf",
                               @"audio/x-m4a",
                               @"audio/x-m4b",
                               @"audio/x-m4p",
                               @"audio/x-mp3",
                               @"audio/x-mpeg",
                               @"audio/x-mpeg3",
                               @"audio/x-wav",
                               nil];
    NSArray *archiveMIMETypes = [NSArray arrayWithObjects:
                                 @"application/zip",
                                 @"application/x-rar-compressed",
                                 @"application/octet-stream",
                                 nil];
    
    NSString *mimeType = [[response MIMEType]lowercaseString];
    
    if ([audioMIMETypes containsObject:mimeType]) {
        // This prevents the web view from playing audio, as the connections are concurrent.
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        
        pendingURL = [response URL];
        
        if (downloadActionSheet) {
            [downloadActionSheet dismissWithClickedButtonIndex:downloadActionSheet.cancelButtonIndex animated:NO];
        }
        
        downloadActionSheet = [[UIActionSheet alloc]
                                initWithTitle:[pendingURL absoluteString]
                                delegate:self
                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                destructiveButtonTitle:@"Download"
                                otherButtonTitles:nil];
        downloadActionSheet.tag = 0;
        [downloadActionSheet showInView:self.tabBarController.view];
    }
    else if ([archiveMIMETypes containsObject:mimeType]) {
        // This prevents the web view from playing audio, as the connections are concurrent.
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        
        pendingURL = [response URL];
        
        if (downloadActionSheet) {
            [downloadActionSheet dismissWithClickedButtonIndex:downloadActionSheet.cancelButtonIndex animated:NO];
        }
        
        downloadActionSheet = [[UIActionSheet alloc]
                               initWithTitle:[pendingURL absoluteString]
                               delegate:self
                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                               destructiveButtonTitle:@"Download"
                               otherButtonTitles:nil];
        downloadActionSheet.tag = 1;
        [downloadActionSheet showInView:self.tabBarController.view];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webview {
    loading = YES;
    
    [self showLoadingIndicator:YES];
    [self updateURL];
    [addressBarTextField.actionButton setImage:[UIImage skinImageNamed:@"Stop"] forState:UIControlStateNormal];
    [self showTopBar];
    
    backButton.enabled = [webview canGoBack];
    forwardButton.enabled = [webview canGoForward];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        downloadActionSheet = nil;
        
        if (buttonIndex == 0) {
            [[Downloader sharedDownloader]downloadSongAtURL:pendingURL];
        }
    }
    else if (actionSheet.tag == 1) {
        downloadActionSheet = nil;
        
        if (buttonIndex == 0) {
            [[Downloader sharedDownloader]downloadArchiveAtURL:pendingURL];
        }
    }
    else if (actionSheet.tag == 2) {
        optionsActionSheet = nil;
        
        if (buttonIndex == 0) {
            Downloader *downloader = [Downloader sharedDownloader];
            for (int i = 0; i < [urlsArray count]; i++) {
                NSString *url = [urlsArray objectAtIndex:i];
                [downloader downloadItemWithoutSavingAtURL:[NSURL URLWithString:url]];
            }
        }
        else if (buttonIndex == 1) {
            AddBookmarkNavigationController *addBookmarkNavigationController = [[AddBookmarkNavigationController alloc]init];
            addBookmarkNavigationController.addBookmarkNavigationControllerDelegate = self;
            [self safelyPresentModalViewController:addBookmarkNavigationController animated:YES completion:nil];
        }
        else if (buttonIndex == 2) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[currentURL absoluteString] forKey:kHomepageKey];
            [defaults synchronize];
        }
    }
}

- (NSString *)addBookmarkNavigationControllerBookmarkName {
    return pageTitle;
}

- (NSString *)addBookmarkNavigationControllerBookmarkURL {
    return [currentURL absoluteString];
}

- (void)addBookmarkNavigationControllerDidCancel {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)addBookmarkNavigationControllerDidChooseBookmarkName:(NSString *)bookmarkName url:(NSString *)url parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder {
    [[DataManager sharedDataManager]createBookmarkWithName:bookmarkName url:url parentBookmarkFolder:parentBookmarkFolder];
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview {
    NSString *downloadAllJavascriptFilePath = [[NSBundle mainBundle]pathForResource:@"Download_All" ofType:@"js"];
    NSString *downloadAllJavascriptString = [NSString stringWithContentsOfFile:downloadAllJavascriptFilePath encoding:NSUTF8StringEncoding error:nil];
    [webview stringByEvaluatingJavaScriptFromString:downloadAllJavascriptString];
    NSString *allURLs = [webview stringByEvaluatingJavaScriptFromString:@"javascript:findAllURLs();"];
    NSArray *allURLsArray = [allURLs componentsSeparatedByString:@","];
    NSArray *filteredURLsArray = [allURLsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *url = evaluatedObject;
        NSString *extension = [[url pathExtension]lowercaseString];
        NSArray *validExtensionsArray = [NSArray arrayWithObjects:
                                         // Audio extensions
                                         @"m4a", @"m4r", @"m4b", @"m4p", @"mp4", @"3g2", @"aac", @"wav", @"aif", @"aifc", @"aiff", @"mp3",
                                         // Archive extensions
                                         @"rar", @"cbr", @"zip", nil];
        return [validExtensionsArray containsObject:extension];
    }]];
    [urlsArray setArray:filteredURLsArray];
    
    loading = NO;
    previousZoomScale = [[self scrollView]zoomScale];
    
    backButton.enabled = [webview canGoBack];
    forwardButton.enabled = [webview canGoForward];
    
    [self showLoadingIndicator:NO];
    [self updateTitle];
    
    NSString *urlString = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    if ((urlString) && ([urlString length] > 0)) {
        currentURL = [NSURL URLWithString:urlString];
        [self updateURL];
    }
    
    [self fadeOutProgressView];
    [addressBarTextField.actionButton setImage:[UIImage skinImageNamed:@"Refresh"] forState:UIControlStateNormal];
    [self hideTopBar];
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error {
	[self webViewDidFinishLoad:webview];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    previousZoomScale *= scale;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // The address bar is completely shown with a Y-offset of -62 and fully compressed with a Y-offset of -40.
    if ((scrollView.contentOffset.y > -62) && (scrollView.contentOffset.y < -40)) {
        // Midpoint of -62 and -40; round to the nearest Y-offset.
        if (scrollView.contentOffset.y < -51) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -62) animated:YES];
        }
        else {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -40) animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float absoluteZoomScale = (previousZoomScale * scrollView.zoomScale);
    
    NSInteger x = 0;
    if (absoluteZoomScale >= 1) {
        if (scrollView.contentOffset.x < 0) {
            x = -scrollView.contentOffset.x;
        }
        else if ((scrollView.contentOffset.x + scrollView.frame.size.width) > scrollView.contentSize.width) {
            x = (scrollView.contentSize.width - (scrollView.contentOffset.x + scrollView.frame.size.width));
        }
    }
    
    if ([SkinManager iOS7]) {
        // The top bar height is fixed to prevent resizing issues when rotation occurs.
        
        if (scrollView.contentOffset.y < -40) {
            topBar.frame = CGRectMake(x, (-scrollView.contentOffset.y - topBar.frame.size.height), topBar.frame.size.width, 62);
        }
        else {
            topBar.frame = CGRectMake(x, -(topBar.frame.size.height - 40), topBar.frame.size.width, 62);
        }
        
        CGRect addressBarFrame = addressBar.frame;
        CGRect rightBarFrame = rightBar.frame;
        
        NSInteger originalAddressBarWidth = (topBar.frame.size.width - rightBar.frame.size.width);
        
        if ((scrollView.contentOffset.y >= -topBar.frame.size.height) && (scrollView.contentOffset.y <= -40)) {
            CGFloat offset = (scrollView.contentOffset.y + topBar.frame.size.height);
            CGFloat scale = (offset / 22.0);
            CGFloat invertedScale = (1 - scale);
            
            rightBar.alpha = invertedScale;
            [addressBarTextField setBackgroundAlpha:invertedScale];
            
            addressBarFrame.origin.y = (-12 + (11 * scale));
            rightBarFrame.origin.y = (-12 + (11 * scale));
            addressBarTextField.frame = CGRectMake(addressBarTextField.frame.origin.x, addressBarTextField.frame.origin.y, addressBarTextField.frame.size.width, (31 - (11 * scale)));
            rightBar.topItem.rightBarButtonItem.customView.frame = CGRectMake(rightBar.topItem.rightBarButtonItem.customView.frame.origin.x, rightBar.topItem.rightBarButtonItem.customView.frame.origin.y, rightBar.topItem.rightBarButtonItem.customView.frame.size.width, (31 - (11 * scale)));
            
            NSInteger shift = ((rightBarFrame.size.width + 30) * scale);
            addressBarFrame.size.width = (originalAddressBarWidth + shift);
            rightBarFrame.origin.x = (originalAddressBarWidth + shift);
        }
        else if (scrollView.contentOffset.y < -topBar.frame.size.height) {
            rightBar.alpha = 1;
            [addressBarTextField setBackgroundAlpha:1];
            
            addressBarFrame.origin.y = -12;
            rightBarFrame.origin.y = -12;
            addressBarTextField.frame = CGRectMake(addressBarTextField.frame.origin.x, addressBarTextField.frame.origin.y, addressBarTextField.frame.size.width, 31);
            rightBar.topItem.rightBarButtonItem.customView.frame = CGRectMake(rightBar.topItem.rightBarButtonItem.customView.frame.origin.x, rightBar.topItem.rightBarButtonItem.customView.frame.origin.y, rightBar.topItem.rightBarButtonItem.customView.frame.size.width, 31);
            
            addressBarFrame.size.width = originalAddressBarWidth;
            rightBarFrame.origin.x = originalAddressBarWidth;
        }
        else {
            rightBar.alpha = 0;
            [addressBarTextField setBackgroundAlpha:0];
            
            addressBarFrame.origin.y = -1;
            rightBarFrame.origin.y = -1;
            addressBarTextField.frame = CGRectMake(addressBarTextField.frame.origin.x, addressBarTextField.frame.origin.y, addressBarTextField.frame.size.width, 20);
            rightBar.topItem.rightBarButtonItem.customView.frame = CGRectMake(rightBar.topItem.rightBarButtonItem.customView.frame.origin.x, rightBar.topItem.rightBarButtonItem.customView.frame.origin.y, rightBar.topItem.rightBarButtonItem.customView.frame.size.width, 20);
            
            addressBarFrame.size.width = (originalAddressBarWidth + (rightBarFrame.size.width + 30));
            rightBarFrame.origin.x = (originalAddressBarWidth + (rightBarFrame.size.width + 30));
        }
        
        /*
         // Landscape orientation fix.
         addressBarFrame.size.height = 74;
         rightBarFrame.size.height = 74;
         */
        
        addressBar.frame = addressBarFrame;
        rightBar.frame = rightBarFrame;
    }
    else {
        if (topBarShown) {
            if (scrollView.contentOffset.y < -topBar.frame.size.height) {
                topBar.frame = CGRectMake(x, (-scrollView.contentOffset.y - topBar.frame.size.height), topBar.frame.size.width, topBar.frame.size.height);
            }
            else {
                topBar.frame = CGRectMake(x, 0, topBar.frame.size.width, topBar.frame.size.height);
            }
        }
        else {
            topBar.frame = CGRectMake(x, (-scrollView.contentOffset.y - topBar.frame.size.height), topBar.frame.size.width, topBar.frame.size.height);
        }
    }
    
    NSInteger scrollIndicatorInsetTop = (topBar.frame.origin.y + topBar.frame.size.height);
    if (scrollIndicatorInsetTop >= 0) {
        UIEdgeInsets scrollIndicatorInsets = scrollView.scrollIndicatorInsets;
        scrollIndicatorInsets.top = scrollIndicatorInsetTop;
        scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
    }
}

#pragma mark -
#pragma mark Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateFrames];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// iOS 6 Rotation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Getter Methods

- (void)updateTitle {
    NSString *documentTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (webView.loading) {
        if ([documentTitle length] > 0) {
            pageTitle = documentTitle;
            titleLabel.text = pageTitle;
        }
    }
    else {
        if ([documentTitle length] > 0) {
            pageTitle = documentTitle;
        }
        else {
            pageTitle = @"Untitled";
        }
        titleLabel.text = pageTitle;
    }
}

- (void)updateURL {
    // This prevents the app from updating the URL while the user is editing the address.
    if ([addressBarTextField isFirstResponder]) {
        return;
    }
    
    NSString *host = [currentURL host];
    if ([host hasPrefix:@"www."]) {
        host = [host substringFromIndex:4];
    }
    
    if ([[host lowercaseString]hasSuffix:@"google.com"]) {
        NSString *query = [currentURL query];
        NSArray *queryComponents = [query componentsSeparatedByString:@"&"];
        for (NSString *queryComponent in queryComponents) {
            NSRange equalsSignRange = [queryComponent rangeOfString:@"="];
            if (equalsSignRange.length > 0) {
                if ([[queryComponent substringToIndex:equalsSignRange.location]isEqualToString:@"q"]) {
                    NSString *searchText = [queryComponent substringFromIndex:(equalsSignRange.location + 1)];
                    
                    // Standard URL decoding
                    searchText = [searchText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    // Decode the plus signs used in place of spaces in Google search queries.
                    searchText = [searchText stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                    
                    if ([[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0) {
                        addressBarTextField.textField.text = searchText;
                        return;
                    }
                }
            }
        }
    }
    
    addressBarTextField.textField.text = host;
}

- (void)showLoadingIndicator:(BOOL)show {
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:show];
}

#pragma mark -
#pragma mark WebViewController Methods

- (void)stopLoading {
	[webView stopLoading];
    [self showLoadingIndicator:NO];
    [self fadeOutProgressView];
}

- (void)loadWebView {
    if ([self networkReachable]) {
        titleLabel.text = @"Loading";
        [webView loadRequest:[NSURLRequest requestWithURL:currentURL]];
    }
    else {
        UIAlertView *cannotConnectAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Cannot Connect"
                                           message:@"Please check your Internet connection status and try again."
                                           delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                           otherButtonTitles:nil];
        [cannotConnectAlert show];
    }
}

#pragma mark -
#pragma mark NJKWebViewProgressDelegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    if (![addressBarTextField isFirstResponder]) {
        if (progress < 1) {
            if (progressView.alpha < 1) {
                progressView.alpha = 1;
            }
            
            if ([progressView respondsToSelector:@selector(setProgress:animated:)]) {
                [progressView setProgress:progress animated:YES];
            }
            else {
                progressView.progress = progress;
            }
        }
        else {
            [self fadeOutProgressView];
        }
    }
}

- (void)fadeOutProgressView {
    [UIView beginAnimations:@"Fade Out Progress View" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didFadeOutProgressView)];
    progressView.alpha = 0;
    [UIView commitAnimations];
}

- (void)didFadeOutProgressView {
    if ([progressView respondsToSelector:@selector(setProgress:animated:)]) {
        [progressView setProgress:0 animated:NO];
    }
    else {
        progressView.progress = 0;
    }
}

#pragma mark -
#pragma mark Reachability Notification

- (void)reachabilityChanged {
    if (![self networkReachable]) {
        if ([webView isLoading]) {
            [self stopLoading];
            
            UIAlertView *cannotConnectAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Cannot Connect"
                                               message:@"Please check your Internet connection status and try again."
                                               delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil];
            [cannotConnectAlert show];
        }
    }
}

- (BOOL)networkReachable {
	NetworkStatus networkStatus = [[self reachability]currentReachabilityStatus];
	BOOL connectionRequired = [[self reachability]connectionRequired];
	
	if (((networkStatus == ReachableViaWiFi) || (networkStatus == ReachableViaWWAN)) && (!connectionRequired)) {
		return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
