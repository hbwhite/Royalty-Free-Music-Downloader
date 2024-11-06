//
//  PlaylistsDetailViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "PlaylistsDetailViewController.h"
#import "VisibilityViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "DataManager.h"
#import "PlaylistItem.h"
#import "File.h"
#import "Album.h"
#import "Artist.h"
#import "Playlist.h"
#import "SongCell.h"
#import "ShuffleCell.h"
#import "PlayerViewController.h"
#import "PlaylistEditOptionsCell.h"
#import "Player.h"
#import "StandardCell.h"
#import "SkinManager.h"
#import "MBProgressHUD.h"
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface PlaylistsDetailViewController ()

@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UILabel *songCountLabel;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)nowPlayingFileDidChange;
- (void)didFinishSearching;
- (void)addButtonPressed;
- (void)presentAddToPlaylistViewController;
- (void)updateSongCountLabel;
- (void)playlistEditOptionsCellEditButtonPressed;
- (void)playlistEditOptionsCellClearButtonPressed;
- (void)playlistEditOptionsCellDeleteButtonPressed;
- (void)playlistEditOptionsCellDoneButtonPressed;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PlaylistsDetailViewController

// Public
@synthesize delegate;

// Private
@synthesize addButton;
@synthesize searchBar;
@synthesize fetchedResultsController;
@synthesize songCountLabel;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(groupByAlbumArtistPreferenceDidChange) name:kGroupByAlbumArtistPreferenceDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(nowPlayingFileDidChange) name:kPlayerNowPlayingFileDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didFinishSearching) name:kVisibilityViewControllerDidFinishSearchingNotification object:nil];
    
    addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
    
    songCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    songCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    songCountLabel.font = [UIFont systemFontOfSize:20];
    songCountLabel.textAlignment = UITextAlignmentCenter;
    songCountLabel.textColor = [UIColor grayColor];
    songCountLabel.backgroundColor = [UIColor clearColor];
    if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
        [self updateSongCountLabel];
        self.tableView.tableFooterView = songCountLabel;
    }
}

- (void)groupByAlbumArtistPreferenceDidChange {
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)nowPlayingFileDidChange {
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)didFinishSearching {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
            [self updateSongCountLabel];
            self.tableView.tableFooterView = songCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    });
}

- (void)addButtonPressed {
    // This can be a time-consuming process, so I have included a HUD to indicate that the app is loading.
    
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:window];
    hud.dimBackground = YES;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
    [window addSubview:hud];
    [hud showWhileExecuting:@selector(presentAddToPlaylistViewController) onTarget:self withObject:nil animated:YES];
}

- (void)presentAddToPlaylistViewController {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        AddToPlaylistViewController *addToPlaylistViewController = [[AddToPlaylistViewController alloc]initWithDelegate:self];
        [self safelyPresentModalViewController:addToPlaylistViewController animated:YES completion:nil];
    });
}

- (void)updateSongCountLabel {
    songCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LISTING_COUNT_SONGS_FORMAT", @""), [[[self fetchedResultsController]fetchedObjects]count]];
}

- (Playlist *)addToPlaylistViewControllerPlaylist {
    return [delegate playlistsDetailViewControllerPlaylist];
}

