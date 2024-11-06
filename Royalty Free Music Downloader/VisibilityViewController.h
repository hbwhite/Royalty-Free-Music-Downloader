//
//  VisibilityViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextInputNavigationControllerDelegate.h"
#import "SearchControllerDelegate.h"
#import "SongSelectorDelegate.h"
#import "MoveItemsNavigationControllerDelegate.h"
#import "OptionsActionSheetHandlerDelegate.h"

@class NowPlayingButton;
@class SearchController;
@class PlaylistsEditBar;
@class FilesEditBar;
@class Directory;
@class Archive;
@class File;

#define kVisibilityViewControllerModeDidChangeNotification      @"Visibility View Controller Mode Did Change"
#define kVisibilityViewControllerDidFinishSearchingNotification @"Visibility View Controller Did Finish Searching"

enum {
    kVisibilityViewControllerModeNone = 0,
    kVisibilityViewControllerModeEdit,
    kVisibilityViewControllerModeMultiEdit,
    kVisibilityViewControllerModeMove,
    kVisibilityViewControllerModeAddToPlaylist
};
typedef NSUInteger kVisibilityViewControllerMode;

enum {
    kTextInputViewControllerModeAddFolder = 0,
    kTextInputViewControllerModeRenameFolder,
    kTextInputViewControllerModeRenameArchive
};
typedef NSUInteger kTextInputViewControllerMode;

@interface VisibilityViewController : UIViewController  <UISearchBarDelegate, UIActionSheetDelegate, TextInputNavigationControllerDelegate, SearchControllerDelegate, MoveItemsNavigationControllerDelegate, OptionsActionSheetHandlerDelegate> {
@public
    id <SongSelectorDelegate> __unsafe_unretained songSelectorDelegate;
    UIBarButtonItem *previousLeftBarButtonItem;
    UIBarButtonItem *previousRightBarButtonItem;
    PlaylistsEditBar *playlistsEditBar;
    FilesEditBar *filesEditBar;
    NSMutableArray *selectedItemsArray;
    NSMutableArray *selectedFilesArray;
    kVisibilityViewControllerMode mode;
    BOOL searching;
    BOOL viewIsVisible;
@private
    // This is necessary to use self.tableView in VisibilityViewController subclasses, which is necessary because the default UITableViewDataSource and UITableViewDelegate methods give the table view variable the name "tableView" as well.
    UITableView *_tableView;
    UISearchBar *_searchBar;
    NowPlayingButton *nowPlayingButton;
    UIBarButtonItem *cancelButton;
    SearchController *searchController;
    NSString *previousTitle;
    UIView *titleView;
    UILabel *titleLabel;
    UIImageView *arrowImageView;
    UIBarButtonItem *editBarEditDoneButton;
    UIBarButtonItem *editBarMultiEditCancelButton;
    UIBarButtonItem *editBarMultiEditDoneButton;
    UIBarButtonItem *editBarMoveCancelButton;
    UIBarButtonItem *editBarMoveDoneButton;
    UIView *shadowView;
    id <UITableViewDataSource> __unsafe_unretained previousTableViewDataSource;
    id <UITableViewDelegate> __unsafe_unretained previousTableViewDelegate;
    UIView *previousTableViewFooter;
    CGFloat previousTableViewRowHeight;
    Directory *renameDirectory;
    Archive *renameArchive;
    kTextInputViewControllerMode textInputViewControllerMode;
}

@property (nonatomic, unsafe_unretained) id <SongSelectorDelegate> songSelectorDelegate;
@property (nonatomic, strong) UIBarButtonItem *previousLeftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *previousRightBarButtonItem;
@property (nonatomic, strong) PlaylistsEditBar *playlistsEditBar;
@property (nonatomic, strong) FilesEditBar *filesEditBar;
@property (nonatomic, strong) NSMutableArray *selectedItemsArray;
@property (nonatomic, strong) NSMutableArray *selectedFilesArray;
@property (nonatomic) kVisibilityViewControllerMode mode;
@property (readwrite) BOOL searching;
@property (readwrite) BOOL viewIsVisible;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

- (id)initWithDelegate:(id)delegate;
- (void)normalize;
- (void)renameDirectory:(Directory *)directory;
- (void)renameArchive:(Archive *)archive;

@end
