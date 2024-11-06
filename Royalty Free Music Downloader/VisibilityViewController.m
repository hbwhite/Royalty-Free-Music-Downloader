//
//  VisibilityViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "VisibilityViewController.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "DownloadsViewController.h"
#import "FilesViewController.h"
#import "PlaylistsViewController.h"
#import "PlaylistsDetailViewController.h"
#import "Top25MostPlayedViewController.h"
#import "MyTopRatedViewController.h"
#import "RecentlyPlayedViewController.h"
#import "RecentlyAddedViewController.h"
#import "TextInputNavigationController.h"
#import "MoveItemsNavigationController.h"
#import "NowPlayingButton.h"
#import "SearchController.h"
#import "Playlist.h"
#import "StandardEditBar.h"
#import "FilesEditBar.h"
#import "PlaylistsEditBar.h"
#import "DataManager.h"
#import "OptionsActionSheetHandler.h"
#import "File.h"
#import "File+Extensions.h"
#import "Directory.h"
#import "Archive.h"
#import "SkinManager.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "UIImage+SafeStretchableImage.h"

static NSString *kShowEditBarKey    = @"Show Edit Bar";

@interface VisibilityViewController ()

@property (nonatomic, strong) NowPlayingButton *nowPlayingButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) SearchController *searchController;
@property (nonatomic, strong) NSString *previousTitle;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIBarButtonItem *editBarEditCancelButton;
@property (nonatomic, strong) UIBarButtonItem *editBarEditDoneButton;
@property (nonatomic, strong) UIBarButtonItem *editBarMultiEditCancelButton;
@property (nonatomic, strong) UIBarButtonItem *editBarMultiEditDoneButton;
@property (nonatomic, strong) UIBarButtonItem *editBarMoveCancelButton;
@property (nonatomic, strong) UIBarButtonItem *editBarMoveDoneButton;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, unsafe_unretained) id <UITableViewDataSource> __unsafe_unretained previousTableViewDataSource;
@property (nonatomic, unsafe_unretained) id <UITableViewDelegate> __unsafe_unretained previousTableViewDelegate;
@property (nonatomic, strong) UIView *previousTableViewFooter;
@property (nonatomic) CGFloat previousTableViewRowHeight;
@property (nonatomic, strong) Directory *renameDirectory;
@property (nonatomic) kTextInputViewControllerMode textInputViewControllerMode;

- (void)runBasicSetup;
- (void)adDidShow;
- (void)adDidHide;
- (void)updateFrames;
- (void)doneButtonPressed;
- (void)editBarAddFolderButtonPressed;
- (void)editBarEditButtonPressed;
- (void)editBarEditDoneButtonPressed;
- (void)exitEditMode;
- (void)editBarMultiEditButtonPressed;
- (void)editBarMultiEditCancelButtonPressed;
- (void)editBarMultiEditDoneButtonPressed;
- (void)exitMultiEditMode;
- (void)editBarMoveButtonPressed;
- (void)editBarMoveCancelButtonPressed;
- (void)editBarMoveDoneButtonPressed;
- (void)exitMoveMode;
- (void)cancelButtonPressed;
- (void)backButtonPressed;
- (void)updateSkin;
- (void)exitSearchMode;
- (void)shadowViewTapped;
- (void)titleButtonPressed;
- (void)expandEditBarAnimated;
- (void)expandEditBar;
- (void)collapseEditBarAnimated;
- (void)collapseEditBar;

@end

@implementation VisibilityViewController

// Public
@synthesize songSelectorDelegate;
@synthesize previousLeftBarButtonItem;
@synthesize previousRightBarButtonItem;
@synthesize playlistsEditBar;
@synthesize filesEditBar;
@synthesize selectedItemsArray;
@synthesize selectedFilesArray;
@synthesize mode;
@synthesize searching;
@synthesize viewIsVisible;
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;

// Private
@synthesize nowPlayingButton;
@synthesize cancelButton;
@synthesize searchController;
@synthesize previousTitle;
@synthesize titleView;
@synthesize titleLabel;
@synthesize arrowImageView;
@synthesize editBarEditDoneButton;
@synthesize editBarMultiEditCancelButton;
@synthesize editBarMultiEditDoneButton;
@synthesize editBarMoveCancelButton;
@synthesize editBarMoveDoneButton;
@synthesize shadowView;
@synthesize previousTableViewDataSource;
@synthesize previousTableViewDelegate;
@synthesize previousTableViewFooter;
@synthesize previousTableViewRowHeight;
@synthesize renameDirectory;
@synthesize textInputViewControllerMode;

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        // The delegate must be set before the table view is initialized because the relevant fetched results controller is loaded at that point and could otherwise have to be reloaded when the delegate is set, potentially modifying its predicate.
        if (delegate) {
            if ([self respondsToSelector:@selector(setDelegate:)]) {
                [self performSelector:@selector(setDelegate:) withObject:delegate];
            }
        }
        
        [self runBasicSetup];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self runBasicSetup];
    }
    return self;
}

