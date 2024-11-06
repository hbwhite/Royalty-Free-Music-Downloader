//
//  PlaylistsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "PlaylistsViewController.h"
#import "VisibilityViewController.h"
#import "TextInputNavigationController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "Playlist.h"
#import "PlaylistItem.h"
#import "File.h"
#import "SongsViewController.h"
#import "Top25MostPlayedViewController.h"
#import "MyTopRatedViewController.h"
#import "RecentlyPlayedViewController.h"
#import "RecentlyAddedViewController.h"
#import "StandardCell.h"
#import "MBProgressHUD.h"
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+SafeModal.h"

static NSString *kTop25MostPlayedSmartPlaylistEnabledKey    = @"Top 25 Most Played Smart Playlist Enabled";
static NSString *kMyTopRatedSmartPlaylistEnabledKey         = @"My Top Rated Smart Playlist Enabled";
static NSString *kRecentlyPlayedSmartPlaylistEnabledKey     = @"Recently Played Smart Playlist Enabled";
static NSString *kRecentlyAddedSmartPlaylistEnabledKey      = @"Recently Added Smart Playlist Enabled";

@interface PlaylistsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Playlist *selectedPlaylist;
@property (readwrite) BOOL addingPlaylist;

@property (nonatomic) kRowIdentifier row1ID;
@property (nonatomic) kRowIdentifier row2ID;
@property (nonatomic) kRowIdentifier row3ID;
@property (nonatomic) kRowIdentifier row4ID;

- (kRowIdentifier)identifierForRow:(NSInteger)row;
- (NSString *)titleForRowID:(kRowIdentifier)rowID;
- (NSString *)titleForRow:(NSInteger)row;
- (void)updateSections;
- (void)presentAddToPlaylistViewController;
- (void)pushPlaylistsDetailViewControllerAnimated:(BOOL)animated;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PlaylistsViewController

// Private
@synthesize fetchedResultsController;
@synthesize selectedPlaylist;
@synthesize addingPlaylist;

@synthesize row1ID;
@synthesize row2ID;
@synthesize row3ID;
@synthesize row4ID;

- (kRowIdentifier)identifierForRow:(NSInteger)row {
    kRowIdentifier rowID = 0;
    switch (row) {
        case 0:
            rowID = row1ID;
            break;
        case 1:
            rowID = row2ID;
            break;
        case 2:
            rowID = row3ID;
            break;
        case 3:
            rowID = row4ID;
            break;
    }
    return rowID;
}

- (NSString *)titleForRowID:(kRowIdentifier)rowID {
    switch (rowID) {
        case kRowIdentifierTop25MostPlayed:
            return @"Top 25 Most Played";
        case kRowIdentifierMyTopRated:
            return @"My Top Rated";
        case kRowIdentifierRecentlyPlayed:
            return @"Recently Played";
        case kRowIdentifierRecentlyAdded:
            return @"Recently Added";
        default:
            return nil;
    }
}

- (NSString *)titleForRow:(NSInteger)row {
    return [self titleForRowID:[self identifierForRow:row]];
}

