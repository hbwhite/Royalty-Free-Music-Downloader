//
//  AddToPlaylistViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/27/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "AddToPlaylistViewController.h"
#import "SongsViewController.h"
#import "FilesViewController.h"
#import "PlaylistsViewController.h"
#import "ArtistsViewController.h"
#import "AlbumsViewController.h"
#import "GenresViewController.h"
#import "Playlist.h"
#import "SkinManager.h"
#import "MoreTableViewDataSource.h"
#import "Modes.h"

static NSString *kFilesStr  = @"Files";

@interface AddToPlaylistViewController ()

@property (nonatomic, unsafe_unretained) id <AddToPlaylistViewControllerDelegate> addToPlaylistViewControllerDelegate;
@property (nonatomic, strong) NSMutableArray *selectedFilesArray;
@property (nonatomic, strong) MoreTableViewDataSource *moreTableViewDataSource;
@property (nonatomic, strong) UIImageView *dividerImageView1;
@property (nonatomic, strong) UIImageView *dividerImageView2;
@property (nonatomic, strong) UIImageView *dividerImageView3;
@property (nonatomic, strong) UIImageView *dividerImageView4;

- (void)didFinishSelectingFiles;

@end

@implementation AddToPlaylistViewController

// Private
@synthesize addToPlaylistViewControllerDelegate = _addToPlaylistViewControllerDelegate;
@synthesize selectedFilesArray;
@synthesize moreTableViewDataSource;
@synthesize dividerImageView1;
@synthesize dividerImageView2;
@synthesize dividerImageView3;
@synthesize dividerImageView4;

