//
//  AutoresizingViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "AutoresizingViewController.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "NowPlayingButton.h"
#import "SkinManager.h"
#import "UIImage+SafeStretchableImage.h"

@interface AutoresizingViewController ()

- (void)adDidShow;
- (void)adDidHide;
- (void)updateFrames;
- (void)updateSkin;

@end

@implementation AutoresizingViewController

@synthesize tableView = _tableView;

- (void)adDidShow {
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - [[[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewContainer]frame].size.height));
}

- (void)adDidHide {
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)updateFrames {
    if ([[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewShown]) {
        [self adDidShow];
    }
    else {
        [self adDidHide];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // This is necessary for the view to be laid out correctly on iOS 7.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(adDidShow) name:kAdDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(adDidHide) name:kAdDidHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateSkin) name:kSkinDidChangeNotification object:nil];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = (id <UITableViewDataSource>)self;
    self.tableView.delegate = (id <UITableViewDelegate>)self;
    [self.view addSubview:self.tableView];
    
    [self updateFrames];
    
    NowPlayingButton *nowPlayingButton = [[NowPlayingButton alloc]init];
    self.navigationItem.rightBarButtonItem = nowPlayingButton;
    
    [self updateSkin];
}

- (void)updateSkin {
    // Sometimes the navigation bar background can persist when switching skins.
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        if ([SkinManager iOS6Skin]) {
            [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"Navigation_Bar_Background-6"]safeStretchableImageWithLeftCapWidth:0 topCapHeight:22] forBarMetrics:UIBarMetricsDefault];
        }
        else {
            [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    if ([SkinManager iOS6Skin]) {
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
        self.tableView.backgroundView.hidden = YES;
    }
    else {
        if ([SkinManager iOS7Skin]) {
            self.tableView.backgroundColor = [SkinManager iOS7SkinTableViewBackgroundColor];
            self.tableView.backgroundView.hidden = YES;
        }
        else {
            // The table view background color does not change back to the groupTableViewBackgroundColor on devices running iOS 5.0.
            // Apparently +groupTableViewBackgroundColor will be deprecated at some point, so this is a safe way to resolve the issue.
            if ([UIColor respondsToSelector:@selector(groupTableViewBackgroundColor)]) {
                self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
            
            self.tableView.backgroundView.hidden = NO;
        }
    }
    
    // This makes the background less noticeable when the banner view is animating.
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    // iOS 7 appearance fix.
    // This must be called in -viewWillAppear: and will not work in -updateSkin.
    self.navigationController.navigationBar.translucent = NO;
    
    [self updateFrames];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // For some reason, elements don't always display properly if they are updated when -viewWillAppear: is called, so they have to be updated here instead.
    [self updateFrames];
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateFrames];
}

// iOS 6 Rotation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