- (void)runBasicSetup {
    // This initializes the fetched results controller when an instance of the class is initialized such that the required data has already been loaded when the app launches.
    // If the data isn't loaded beforehand, the app will lag when it loads it lazily.
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    // The table view frame must be set after the table view is initialized because the table view is accessed in -viewDidLoad (e.g. for the footer view), which is run when self.view is referenced in the following line (which would otherwise be part of the initialization code above, running before the table view is initialized).
    // In addition, as soon as self.view is referenced, -viewDidLoad is called, and because the table view must be initialized when the skin applies itself, -viewDidLoad must be called after the table view is initialized.
    self.tableView.frame = self.view.bounds;
    
    self.tableView.dataSource = (id <UITableViewDataSource>)self;
    self.tableView.delegate = (id <UITableViewDelegate>)self;
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:nil];
    self.tableView.tableHeaderView = searchDisplayController.searchBar;
    
    // The table view must be below the shadow view but above the edit bar.
    // The view will already have been loaded at this point (the first time self.view is called), so it is safe to refer to the shadowView variable in order to insert the table view directly below it.
    [self.view insertSubview:self.tableView belowSubview:shadowView];
}

- (void)setSongSelectorDelegate:(id <SongSelectorDelegate>)newSongSelectorDelegate {
    songSelectorDelegate = newSongSelectorDelegate;
    searchController.songSelectorDelegate = songSelectorDelegate;
    
    if ([songSelectorDelegate songSelectorMode] == kModeMain) {
        if (mode != kVisibilityViewControllerModeNone) {
            mode = kVisibilityViewControllerModeNone;
            [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerModeDidChangeNotification object:nil];
        }
        
        nowPlayingButton = [[NowPlayingButton alloc]init];
        self.navigationItem.rightBarButtonItem = nowPlayingButton;
    }
    else {
        if (mode != kVisibilityViewControllerModeAddToPlaylist) {
            mode = kVisibilityViewControllerModeAddToPlaylist;
            [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerModeDidChangeNotification object:nil];
        }
        
        self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"ADD_SONGS_TO_CUSTOM_PLAYLIST_FORMAT", @""), [[songSelectorDelegate songSelectorPlaylist]name]];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    // Reload the table view to account for the mode change.
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((tableView.dataSource) && ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) && ([[tableView.dataSource tableView:tableView titleForHeaderInSection:section]length] > 0)) {
        if ([SkinManager iOS6Skin]) {
            return 26;
        }
        else {
            return 22;
        }
    }
    return 0;
}

// Ingenious hack for optional delegate method implementation
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(tableView:viewForHeaderInSection:)) {
        return [SkinManager iOS6Skin];
    }
    else {
        return [super respondsToSelector:aSelector];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ((tableView.dataSource) && ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)])) {
        NSString *title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        if ([title length] > 0) {
            UIImageView *sectionHeaderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 26)];
            sectionHeaderImageView.image = [UIImage imageNamed:@"Table_View_Section_Header-6"];
            
            UILabel *sectionTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, (tableView.frame.size.width - 40), 25)];
            sectionTitleLabel.font = [UIFont boldSystemFontOfSize:15];
            sectionTitleLabel.textColor = [SkinManager iOS6SkinTableViewSectionHeaderTextColor];
            sectionTitleLabel.shadowColor = [SkinManager iOS6SkinTableViewSectionHeaderShadowColor];
            sectionTitleLabel.shadowOffset = CGSizeMake(0, 1);
            sectionTitleLabel.backgroundColor = [UIColor clearColor];
            sectionTitleLabel.text = title;
            [sectionHeaderImageView addSubview:sectionTitleLabel];
            return sectionHeaderImageView;
        }
    }
    return nil;
}

- (UISearchBar *)searchControllerSearchBar {
    return self.searchBar;
}

- (UITableView *)searchControllerTableView {
    return self.tableView;
}

- (UINavigationController *)searchControllerNavigationController {
    return self.navigationController;
}

- (BOOL)isPlaylistsDetailViewController {
    return (([self isKindOfClass:[PlaylistsDetailViewController class]]) || ([self isKindOfClass:[Top25MostPlayedViewController class]]) || ([self isKindOfClass:[MyTopRatedViewController class]]) || ([self isKindOfClass:[RecentlyPlayedViewController class]]) || ([self isKindOfClass:[RecentlyAddedViewController class]]));
}