- (id)initWithDelegate:(id <AddToPlaylistViewControllerDelegate>)addToPlaylistViewControllerDelegate {
    self = [super init];
    if (self) {
        // Custom initialization
        
        // -viewDidLoad can be called before self.addToPlaylistViewControllerDelegate is set, so the code that would normally run in -viewDidLoad is called here.
        
        self.addToPlaylistViewControllerDelegate = addToPlaylistViewControllerDelegate;
        
        selectedFilesArray = [[NSMutableArray alloc]init];
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:nil];
        
        // Using a loop here helps to define different instances of UINavigationController while reusing the generic variable name "navigationController".
        for (int i = 0; i < 6; i++) {
            if (i == 0) {
                SongsViewController *songsViewController = [[SongsViewController alloc]init];
                songsViewController.songSelectorDelegate = self;
                songsViewController.title = NSLocalizedString(@"Songs", @"");
                
                UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:songsViewController];
                
                [viewControllers addObject:navigationController];
            }
            else if (i == 1) {
                ArtistsViewController *artistsViewController = [[ArtistsViewController alloc]init];
                artistsViewController.songSelectorDelegate = self;
                artistsViewController.title = NSLocalizedString(@"NO_CONTEXT_NAVTITLE_ARTISTS", @"");
                
                UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:artistsViewController];
                
                [viewControllers addObject:navigationController];
            }
            else if (i == 2) {
                AlbumsViewController *albumsViewController = [[AlbumsViewController alloc]init];
                albumsViewController.songSelectorDelegate = self;
                albumsViewController.title = NSLocalizedString(@"Albums", @"");
                
                UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:albumsViewController];
                
                [viewControllers addObject:navigationController];
            }
            else if (i == 3) {
                GenresViewController *genresViewController = [[GenresViewController alloc]init];
                genresViewController.songSelectorDelegate = self;
                genresViewController.title = NSLocalizedString(@"NO_CONTEXT_NAVTITLE_GENRES", @"");
                
                UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:genresViewController];
                
                [viewControllers addObject:navigationController];
            }
            else if (i == 4) {
                FilesViewController *filesViewController = [[FilesViewController alloc]init];
                filesViewController.songSelectorDelegate = self;
                filesViewController.title = kFilesStr;
                
                UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:filesViewController];
                
                [viewControllers addObject:navigationController];
            }
            else {
                PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc]init];
                playlistsViewController.songSelectorDelegate = self;
                playlistsViewController.title = NSLocalizedString(@"Playlists", @"");
                
                UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:playlistsViewController];
                
                [viewControllers addObject:navigationController];
            }
        }
        
        for (int i = 0; i < [viewControllers count]; i++) {
            UITabBarItem *tabBarItem = [[viewControllers objectAtIndex:i]tabBarItem];
            tabBarItem.tag = i;
        }
        self.viewControllers = viewControllers;
        
        id topView = self.moreNavigationController.topViewController.view;
        if ([topView isKindOfClass:[UITableView class]]) {
            UITableView *tableView = topView;
            moreTableViewDataSource = [[MoreTableViewDataSource alloc]initWithOriginalDataSource:tableView.dataSource tableView:tableView];
            tableView.dataSource = moreTableViewDataSource;
        }
        
        BOOL iOS6Skin = [SkinManager iOS6Skin];
        BOOL iOS5 = ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending);
        
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (iOS6Skin) {
                dividerImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(((self.tabBar.frame.size.width / 5.0) - 2), 0, 2, 49)];
                dividerImageView1.contentMode = UIViewContentModeRight;
                dividerImageView1.image = [UIImage imageNamed:@"Tab_Bar_Divider-6"];
                dividerImageView1.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
                [self.tabBar addSubview:dividerImageView1];
                
                dividerImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake((((self.tabBar.frame.size.width / 5.0) * 2) - 2), 0, 2, 49)];
                dividerImageView2.contentMode = UIViewContentModeRight;
                dividerImageView2.image = [UIImage imageNamed:@"Tab_Bar_Divider-6"];
                dividerImageView2.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
                [self.tabBar addSubview:dividerImageView2];
                
                dividerImageView3 = [[UIImageView alloc]initWithFrame:CGRectMake((((self.tabBar.frame.size.width / 5.0) * 3) - 2), 0, 2, 49)];
                dividerImageView3.contentMode = UIViewContentModeRight;
                dividerImageView3.image = [UIImage imageNamed:@"Tab_Bar_Divider-6"];
                dividerImageView3.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
                [self.tabBar addSubview:dividerImageView3];
                
                dividerImageView4 = [[UIImageView alloc]initWithFrame:CGRectMake((((self.tabBar.frame.size.width / 5.0) * 4) - 2), 0, 2, 49)];
                dividerImageView4.contentMode = UIViewContentModeRight;
                dividerImageView4.image = [UIImage imageNamed:@"Tab_Bar_Divider-6"];
                dividerImageView4.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
                [self.tabBar addSubview:dividerImageView4];
            }
            else {
                [dividerImageView1 removeFromSuperview];
                [dividerImageView2 removeFromSuperview];
                [dividerImageView3 removeFromSuperview];
                [dividerImageView4 removeFromSuperview];
            }
        }
        
        for (int i = 0; i < [self.viewControllers count]; i++) {
            UITabBarItem *item = [[self.viewControllers objectAtIndex:i]tabBarItem];
            
            NSString *imageName = nil;
            
            switch (item.tag) {
                case 0:
                    imageName = @"Songs";
                    break;
                case 1:
                    imageName = @"Artists";
                    break;
                case 2:
                    imageName = @"Albums";
                    break;
                case 3:
                    imageName = @"Genres";
                    break;
                case 4:
                    imageName = @"File";
                    break;
                case 5:
                    imageName = @"Playlists";
                    break;
            }
            
            item.image = [UIImage iOS7SkinImageNamed:imageName];
            
            if (iOS6Skin) {
                UIImage *image = [UIImage skinImageNamed:imageName];
                [item setFinishedSelectedImage:image withFinishedUnselectedImage:image];
            }
            else if ([item respondsToSelector:@selector(setFinishedSelectedImage:withFinishedUnselectedImage:)]) {
                [item setFinishedSelectedImage:nil withFinishedUnselectedImage:nil];
            }
        }
        
        if ((iOS6Skin) || ([SkinManager iOS7Skin])) {
            UIImage *image = [UIImage skinImageNamed:@"More"];
            UITabBarItem *moreTabBarItem = [[UITabBarItem alloc]initWithTitle:@"More" image:image tag:0];
            if (iOS5) {
                [moreTabBarItem setFinishedSelectedImage:image withFinishedUnselectedImage:image];
            }
            self.moreNavigationController.tabBarItem = moreTabBarItem;
        }
        else {
            self.moreNavigationController.tabBarItem = nil;
        }
        
        // iOS 7 appearance fix.
        if ([self.tabBar respondsToSelector:@selector(setTranslucent:)]) {
            [self.tabBar setTranslucent:NO];
        }
        
        self.delegate = self;
        self.moreNavigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"ADD_SONGS_TO_CUSTOM_PLAYLIST_FORMAT", @""), [[addToPlaylistViewControllerDelegate addToPlaylistViewControllerPlaylist]name]];
        self.moreNavigationController.delegate = self;
    }
    return self;
}