- (void)updateSections {
    row1ID = kRowIdentifierNone;
    row2ID = kRowIdentifierNone;
    row3ID = kRowIdentifierNone;
    row4ID = kRowIdentifierNone;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kTop25MostPlayedSmartPlaylistEnabledKey]) {
        row1ID = kRowIdentifierTop25MostPlayed;
    }
    if ([defaults boolForKey:kMyTopRatedSmartPlaylistEnabledKey]) {
        if (row1ID == kRowIdentifierNone) {
            row1ID = kRowIdentifierMyTopRated;
        }
        else {
            row2ID = kRowIdentifierMyTopRated;
        }
    }
    if ([defaults boolForKey:kRecentlyPlayedSmartPlaylistEnabledKey]) {
        if (row1ID == kRowIdentifierNone) {
            row1ID = kRowIdentifierRecentlyPlayed;
        }
        else if (row2ID == kRowIdentifierNone) {
            row2ID = kRowIdentifierRecentlyPlayed;
        }
        else {
            row3ID = kRowIdentifierRecentlyPlayed;
        }
    }
    if ([defaults boolForKey:kRecentlyAddedSmartPlaylistEnabledKey]) {
        if (row1ID == kRowIdentifierNone) {
            row1ID = kRowIdentifierRecentlyAdded;
        }
        else if (row2ID == kRowIdentifierNone) {
            row2ID = kRowIdentifierRecentlyAdded;
        }
        else if (row3ID == kRowIdentifierNone) {
            row3ID = kRowIdentifierRecentlyAdded;
        }
        else {
            row4ID = kRowIdentifierRecentlyAdded;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateSections];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        if (row1ID == kRowIdentifierNone) {
            return @"Standard Playlists";
        }
        else {
            return @"Smart Playlists";
        }
    }
    else if (section == 2) {
        return @"Standard Playlists";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
    NSInteger sectionCount = 1;
    if (row1ID != kRowIdentifierNone) {
        sectionCount += 1;
    }
    if ([[[self fetchedResultsController]fetchedObjects]count] > 0) {
        sectionCount += 1;
    }
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
    if (section == 0) {
        if ((mode != kVisibilityViewControllerModeEdit) && (mode != kVisibilityViewControllerModeAddToPlaylist)) {
            return 1;
        }
    }
    else if (section == 1) {
        if (row1ID != kRowIdentifierNone) {
            NSInteger rowCount = 0;
            if (row1ID != kRowIdentifierNone) {
                rowCount += 1;
            }
            if (row2ID != kRowIdentifierNone) {
                rowCount += 1;
            }
            if (row3ID != kRowIdentifierNone) {
                rowCount += 1;
            }
            if (row4ID != kRowIdentifierNone) {
                rowCount += 1;
            }
            return rowCount;
        }
        else {
            NSArray *sections = [[self fetchedResultsController]sections];
            if ([sections count] > 0) {
                id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:0];
                return [sectionInfo numberOfObjects];
            }
        }
    }
    else {
        NSArray *sections = [[self fetchedResultsController]sections];
        if ([sections count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController]sections]objectAtIndex:0];
            return [sectionInfo numberOfObjects];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    StandardCell *cell = (StandardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[StandardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"ADD_PLAYLIST_ROW", @"");
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.section == 1) {
        if (row1ID != kRowIdentifierNone) {
            cell.textLabel.text = [self titleForRow:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryNone;
        }
        else {
            [self configureCell:cell atIndexPath:indexPath];
        }
    }
    else {
        [self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return ((mode != kVisibilityViewControllerModeAddToPlaylist) && (mode != kVisibilityViewControllerModeMultiEdit) && (indexPath.section > 0));
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        if (indexPath.section == 1) {
            if (row1ID == kRowIdentifierNone) {
                Playlist *playlist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
                [[DataManager sharedDataManager]deletePlaylist:playlist];
            }
            else {
                kRowIdentifier rowIdentifier = [self identifierForRow:indexPath.row];
                if (rowIdentifier != kRowIdentifierNone) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    if (rowIdentifier == kRowIdentifierTop25MostPlayed) {
                        [defaults setBool:NO forKey:kTop25MostPlayedSmartPlaylistEnabledKey];
                    }
                    else if (rowIdentifier == kRowIdentifierMyTopRated) {
                        [defaults setBool:NO forKey:kMyTopRatedSmartPlaylistEnabledKey];
                    }
                    else if (rowIdentifier == kRowIdentifierRecentlyPlayed) {
                        [defaults setBool:NO forKey:kRecentlyPlayedSmartPlaylistEnabledKey];
                    }
                    else {
                        [defaults setBool:NO forKey:kRecentlyAddedSmartPlaylistEnabledKey];
                    }
                    [defaults synchronize];
                    
                    [self updateSections];
                    [tableView reloadData];
                }
            }
        }
        else {
            Playlist *playlist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [[DataManager sharedDataManager]deletePlaylist:playlist];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
}
*/
/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    NSInteger sectionIndex = 1;
    if (row1ID != kRowIdentifierNone) {
        sectionIndex = 2;
    }
    
    if (proposedDestinationIndexPath.section < sectionIndex) {
        return [NSIndexPath indexPathForRow:0 inSection:sectionIndex];
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
    
    if (indexPath.section == 0) {
        addingPlaylist = YES;
        TextInputNavigationController *textInputNavigationController = [[TextInputNavigationController alloc]init];
        textInputNavigationController.textInputNavigationControllerDelegate = self;
        [self safelyPresentModalViewController:textInputNavigationController animated:YES completion:nil];
    }
    else if (indexPath.section == 1) {
        if (row1ID == kRowIdentifierNone) {
            selectedPlaylist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [self pushPlaylistsDetailViewControllerAnimated:YES];
        }
        else {
            kRowIdentifier rowID = [self identifierForRow:indexPath.row];
            if (rowID == kRowIdentifierTop25MostPlayed) {
                Top25MostPlayedViewController *top25MostPlayedViewController = [[Top25MostPlayedViewController alloc]init];
                top25MostPlayedViewController.songSelectorDelegate = songSelectorDelegate;
                top25MostPlayedViewController.title = [self titleForRowID:rowID];
                [self.navigationController pushViewController:top25MostPlayedViewController animated:YES];
            }
            else if (rowID == kRowIdentifierMyTopRated) {
                MyTopRatedViewController *myTopRatedViewController = [[MyTopRatedViewController alloc]init];
                myTopRatedViewController.songSelectorDelegate = songSelectorDelegate;
                myTopRatedViewController.title = [self titleForRowID:rowID];
                [self.navigationController pushViewController:myTopRatedViewController animated:YES];
            }
            else if (rowID == kRowIdentifierRecentlyPlayed) {
                RecentlyPlayedViewController *recentlyPlayedViewController = [[RecentlyPlayedViewController alloc]init];
                recentlyPlayedViewController.songSelectorDelegate = songSelectorDelegate;
                recentlyPlayedViewController.title = [self titleForRowID:rowID];
                [self.navigationController pushViewController:recentlyPlayedViewController animated:YES];
            }
            else {
                RecentlyAddedViewController *recentlyAddedViewController = [[RecentlyAddedViewController alloc]init];
                recentlyAddedViewController.songSelectorDelegate = songSelectorDelegate;
                recentlyAddedViewController.title = [self titleForRowID:rowID];
                [self.navigationController pushViewController:recentlyAddedViewController animated:YES];
            }
        }
    }
    else {
        selectedPlaylist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self pushPlaylistsDetailViewControllerAnimated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    selectedPlaylist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    TextInputNavigationController *textInputNavigationController = [[TextInputNavigationController alloc]init];
    textInputNavigationController.textInputNavigationControllerDelegate = self;
    [self safelyPresentModalViewController:textInputNavigationController animated:YES completion:nil];
}

- (NSString *)textInputNavigationControllerNavigationBarTitle {
    if (addingPlaylist) {
        return NSLocalizedString(@"ADD_PLAYLIST_DIALOG_TITLE", @"");
    }
    else {
        return @"Rename Playlist";
    }
}

- (NSString *)textInputNavigationControllerHeader {
    if (addingPlaylist) {
        return NSLocalizedString(@"ADD_PLAYLIST_DIALOG_MESSAGE", @"");
    }
    else {
        return @"Enter a new name for this playlist.";
    }
}

- (NSString *)textInputNavigationControllerPlaceholder {
    return NSLocalizedString(@"ADD_PLAYLIST_TITLE_PLACEHOLDER", @"");
}

- (NSString *)textInputNavigationControllerDefaultText {
    return nil;
}

- (void)textInputNavigationControllerDidCancel {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)textInputNavigationControllerDidReceiveTextInput:(NSString *)text {
    if (addingPlaylist) {
        addingPlaylist = NO;
        
        DataManager *dataManager = [DataManager sharedDataManager];
        NSManagedObjectContext *managedObjectContext = [dataManager managedObjectContext];
        
        selectedPlaylist = [[Playlist alloc]initWithEntity:[NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
        selectedPlaylist.name = text;
        
        [dataManager saveContext];
        
        [self safelyDismissModalViewControllerAnimated:YES completion:nil];
        
        // This can be a time-consuming process, so I have included a HUD to indicate that the app is loading.
        
        UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
        MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:window];
        hud.dimBackground = YES;
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading...";
        [window addSubview:hud];
        [hud showWhileExecuting:@selector(presentAddToPlaylistViewController) onTarget:self withObject:nil animated:YES];
    }
    else {
        selectedPlaylist.name = text;
        [[DataManager sharedDataManager]saveContext];
        [self safelyDismissModalViewControllerAnimated:YES completion:nil];
    }
}

- (void)presentAddToPlaylistViewController {
    __block AddToPlaylistViewController *addToPlaylistViewController = nil;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        addToPlaylistViewController = [[AddToPlaylistViewController alloc]initWithDelegate:self];
    });
    
    while ([self safeModalViewController]);
    
    dispatch_async(mainQueue, ^{
        [self safelyPresentModalViewController:addToPlaylistViewController animated:YES completion:nil];
    });
}

- (void)pushPlaylistsDetailViewControllerAnimated:(BOOL)animated {
    PlaylistsDetailViewController *playlistsDetailViewController = [[PlaylistsDetailViewController alloc]initWithDelegate:self];
    playlistsDetailViewController.songSelectorDelegate = songSelectorDelegate;
    playlistsDetailViewController.title = selectedPlaylist.name;
    [self.navigationController pushViewController:playlistsDetailViewController animated:YES];
}

- (Playlist *)addToPlaylistViewControllerPlaylist {
    return selectedPlaylist;
}

- (void)addToPlaylistViewControllerDidSelectFiles:(NSArray *)files {
    DataManager *dataManager = [DataManager sharedDataManager];
    NSManagedObjectContext *managedObjectContext = [dataManager managedObjectContext];
    for (int i = 0; i < [files count]; i++) {
        File *file = [files objectAtIndex:i];
        
        PlaylistItem *playlistItem = [[PlaylistItem alloc]initWithEntity:[NSEntityDescription entityForName:@"PlaylistItem" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
        playlistItem.index = [NSNumber numberWithInteger:i];
        playlistItem.fileRef = file;
        playlistItem.playlistRef = selectedPlaylist;
        
        [file addPlaylistItemRefsObject:playlistItem];
        
        [selectedPlaylist addPlaylistItemsObject:playlistItem];
    }
    [dataManager saveContext];
    
    [self pushPlaylistsDetailViewControllerAnimated:NO];
    
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (Playlist *)playlistsDetailViewControllerPlaylist {
    return selectedPlaylist;
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* @"Playlist_Cache" */ nil];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
        
        // @try {
            NSError *error = nil;
            if (![[self fetchedResultsController]performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        // }
        /*
        @catch (NSException *exception) {
            [NSFetchedResultsController deleteCacheWithName:@"Playlist_Cache"];
            
            NSError *error = nil;
            if (![[self fetchedResultsController]performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        */
    }
    return fetchedResultsController;
}

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Playlist *playlist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    cell.textLabel.text = playlist.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSInteger sectionIndex = 1;
    if (row1ID != kRowIdentifierNone) {
        sectionIndex = 2;
    }
    
    if (indexPath.section == sectionIndex) {
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else {
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
    }
}

@end