- (void)adDidShow {
    if (mode == kVisibilityViewControllerModeAddToPlaylist) {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        shadowView.frame = CGRectMake(0, 44, self.tableView.frame.size.width, (self.tableView.frame.size.height - 44));
    }
    else {
        NSInteger yOffset = (([[NSUserDefaults standardUserDefaults]boolForKey:kShowEditBarKey]) && ((([self isKindOfClass:[FilesViewController class]]) && (mode == kVisibilityViewControllerModeEdit)) || ((mode != kVisibilityViewControllerModeEdit) && (mode != kVisibilityViewControllerModeMultiEdit) && (mode != kVisibilityViewControllerModeMove))) && (![self isPlaylistsDetailViewController])) ? 44 : 0;
        self.tableView.frame = CGRectMake(0, yOffset, self.view.frame.size.width, (self.view.frame.size.height - (yOffset + [[[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewContainer]frame].size.height)));
        shadowView.frame = CGRectMake(0, (yOffset + 44), self.tableView.frame.size.width, (self.tableView.frame.size.height - 44));
    }
}

- (void)adDidHide {
    if (mode == kVisibilityViewControllerModeAddToPlaylist) {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        shadowView.frame = CGRectMake(0, 44, self.tableView.frame.size.width, (self.tableView.frame.size.height - 44));
    }
    else {
        NSInteger yOffset = (([[NSUserDefaults standardUserDefaults]boolForKey:kShowEditBarKey]) && ((([self isKindOfClass:[FilesViewController class]]) && (mode == kVisibilityViewControllerModeEdit)) || ((mode != kVisibilityViewControllerModeEdit) && (mode != kVisibilityViewControllerModeMultiEdit) && (mode != kVisibilityViewControllerModeMove))) && (![self isPlaylistsDetailViewController])) ? 44 : 0;
        self.tableView.frame = CGRectMake(0, yOffset, self.view.frame.size.width, (self.view.frame.size.height - yOffset));
        shadowView.frame = CGRectMake(0, (yOffset + 44), self.tableView.frame.size.width, (self.tableView.frame.size.height - 44));
    }
}

- (void)updateFrames {
    if ([[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewShown]) {
        [self adDidShow];
    }
    else {
        [self adDidHide];
    }
    
    NSInteger fontSize = 20;
    if (([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && (self.interfaceOrientation != UIInterfaceOrientationPortrait)) {
        fontSize = 16;
    }
    else if ([SkinManager iOS7]) {
        fontSize = 17;
    }
    titleView.frame = CGRectMake(self.navigationItem.titleView.frame.origin.x, self.navigationItem.titleView.frame.origin.y, [previousTitle sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]].width, self.navigationController.navigationBar.frame.size.height);
    titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
}

- (void)doneButtonPressed {
    [songSelectorDelegate songSelectorDidFinishSelectingFiles];
}

- (void)editBarAddFolderButtonPressed {
    textInputViewControllerMode = kTextInputViewControllerModeAddFolder;
    
    TextInputNavigationController *textInputNavigationController = [[TextInputNavigationController alloc]init];
    textInputNavigationController.textInputNavigationControllerDelegate = self;
    [self safelyPresentModalViewController:textInputNavigationController animated:YES completion:nil];
}

- (NSString *)textInputNavigationControllerNavigationBarTitle {
    if (textInputViewControllerMode == kTextInputViewControllerModeAddFolder) {
        return @"Add Folder";
    }
    else if (textInputViewControllerMode == kTextInputViewControllerModeRenameFolder) {
        return @"Rename Folder";
    }
    else {
        return @"Rename Archive";
    }
}

- (NSString *)textInputNavigationControllerHeader {
    if (textInputViewControllerMode == kTextInputViewControllerModeAddFolder) {
        return @"Enter a name for this folder.";
    }
    else if (textInputViewControllerMode == kTextInputViewControllerModeRenameFolder) {
        return @"Enter a new name for this folder.";
    }
    else {
        return @"Enter a new name for this archive.";
    }
}

- (NSString *)textInputNavigationControllerPlaceholder {
    return NSLocalizedString(@"ADD_PLAYLIST_TITLE_PLACEHOLDER", @"");
}

- (NSString *)textInputNavigationControllerDefaultText {
    if (textInputViewControllerMode == kTextInputViewControllerModeRenameFolder) {
        return renameDirectory.name;
    }
    else if (textInputViewControllerMode == kTextInputViewControllerModeRenameArchive) {
        return renameArchive.fileName;
    }
    return nil;
}

- (void)textInputNavigationControllerDidCancel {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)textInputNavigationControllerDidReceiveTextInput:(NSString *)text {
    if (textInputViewControllerMode == kTextInputViewControllerModeAddFolder) {
        if ([[DataManager sharedDataManager]createDirectoryWithName:text parentDirectory:[((FilesViewController *)self).delegate filesViewControllerParentDirectory]]) {
            [self safelyDismissModalViewControllerAnimated:YES completion:nil];
        }
    }
    else if (textInputViewControllerMode == kTextInputViewControllerModeRenameFolder) {
        if ([[DataManager sharedDataManager]renameDirectory:renameDirectory newName:text]) {
            [self safelyDismissModalViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        if ([[DataManager sharedDataManager]renameArchive:renameArchive newName:text]) {
            [self safelyDismissModalViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)normalize {
    if (mode == kVisibilityViewControllerModeEdit) {
        [self exitEditMode];
    }
    else if (mode == kVisibilityViewControllerModeMultiEdit) {
        [self exitMultiEditMode];
    }
    else if (mode == kVisibilityViewControllerModeMove) {
        [self exitMoveMode];
    }
    
    if (searching) {
        [self exitSearchMode];
    }
}

- (void)editBarEditButtonPressed {
    // This prevents the user from pressing multiple buttons at once.
    if ((mode != kVisibilityViewControllerModeEdit) && (mode != kVisibilityViewControllerModeMultiEdit) && (mode != kVisibilityViewControllerModeMove)) {
        // The mode must be set before the table view is reloaded in order for it to reload the content properly.
        mode = kVisibilityViewControllerModeEdit;
        
        // The table view must be reloaded before the bar button items are updated because if the user has swiped a row to delete it, it will register as finishing editing when the table view is reloaded, setting the right bar button item to the now playing button when it should actually be the done button.
        // Setting the done button here ensures that the now playing button will be replaced, rather than the now playing button replacing the done button if it's set later on.
        [self.tableView reloadData];
        
        self.navigationItem.titleView = nil;
        self.navigationItem.title = previousTitle;
        self.navigationItem.hidesBackButton = YES;
        previousRightBarButtonItem = self.navigationItem.rightBarButtonItem;
        [self.navigationItem safelySetRightBarButtonItemAnimated:editBarEditDoneButton];
        
        if (([self isKindOfClass:[FilesViewController class]]) && (!searching)) {
            [filesEditBar setEditing:YES];
        }
        else {
            [self collapseEditBarAnimated];
        }
        
        self.tableView.tableHeaderView = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerModeDidChangeNotification object:nil];
        
        if ([self.searchBar.text length] <= 0) {
            [self.searchBar setShowsCancelButton:NO animated:YES];
            [self.searchBar resignFirstResponder];
            
            self.tableView.scrollEnabled = YES;
            
            if (shadowView.alpha > 0) {
                shadowView.alpha = 0;
            }
        }
        
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)editBarEditDoneButtonPressed {
    [self exitEditMode];
}

- (void)exitEditMode {
    if (([self isKindOfClass:[FilesViewController class]]) || ([self isKindOfClass:[PlaylistsViewController class]])) {
        // Save the context in case the custom order has been changed.
        // The context is saved here because it causes appearance problems when it is saved immediately after the table view is manually reordered.
        [[DataManager sharedDataManager]saveContext];
    }
    
    if ([self isKindOfClass:[FilesViewController class]]) {
        [filesEditBar setEditing:NO];
    }
    
    self.navigationItem.prompt = nil;
    self.navigationItem.titleView = titleView;
    titleView.hidden = NO;
    arrowImageView.hidden = NO;
    self.navigationItem.hidesBackButton = NO;
    [self.navigationItem safelySetRightBarButtonItemAnimated:previousRightBarButtonItem];
    [self expandEditBarAnimated];
    self.tableView.tableHeaderView = self.searchBar;
    searching = ([self.searchBar.text length] > 0);
    playlistsEditBar.hidden = searching;
    filesEditBar.hidden = searching;
    mode = kVisibilityViewControllerModeNone;
    [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerModeDidChangeNotification object:nil];
    [self.tableView reloadData];
    [self.tableView setEditing:NO animated:YES];
}

- (void)editBarMultiEditButtonPressed {
    // This prevents the user from pressing multiple buttons at once.
    if ((mode != kVisibilityViewControllerModeEdit) && (mode != kVisibilityViewControllerModeMultiEdit) && (mode != kVisibilityViewControllerModeMove)) {
        // The mode must be set before the table view is reloaded in order for it to reload the content properly.
        mode = kVisibilityViewControllerModeMultiEdit;
        
        // The table view must be reloaded before the bar button items are updated because if the user has swiped a row to delete it, it will register as finishing editing when the table view is reloaded, setting the right bar button item to the now playing button when it should actually be the done button.
        // Setting the done button here ensures that the now playing button will be replaced, rather than the now playing button replacing the done button if it's set later on.
        [self.tableView reloadData];
        
        self.navigationItem.prompt = @"Select one or more items to edit.";
        self.navigationItem.titleView = nil;
        self.navigationItem.title = previousTitle;
        titleView.hidden = YES;
        arrowImageView.hidden = YES;
        previousLeftBarButtonItem = self.navigationItem.leftBarButtonItem;
        previousRightBarButtonItem = self.navigationItem.rightBarButtonItem;
        [self.navigationItem safelySetLeftBarButtonItemAnimated:editBarMultiEditCancelButton];
        [self.navigationItem safelySetRightBarButtonItemAnimated:editBarMultiEditDoneButton];
        [self collapseEditBar];
        self.tableView.tableHeaderView = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerModeDidChangeNotification object:nil];
        
        if ([self.searchBar.text length] <= 0) {
            [self.searchBar setShowsCancelButton:NO animated:YES];
            [self.searchBar resignFirstResponder];
            
            self.tableView.scrollEnabled = YES;
            
            if (shadowView.alpha > 0) {
                shadowView.alpha = 0;
            }
        }
    }
}

- (void)editBarMultiEditCancelButtonPressed {
    [self exitMultiEditMode];
}

- (void)editBarMultiEditDoneButtonPressed {
    if ([selectedFilesArray count] > 0) {
        OptionsActionSheetHandler *handler = [OptionsActionSheetHandler sharedHandler];
        handler.delegate = self;
        [handler presentOptionsActionSheetForMultipleFiles:selectedFilesArray fromBarButtonItem:self.navigationItem.rightBarButtonItem searchString:nil canDelete:YES];
    }
    else {
        [self exitMultiEditMode];
    }
}

- (void)optionsActionSheetHandlerDidFinish {
    [self exitMultiEditMode];
}

- (void)exitMultiEditMode {
    [[OptionsActionSheetHandler sharedHandler]dismissOptionsActionSheetIfApplicable];
    self.navigationItem.prompt = nil;
    self.navigationItem.titleView = titleView;
    titleView.hidden = NO;
    arrowImageView.hidden = NO;
    [self.navigationItem safelySetLeftBarButtonItemAnimated:previousLeftBarButtonItem];
    [self.navigationItem safelySetRightBarButtonItemAnimated:previousRightBarButtonItem];
    [self expandEditBar];
    self.tableView.tableHeaderView = self.searchBar;
    searching = ([self.searchBar.text length] > 0);
    playlistsEditBar.hidden = searching;
    filesEditBar.hidden = searching;
    mode = kVisibilityViewControllerModeNone;
    [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerModeDidChangeNotification object:nil];
    [selectedItemsArray removeAllObjects];
    [selectedFilesArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)editBarMoveButtonPressed {
    // This prevents the user from pressing multiple buttons at once.
    if ((mode != kVisibilityViewControllerModeEdit) && (mode != kVisibilityViewControllerModeMultiEdit) && (mode != kVisibilityViewControllerModeMove)) {
        // The mode must be set before the table view is reloaded in order for it to reload the content properly.
        mode = kVisibilityViewControllerModeMove;
        
        // The table view must be reloaded before the bar button items are updated because if the user has swiped a row to delete it, it will register as finishing editing when the table view is reloaded, setting the right bar button item to the now playing button when it should actually be the done button.
        // Setting the done button here ensures that the now playing button will be replaced, rather than the now playing button replacing the done button if it's set later on.
        [self.tableView reloadData];
        
        self.navigationItem.prompt = @"Select files or folders to move.";
        self.navigationItem.titleView = nil;
        self.navigationItem.title = previousTitle;
        titleView.hidden = YES;
        arrowImageView.hidden = YES;
        previousLeftBarButtonItem = self.navigationItem.leftBarButtonItem;
        previousRightBarButtonItem = self.navigationItem.rightBarButtonItem;
        [self.navigationItem safelySetLeftBarButtonItemAnimated:editBarMoveCancelButton];
        [self.navigationItem safelySetRightBarButtonItemAnimated:editBarMoveDoneButton];
        [self collapseEditBar];
        self.tableView.tableHeaderView = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerModeDidChangeNotification object:nil];
        
        if ([self.searchBar.text length] <= 0) {
            [self.searchBar setShowsCancelButton:NO animated:YES];
            [self.searchBar resignFirstResponder];
            
            self.tableView.scrollEnabled = YES;
            
            if (shadowView.alpha > 0) {
                shadowView.alpha = 0;
            }
        }
    }
}

- (void)editBarMoveCancelButtonPressed {
    [self exitMoveMode];
}

- (void)editBarMoveDoneButtonPressed {
    if ([selectedItemsArray count] > 0) {
        MoveItemsNavigationController *moveItemsNavigationController = [[MoveItemsNavigationController alloc]initWithItems:selectedItemsArray];
        moveItemsNavigationController.moveItemsNavigationControllerDelegate = self;
        [self safelyPresentModalViewController:moveItemsNavigationController animated:YES completion:nil];
    }
    
    // This is functionally equivalent.
    [self exitMultiEditMode];
}

- (void)exitMoveMode {
    // This is functionally equivalent.
    [self exitMultiEditMode];
}

- (void)moveItemsNavigationControllerDidCancel {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)moveItemsNavigationControllerDidFinishMovingItems {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonPressed {
    [self.navigationItem safelySetRightBarButtonItemAnimated:nowPlayingButton];
    [self.tableView setEditing:NO animated:YES];
}

- (void)renameDirectory:(Directory *)directory {
    renameDirectory = directory;
    
    textInputViewControllerMode = kTextInputViewControllerModeRenameFolder;
    
    TextInputNavigationController *textInputNavigationController = [[TextInputNavigationController alloc]init];
    textInputNavigationController.textInputNavigationControllerDelegate = self;
    [self safelyPresentModalViewController:textInputNavigationController animated:YES completion:nil];
}

- (void)renameArchive:(Archive *)archive {
    renameArchive = archive;
    
    textInputViewControllerMode = kTextInputViewControllerModeRenameArchive;
    
    TextInputNavigationController *textInputNavigationController = [[TextInputNavigationController alloc]init];
    textInputNavigationController.textInputNavigationControllerDelegate = self;
    [self safelyPresentModalViewController:textInputNavigationController animated:YES completion:nil];
}

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
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
    
    selectedItemsArray = [[NSMutableArray alloc]init];
    selectedFilesArray = [[NSMutableArray alloc]init];
    
    cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    editBarEditDoneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editBarEditDoneButtonPressed)];
    editBarMultiEditCancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editBarMultiEditCancelButtonPressed)];
    editBarMultiEditDoneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editBarMultiEditDoneButtonPressed)];
    editBarMoveCancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editBarMoveCancelButtonPressed)];
    editBarMoveDoneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editBarMoveDoneButtonPressed)];
    
    shadowView = [[UIView alloc]initWithFrame:self.view.bounds];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = 0;
    [self.view addSubview:shadowView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shadowViewTapped)];
    [shadowView addGestureRecognizer:tapGestureRecognizer];
    
    searchController = [[SearchController alloc]init];
    searchController.delegate = self;
    
    if (![self isPlaylistsDetailViewController]) {
        CGRect editBarFrame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        
        StandardEditBar *standardEditBar = [[StandardEditBar alloc]initWithFrame:editBarFrame];
        [standardEditBar.editButton addTarget:self action:@selector(editBarEditButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [standardEditBar.multiEditButton addTarget:self action:@selector(editBarMultiEditButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:standardEditBar atIndex:0];
        
        if (([self isKindOfClass:[PlaylistsViewController class]]) || ([self isKindOfClass:[DownloadsViewController class]])) {
            playlistsEditBar = [[PlaylistsEditBar alloc]initWithFrame:editBarFrame];
            [playlistsEditBar.editButton addTarget:self action:@selector(editBarEditButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.view insertSubview:playlistsEditBar atIndex:1];
        }
        else if ([self isKindOfClass:[FilesViewController class]]) {
            filesEditBar = [[FilesEditBar alloc]initWithFrame:editBarFrame];
            [filesEditBar.addFolderButton addTarget:self action:@selector(editBarAddFolderButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [filesEditBar.moveButton addTarget:self action:@selector(editBarMoveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [filesEditBar.editButton addTarget:self action:@selector(editBarEditButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [filesEditBar.multiEditButton addTarget:self action:@selector(editBarMultiEditButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.view insertSubview:filesEditBar atIndex:1];
        }
    }
    
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
        titleLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
        
        if ([self.tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
            [self.tableView setSectionIndexColor:[SkinManager iOS6SkinLightGrayColor]];
        }
        if ([self.tableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)]) {
            [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        }
        if ([self.tableView respondsToSelector:@selector(setSectionIndexTrackingBackgroundColor:)]) {
            [self.tableView setSectionIndexTrackingBackgroundColor:[SkinManager iOS6SkinTableViewSectionIndexTrackingBackgroundColor]];
        }
    }
    else {
        if ([SkinManager iOS7Skin]) {
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.shadowColor = nil;
        }
        else {
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.shadowColor = [UIColor colorWithWhite:0.2 alpha:1];
                titleLabel.shadowOffset = CGSizeMake(0, -1);
            }
            else {
                titleLabel.textColor = [UIColor colorWithRed:(94.0 / 255.0) green:(101.0 / 255.0) blue:(109.0 / 255.0) alpha:1];
                titleLabel.shadowColor = [UIColor whiteColor];
            }
        }
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundColor = [UIColor whiteColor];
        
        if ([self.tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
            [self.tableView setSectionIndexColor:nil];
        }
        if ([self.tableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)]) {
            [self.tableView setSectionIndexBackgroundColor:nil];
        }
        if ([self.tableView respondsToSelector:@selector(setSectionIndexTrackingBackgroundColor:)]) {
            [self.tableView setSectionIndexTrackingBackgroundColor:nil];
        }
    }
    
    // This makes the background less noticeable when the banner view is animating.
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([searchBar.text length] <= 0) {
        // Hide the table view section index titles.
        [self.tableView reloadData];
        
        [self.searchBar setShowsCancelButton:YES animated:YES];
        self.tableView.scrollEnabled = NO;
        [UIView animateWithDuration:0.25 animations:^{
            shadowView.alpha = 0.5;
        }];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([searchBar.text length] <= 0) {
        // Show the table view section index titles.
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self exitSearchMode];
}

- (void)exitSearchMode {
    if (searching) {
        searching = NO;
        playlistsEditBar.hidden = NO;
        filesEditBar.hidden = NO;
        
        self.tableView.dataSource = previousTableViewDataSource;
        self.tableView.delegate = previousTableViewDelegate;
        self.tableView.tableFooterView = previousTableViewFooter;
        self.tableView.rowHeight = previousTableViewRowHeight;
        
        [searchController didFinishSearching];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerDidFinishSearchingNotification object:nil];
        
        [self.tableView reloadData];
    }
    
    self.searchBar.text = nil;
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    
    self.tableView.scrollEnabled = YES;
    
    if (shadowView.alpha > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            shadowView.alpha = 0;
        }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0) {
        self.tableView.scrollEnabled = YES;
        shadowView.alpha = 0;
        
        if (!searching) {
            searching = YES;
            playlistsEditBar.hidden = YES;
            filesEditBar.hidden = YES;
            
            previousTableViewDataSource = self.tableView.dataSource;
            previousTableViewDelegate = self.tableView.delegate;
            previousTableViewFooter = self.tableView.tableFooterView;
            previousTableViewRowHeight = self.tableView.rowHeight;
            
            self.tableView.dataSource = searchController;
            self.tableView.delegate = searchController;
            self.tableView.tableFooterView = nil;
            self.tableView.rowHeight = 44;
            
            [self.tableView reloadData];
        }
        
        [searchController updateSections];
        [self.tableView reloadData];
    }
    else {
        self.tableView.scrollEnabled = NO;
        shadowView.alpha = 0.5;
        
        if (searching) {
            searching = NO;
            playlistsEditBar.hidden = NO;
            filesEditBar.hidden = NO;
            
            self.tableView.dataSource = previousTableViewDataSource;
            self.tableView.delegate = previousTableViewDelegate;
            self.tableView.tableFooterView = previousTableViewFooter;
            self.tableView.rowHeight = previousTableViewRowHeight;
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kVisibilityViewControllerDidFinishSearchingNotification object:nil];
            
            [self.tableView reloadData];
        }
    }
}

- (void)shadowViewTapped {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    
    self.tableView.scrollEnabled = YES;
    
    if (shadowView.alpha > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            shadowView.alpha = 0;
        }];
    }
}

- (void)titleButtonPressed {
    if (self.tableView.frame.origin.y < 44) {
        [self expandEditBarAnimated];
    }
    else {
        [self collapseEditBarAnimated];
    }
}

- (void)expandEditBarAnimated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kShowEditBarKey];
    [defaults synchronize];
    
    if ([SkinManager iOS6Skin]) {
        arrowImageView.image = [UIImage imageNamed:@"Collapse-Gray-6"];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            arrowImageView.image = [UIImage imageNamed:@"Collapse-Black-7"];
        }
        else {
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                arrowImageView.image = [UIImage imageNamed:@"Collapse-White"];
            }
            else {
                arrowImageView.image = [UIImage imageNamed:@"Collapse-Gray"];
            }
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self expandEditBar];
    }];
}