- (void)didFinishSelectingFiles {
    if (self.addToPlaylistViewControllerDelegate) {
        if ([self.addToPlaylistViewControllerDelegate respondsToSelector:@selector(addToPlaylistViewControllerDidSelectFiles:)]) {
            [self.addToPlaylistViewControllerDelegate addToPlaylistViewControllerDidSelectFiles:selectedFilesArray];
        }
    }
}

#pragma mark Song selector delegate

- (kMode)songSelectorMode {
    return kModeAddToPlaylist;
}

- (Playlist *)songSelectorPlaylist {
    return [self.addToPlaylistViewControllerDelegate addToPlaylistViewControllerPlaylist];
}

- (NSArray *)songSelectorSelectedFiles {
    return selectedFilesArray;
}

- (void)songSelectorDidSelectFile:(File *)selectedFile {
    [selectedFilesArray addObject:selectedFile];
}

- (void)songSelectorDidSelectFiles:(NSArray *)selectedFiles {
    [selectedFilesArray addObjectsFromArray:selectedFiles];
}

- (void)songSelectorDidFinishSelectingFiles {
    [self didFinishSelectingFiles];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    for (int i = 0; i < [tabBarController.viewControllers count]; i++) {
        UINavigationController *navigationController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:i];
        for (int j = 0; j < [navigationController.viewControllers count]; j++) {
            UIViewController *viewController = [navigationController.viewControllers objectAtIndex:j];
            if ([viewController isKindOfClass:[VisibilityViewController class]]) {
                [(VisibilityViewController *)viewController normalize];
            }
        }
    }
    
    // The above code will not work for view controllers pushed from the tab bar controller's more navigation controller, so it is reset here.
    UINavigationController *moreNavigationController = tabBarController.moreNavigationController;
    
    for (int i = 0; i < [moreNavigationController.viewControllers count]; i++) {
        UIViewController *viewController = [moreNavigationController.viewControllers objectAtIndex:i];
        if ([viewController isKindOfClass:[VisibilityViewController class]]) {
            [(VisibilityViewController *)viewController normalize];
        }
    }
    
    [moreNavigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([SkinManager iOS6Skin]) {
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
                dividerImageView1.hidden = NO;
                dividerImageView2.hidden = NO;
                dividerImageView3.hidden = NO;
                dividerImageView4.hidden = NO;
            }
            else {
                dividerImageView1.hidden = YES;
                dividerImageView2.hidden = YES;
                dividerImageView3.hidden = YES;
                dividerImageView4.hidden = YES;
            }
        }
    }
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

#pragma mark Navigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.moreNavigationController.delegate = nil;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(didFinishSelectingFiles)];
    self.moreNavigationController.navigationBar.topItem.rightBarButtonItem = doneButton;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
