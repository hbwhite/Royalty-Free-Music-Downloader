//
//  RecentlyAddedViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "RecentlyAddedViewController.h"
#import "VisibilityViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "DataManager.h"
#import "File.h"
#import "Album.h"
#import "Artist.h"
#import "ShuffleCell.h"
#import "SongCell.h"
#import "Player.h"
#import "PlayerViewController.h"
#import "StandardCell.h"
#import "SkinManager.h"
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface RecentlyAddedViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UILabel *songCountLabel;

@property (nonatomic) NSInteger initialPlaybackIndex;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)nowPlayingFileDidChange;
- (void)didFinishSearching;
- (void)updateSongCountLabel;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation RecentlyAddedViewController

// Private
@synthesize fetchedResultsController;
@synthesize songCountLabel;

@synthesize initialPlaybackIndex;

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
    // [NSFetchedResultsController deleteCacheWithName:@"Recently_Added_Song_Cache"];
    
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

- (void)updateSongCountLabel {
    songCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LISTING_COUNT_SONGS_FORMAT", @""), [[[self fetchedResultsController]fetchedObjects]count]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
    
    NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
    if (section > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[currentFetchedResultsController sections]objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    }
    else if ([currentFetchedResultsController.fetchedObjects count] > 1) {
        if (mode != kVisibilityViewControllerModeEdit) {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ((mode == kVisibilityViewControllerModeAddToPlaylist) || (mode == kVisibilityViewControllerModeMultiEdit)) {
            static NSString *CellIdentifier = @"Cell 1";
            
            StandardCell *cell = (StandardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[StandardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell configure];
            
            // Configure the cell...
            
            if (mode == kVisibilityViewControllerModeAddToPlaylist) {
                cell.textLabel.text = NSLocalizedString(@"Add All Songs", @"");
                
                UIImageView *addButtonAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 29, 29)];
                addButtonAccessoryView.contentMode = UIViewContentModeCenter;
                addButtonAccessoryView.image = [UIImage iOS7SkinImageNamed:@"Add_Button"];
                addButtonAccessoryView.highlightedImage = [UIImage iOS7SkinImageNamed:@"Add_Button-Selected"];
                cell.accessoryView = addButtonAccessoryView;
            }
            else {
                cell.textLabel.text = @"Select All";
                cell.imageView.image = nil;
                cell.imageView.highlightedImage = nil;
            }
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Cell 2";
            
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
        static NSString *CellIdentifier = @"Cell 3";
        
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return ((mode != kVisibilityViewControllerModeAddToPlaylist) && (mode != kVisibilityViewControllerModeMultiEdit) && (indexPath.section > 0) && (![[[[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]iPodMusicLibraryFile]boolValue]));
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        File *file = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [[DataManager sharedDataManager]deleteFile:file];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

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
    
    if (mode == kVisibilityViewControllerModeNone) {
        Player *player = [Player sharedPlayer];
        [player setPlaylistItems:[[self fetchedResultsController]fetchedObjects]];
        
        if (indexPath.section == 0) {
            [player shuffle];
        }
        else {
            [player setCurrentFileWithIndex:indexPath.row];
        }
        
        PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
        [self.navigationController pushViewController:playerViewController animated:YES];
    }
    else if (mode == kVisibilityViewControllerModeAddToPlaylist) {
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        if (indexPath.section == 0) {
            [songSelectorDelegate songSelectorDidSelectFiles:currentFetchedResultsController.fetchedObjects];
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForRowsInRect:CGRectMake(0, self.tableView.contentOffset.y, self.tableView.frame.size.width, self.tableView.frame.size.height)] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            File *file = [currentFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [songSelectorDelegate songSelectorDidSelectFile:file];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *dateAddedSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"dateAdded" ascending:NO];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:dateAddedSortDescriptor, nil]];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSWeekCalendarUnit fromDate:[NSDate date]];
        dateComponents.week -= 2;
        NSDate *twoWeeksAgo = [calendar dateFromComponents:dateComponents];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"creationDate >= %@", twoWeeksAgo]];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* @"Recently_Added_Song_Cache" */ nil];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
        
        // @try {
            NSError *error = nil;
            if (![fetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        // }
        /*
        @catch (NSException *exception) {
            [NSFetchedResultsController deleteCacheWithName:@"Recently_Added_Song_Cache"];
            
            NSError *error = nil;
            if (![fetchedResultsController performFetch:&error]) {
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
    if (!searching) {
        [self.tableView reloadData];
        
        if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
            [self updateSongCountLabel];
            self.tableView.tableFooterView = songCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SongCell *songCell = (SongCell *)cell;
    
    File *file = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
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
        songCell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    songCell.nowPlayingImageView.hidden = ![[[Player sharedPlayer]nowPlayingFile]isEqual:file];
}

- (void)dealloc {
    fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