- (void)expandEditBar {
    if ([[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewShown]) {
        self.tableView.frame = CGRectMake(0, 44, self.view.frame.size.width, (self.view.frame.size.height - (44 + [[[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewContainer]frame].size.height)));
        shadowView.frame = CGRectMake(0, 88, self.tableView.frame.size.width, (self.tableView.frame.size.height - 44));
    }
    else {
        self.tableView.frame = CGRectMake(0, 44, self.view.frame.size.width, (self.view.frame.size.height - 44));
        shadowView.frame = CGRectMake(0, 88, self.tableView.frame.size.width, (self.tableView.frame.size.height - 44));
    }
    
    NSInteger fontSize = 20;
    if (([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && (self.interfaceOrientation != UIInterfaceOrientationPortrait)) {
        fontSize = 16;
    }
    else if ([SkinManager iOS7]) {
        fontSize = 17;
    }
    titleView.frame = CGRectMake(self.navigationItem.titleView.frame.origin.x, self.navigationItem.titleView.frame.origin.y, [previousTitle sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]].width, self.navigationController.navigationBar.frame.size.height);
    titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
}

- (void)collapseEditBarAnimated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kShowEditBarKey];
    [defaults synchronize];
    
    if ([SkinManager iOS6Skin]) {
        arrowImageView.image = [UIImage imageNamed:@"Expand-Gray-6"];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            arrowImageView.image = [UIImage imageNamed:@"Expand-Black-7"];
        }
        else {
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                arrowImageView.image = [UIImage imageNamed:@"Expand-White"];
            }
            else {
                arrowImageView.image = [UIImage imageNamed:@"Expand-Gray"];
            }
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self collapseEditBar];
    }];
}