- (void)addToPlaylistViewControllerDidSelectFiles:(NSArray *)files {
    Playlist *playlist = [delegate playlistsDetailViewControllerPlaylist];
    DataManager *dataManager = [DataManager sharedDataManager];
    NSManagedObjectContext *managedObjectContext = [dataManager managedObjectContext];
    
    NSInteger startIndex = 0;
    
    NSArray *playlistItemsArray = [[self fetchedResultsController]fetchedObjects];
    if ([playlistItemsArray count] > 0) {
        startIndex = ([[[playlistItemsArray lastObject]index]integerValue] + 1);
    }
    
    for (int i = 0; i < [files count]; i++) {
        File *file = [files objectAtIndex:i];
        
        PlaylistItem *playlistItem = [[PlaylistItem alloc]initWithEntity:[NSEntityDescription entityForName:@"PlaylistItem" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
        playlistItem.index = [NSNumber numberWithInteger:(startIndex + i)];
        playlistItem.fileRef = [files objectAtIndex:i];
        playlistItem.playlistRef = playlist;
        
        [file addPlaylistItemRefsObject:playlistItem];
        
        [[delegate playlistsDetailViewControllerPlaylist]addPlaylistItemsObject:playlistItem];
    }
    [dataManager saveContext];
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
    if (section == 0) {
        if ((mode == kVisibilityViewControllerModeNone) || (mode == kVisibilityViewControllerModeEdit)) {
            return 1;
        }
    }
    else {
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        if (section == 1) {
            if ([currentFetchedResultsController.fetchedObjects count] > 1) {
                if (mode != kVisibilityViewControllerModeEdit) {
                    return 1;
                }
            }
        }
        else {
            id <NSFetchedResultsSectionInfo> sectionInfo = [currentFetchedResultsController.sections objectAtIndex:0];
            return [sectionInfo numberOfObjects];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell 1";
        
        PlaylistEditOptionsCell *cell = (PlaylistEditOptionsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PlaylistEditOptionsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        [cell.editButton addTarget:self action:@selector(playlistEditOptionsCellEditButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [cell.clearButton addTarget:self action:@selector(playlistEditOptionsCellClearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteButton addTarget:self action:@selector(playlistEditOptionsCellDeleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [cell.doneButton addTarget:self action:@selector(playlistEditOptionsCellDoneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setEditing:tableView.editing];
        
        return cell;
    }
    else if (indexPath.section == 1) {
        if (mode == kVisibilityViewControllerModeAddToPlaylist) {
            static NSString *CellIdentifier = @"Cell 2";
            
            StandardCell *cell = (StandardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[StandardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell configure];
            
            // Configure the cell...
            
            cell.textLabel.text = NSLocalizedString(@"Add All Songs", @"");
            
            UIImageView *addButtonAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 29, 29)];
            addButtonAccessoryView.contentMode = UIViewContentModeCenter;
            addButtonAccessoryView.image = [UIImage iOS7SkinImageNamed:@"Add_Button"];
            addButtonAccessoryView.highlightedImage = [UIImage iOS7SkinImageNamed:@"Add_Button-Selected"];
            cell.accessoryView = addButtonAccessoryView;
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Cell 3";
            
            ShuffleCell *cell = (ShuffleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[ShuffleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell configure];
            
            // Configure the cell...
            
            cell.textLabel.text = NSLocalizedString(@"Shuffle", @"");
            
            return cell;
        }
    }
    else {
        static NSString *CellIdentifier = @"Cell 4";
        
        SongCell *cell = (SongCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SongCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
}

- (void)playlistEditOptionsCellEditButtonPressed {
    previousLeftBarButtonItem = self.navigationItem.leftBarButtonItem;
    previousRightBarButtonItem = self.navigationItem.rightBarButtonItem;
    [self.navigationItem safelySetLeftBarButtonItemAnimated:addButton];
    [self.navigationItem safelySetRightBarButtonItemAnimated:nil];
    mode = kVisibilityViewControllerModeEdit;
    searchBar = (UISearchBar *)self.tableView.tableHeaderView;
    self.tableView.tableHeaderView = nil;
    [self.tableView reloadData];
    [self.tableView setEditing:YES animated:YES];
}

- (void)playlistEditOptionsCellClearButtonPressed {
    UIActionSheet *clearPlaylistActionSheet = [[UIActionSheet alloc]
                                               initWithTitle:nil
                                               delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle:NSLocalizedString(@"Clear Playlist", @"")
                                               otherButtonTitles:nil];
    clearPlaylistActionSheet.tag = 0;
    clearPlaylistActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [clearPlaylistActionSheet showInView:self.tabBarController.view];
}

- (void)playlistEditOptionsCellDeleteButtonPressed {
    UIActionSheet *deletePlaylistActionSheet = [[UIActionSheet alloc]
                                                initWithTitle:nil
                                                delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                destructiveButtonTitle:NSLocalizedString(@"Delete Playlist", @"")
                                                otherButtonTitles:nil];
    deletePlaylistActionSheet.tag = 1;
    deletePlaylistActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [deletePlaylistActionSheet showInView:self.tabBarController.view];
}

- (void)playlistEditOptionsCellDoneButtonPressed {
    // The context is saved here because it causes appearance problems when it is saved immediately after the table view is manually reordered.
    [[DataManager sharedDataManager]saveContext];
    
    self.navigationItem.leftBarButtonItem = previousLeftBarButtonItem;
    self.navigationItem.rightBarButtonItem = previousRightBarButtonItem;
    mode = kVisibilityViewControllerModeNone;
    self.tableView.tableHeaderView = searchBar;
    [self.tableView reloadData];
    [self.tableView setEditing:NO animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        DataManager *dataManager = [DataManager sharedDataManager];
        
        if (actionSheet.tag == 0) {
            [dataManager clearPlaylist:[delegate playlistsDetailViewControllerPlaylist]];
        }
        else if (actionSheet.tag == 1) {
            [dataManager deletePlaylist:[delegate playlistsDetailViewControllerPlaylist]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    return (indexPath.section > 1);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        PlaylistItem *playlistItem = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [[DataManager sharedDataManager]deletePlaylistItem:playlistItem];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (![fromIndexPath isEqual:toIndexPath]) {
        NSArray *fetchedObjects = [[self fetchedResultsController]fetchedObjects];
		if (fromIndexPath.row < toIndexPath.row) {
			for (int i = 1; i <= (toIndexPath.row - fromIndexPath.row); i++) {
                NSInteger index = (fromIndexPath.row + i);
                PlaylistItem *playlistItem = [fetchedObjects objectAtIndex:index];
                playlistItem.index = [NSNumber numberWithInteger:(index - 1)];
			}
            
            PlaylistItem *movedPlaylistItem = [fetchedObjects objectAtIndex:fromIndexPath.row];
            movedPlaylistItem.index = [NSNumber numberWithInteger:toIndexPath.row];
		}
		else {
            PlaylistItem *movedPlaylistItem = [fetchedObjects objectAtIndex:fromIndexPath.row];
            movedPlaylistItem.index = [NSNumber numberWithInteger:toIndexPath.row];
            
			for (int i = toIndexPath.row; i < fromIndexPath.row; i++) {
				PlaylistItem *playlistItem = [fetchedObjects objectAtIndex:i];
				playlistItem.index = [NSNumber numberWithInteger:(i + 1)];
			}
		}
	}
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return (indexPath.section == 2);
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section < 2) {
        return [NSIndexPath indexPathForRow:0 inSection:2];
    }
    return proposedDestinationIndexPath;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section > 0) {
        if (mode == kVisibilityViewControllerModeNone) {
            Player *player = [Player sharedPlayer];
            NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
            
            NSMutableArray *filesArray = [NSMutableArray arrayWithObjects:nil];
            NSArray *playlistItemsArray = currentFetchedResultsController.fetchedObjects;
            for (int i = 0; i < [playlistItemsArray count]; i++) {
                [filesArray addObject:[[playlistItemsArray objectAtIndex:i]fileRef]];
            }
            [player setPlaylistItems:filesArray];
            
            if (indexPath.section == 1) {
                [player shuffle];
            }
            else {
                [player setCurrentFileWithIndex:indexPath.row];
            }
            
            PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
            [self.navigationController pushViewController:playerViewController animated:YES];
        }
        else {
            if (indexPath.section == 1) {
                NSMutableArray *filesArray = [NSMutableArray arrayWithObjects:nil];
                NSArray *playlistItemsArray = [[self fetchedResultsController]fetchedObjects];
                for (int i = 0; i < [playlistItemsArray count]; i++) {
                    [filesArray addObject:[[playlistItemsArray objectAtIndex:i]fileRef]];
                }
                
                [songSelectorDelegate songSelectorDidSelectFiles:filesArray];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
            }
            else {
                File *file = [[[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]fileRef];
                [songSelectorDelegate songSelectorDidSelectFile:file];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaylistItem" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *indexSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"index" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:indexSortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playlistRef == %@", [delegate playlistsDetailViewControllerPlaylist]]];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return fetchedResultsController;
}

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self updateSongCountLabel];
    
    if (!searching) {
        [self.tableView reloadData];
        
        if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
            self.tableView.tableFooterView = songCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SongCell *songCell = (SongCell *)cell;
    
    File *file = [[[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]fileRef];
    
    songCell.textLabel.text = file.title;
    
    // The song's individual artist should be shown regardless of how the songs are grouped, so the artistRefForArtistGroup variable is always used.
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        songCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", file.albumRefForAlbumArtistGroup.name, file.artistRefForArtistGroup.name];
    }
    else {
        songCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", file.albumRefForArtistGroup.name, file.artistRefForArtistGroup.name];
    }
    
    if (mode == kVisibilityViewControllerModeAddToPlaylist) {
        UIImageView *addButtonAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 29, 29)];
        addButtonAccessoryView.contentMode = UIViewContentModeCenter;
        addButtonAccessoryView.image = [UIImage iOS7SkinImageNamed:@"Add_Button"];
        addButtonAccessoryView.highlightedImage = [UIImage iOS7SkinImageNamed:@"Add_Button-Selected"];
        cell.accessoryView = addButtonAccessoryView;
        
        if ([[songSelectorDelegate songSelectorSelectedFiles]containsObject:file]) {
            songCell.textLabel.alpha = (1.0 / 3.0);
            songCell.detailTextLabel.alpha = (2.0 / 3.0);
        }
        else {
            songCell.textLabel.alpha = 1;
            songCell.detailTextLabel.alpha = 1;
        }
        
        songCell.checkmarkOverlayView.hidden = YES;
    }
    else {
        if (mode == kVisibilityViewControllerModeEdit) {
            songCell.checkmarkOverlayView.hidden = YES;
        }
        else if (mode == kVisibilityViewControllerModeMultiEdit) {
            songCell.checkmarkOverlayView.hidden = ![selectedFilesArray containsObject:file];
        }
        else {
            songCell.checkmarkOverlayView.hidden = YES;
        }
        
        songCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    songCell.nowPlayingImageView.hidden = ![[[Player sharedPlayer]nowPlayingFile]isEqual:file];
}

- (void)dealloc {
    fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