- (void)collapseEditBar {
    if ([[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewShown]) {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - [[[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewContainer]frame].size.height));
        shadowView.frame = CGRectMake(0, 44, self.tableView.frame.size.width, (self.tableView.frame.size.height - 44));
    }
    else {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        shadowView.frame = CGRectMake(0, 44, self.tableView.frame.size.width, (self.tableView.frame.size.height - 44));
    }
    
    NSInteger fontSize = 20;
    if (([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && (self.interfaceOrientation != UIInterfaceOrientationPortrait)) {
        fontSize = 16;
    }
    else if ([SkinManager iOS7]) {
        fontSize = 17;
    }
    titleView.frame = CGRectMake(self.navigationItem.titleView.frame.origin.x, self.navigationItem.titleView.frame.origin.y, [previousTitle sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]].width, self.navigationController.navigationBar.frame.size.height);
    titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
}

- (void)viewWillAppear:(BOOL)animated {
    viewIsVisible = YES;
    
    // iOS 7 appearance fix.
    // This must be called in -viewWillAppear: and will not work in -updateSkin.
    self.navigationController.navigationBar.translucent = NO;
    
    if (![self isPlaylistsDetailViewController]) {
        if (mode == kVisibilityViewControllerModeNone) {
            if (!titleView) {
                previousTitle = self.title;
                
                NSInteger fontSize = 20;
                if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
                    fontSize = 16;
                }
                else if ([SkinManager iOS7]) {
                    fontSize = 17;
                }
                
                titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self.title sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]].width, self.navigationController.navigationBar.frame.size.height)];
                titleView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                titleView.backgroundColor = [UIColor clearColor];
                
                UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
                titleButton.frame = CGRectMake(0, 0, titleView.frame.size.width, titleView.frame.size.height);
                titleButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                titleButton.backgroundColor = [UIColor clearColor];
                titleButton.showsTouchWhenHighlighted = YES;
                titleButton.adjustsImageWhenHighlighted = NO;
                [titleButton addTarget:self action:@selector(titleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                [titleView addSubview:titleButton];
                
                titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleView.frame.size.width, (titleView.frame.size.height - 10))];
                titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
                titleLabel.text = self.title;
                titleLabel.textAlignment = UITextAlignmentCenter;
                titleLabel.backgroundColor = [UIColor clearColor];
                
                if ([SkinManager iOS6Skin]) {
                    titleLabel.textColor = [SkinManager iOS6SkinDarkGrayColor];
                    titleLabel.shadowColor = [UIColor whiteColor];
                    titleLabel.shadowOffset = CGSizeMake(0, 1);
                }
                else {
                    if ([SkinManager iOS7Skin]) {
                        titleLabel.textColor = [UIColor blackColor];
                        titleLabel.shadowColor = nil;
                    }
                    else {
                        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                            titleLabel.textColor = [UIColor whiteColor];
                            titleLabel.shadowColor = [UIColor colorWithWhite:0.2 alpha:1];
                            titleLabel.shadowOffset = CGSizeMake(0, -1);
                        }
                        else {
                            titleLabel.textColor = [UIColor colorWithRed:(94.0 / 255.0) green:(101.0 / 255.0) blue:(109.0 / 255.0) alpha:1];
                            titleLabel.shadowColor = [UIColor whiteColor];
                        }
                    }
                }
                
                [titleView addSubview:titleLabel];
                
                arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(((titleView.frame.size.width / 2.0) - 6), (titleView.frame.size.height - 12), 11, 7)];
                arrowImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
                arrowImageView.contentMode = UIViewContentModeCenter;
                [titleView addSubview:arrowImageView];
                
                self.navigationItem.titleView = titleView;
            }
        }
        
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kShowEditBarKey]) {
            if ([SkinManager iOS6Skin]) {
                arrowImageView.image = [UIImage imageNamed:@"Collapse-Gray-6"];
            }
            else {
                if ([SkinManager iOS7Skin]) {
                    arrowImageView.image = [UIImage imageNamed:@"Collapse-Black-7"];
                }
                else {
                    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        arrowImageView.image = [UIImage imageNamed:@"Collapse-White"];
                    }
                    else {
                        arrowImageView.image = [UIImage imageNamed:@"Collapse-Gray"];
                    }
                }
            }
            
            [self expandEditBar];
        }
        else {
            if ([SkinManager iOS6Skin]) {
                arrowImageView.image = [UIImage imageNamed:@"Expand-Gray-6"];
            }
            else {
                if ([SkinManager iOS7Skin]) {
                    arrowImageView.image = [UIImage imageNamed:@"Expand-Black-7"];
                }
                else {
                    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        arrowImageView.image = [UIImage imageNamed:@"Expand-White"];
                    }
                    else {
                        arrowImageView.image = [UIImage imageNamed:@"Expand-Gray"];
                    }
                }
            }
            
            [self collapseEditBar];
        }
    }
    
    [self updateFrames];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // For some reason, elements don't always display properly if they are updated when -viewWillAppear: is called, so they have to be updated here instead.
    [self updateFrames];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    viewIsVisible = NO;
    
    // This facilitates normalization when the back button is pressed in the more navigation controller, but prevents normalization from occurring when this method is called in response to a new view controller being pushed onto the stack (respectively).
    
    // When the back button is pressed in the more navigation controller and there is only one view controller (other than the system root view controller) on the stack, self.navigationController will be nil.
    // When switching tabs, self.navigationController.topViewController will be self, but this will not be the case when a new view controller is pushed onto the stack (such as a child view controller or the player view controller).
    if ((!self.navigationController) || ([self.navigationController.topViewController isEqual:self])) {
        // This prevents normalization from occurring when a modal view controller is presented from the current view (such as the multiple tag editor view controller).
        if (![self safeModalViewController]) {
            // Again, when the back button is pressed in the more navigation controller and there is only one view controller (other than the system root view controller) on the stack, self.navigationController will be nil.
            // Because self.navigationController can be nil, self.navigationController.viewControllers can be nil, so the loop below cannot be used to normalize self as well as the other view controllers.
            // To resolve this problem, self is normalized here and checked in the loop below to prevent double-normalization (more efficient).
            // The VisibilityViewController class test is conducted before the view controller is checked for equality with respect to self because it is less likely that a given view controller will pass the VisibilityViewController class test as opposed to the non-self test (again, more efficient).
            [self normalize];
            
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[VisibilityViewController class]]) {
                    if (![viewController isEqual:self]) {
                        // This prevents search mode from persisting if a number of view controllers are pushed onto the stack from a search query in the first view controller, then normalized.
                        [(VisibilityViewController *)viewController normalize];
                    }
                }
            }
            
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
    
    [super viewDidDisappear:animated];
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
    // This prevents memory management issues introduced in iOS 7.
    self.searchBar.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    searchController = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
