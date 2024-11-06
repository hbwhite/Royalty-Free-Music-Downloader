//
//  GenreSingleAlbumViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "GenreSingleAlbumViewController.h"
#import "VisibilityViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "File.h"
#import "Album.h"
#import "Album+Extensions.h"
#import "Artist.h"
#import "SingleAlbumHeaderCell.h"
#import "SingleAlbumSongCell.h"
#import "SingleAlbumSelectAllCell.h"
#import "PlayerViewController.h"
#import "Player.h"
#import "SettingsViewController.h"
#import "OptionsActionSheetHandler.h"
#import "SkinManager.h"
#import "NSArray+Equivalence.h"
#import "File+Extensions.h"
#import "NSDateFormatter+Duration.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface GenreSingleAlbumViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *editingFetchedResultsController;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)visibilityViewControllerModeDidChange;
- (void)nowPlayingFileDidChange;
- (void)shuffleButtonPressed;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation GenreSingleAlbumViewController

// Public
@synthesize delegate;

// Private
@synthesize fetchedResultsController;
@synthesize editingFetchedResultsController;

- (void)groupByAlbumArtistPreferenceDidChange {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        fetchedResultsController = nil;
        
        // Fetch new objects.
        [self fetchedResultsController];
        
        if ([[[self fetchedResultsController]fetchedObjects]count] > 0) {
            [self.tableView reloadData];
        }
    });
}

- (void)visibilityViewControllerModeDidChange {
    if (viewIsVisible) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

- (void)nowPlayingFileDidChange {
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)shuffleButtonPressed {
    Player *player = [Player sharedPlayer];
    [player setPlaylistItems:[[self fetchedResultsController]fetchedObjects]];
    [player shuffle];
    
    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(groupByAlbumArtistPreferenceDidChange) name:kGroupByAlbumArtistPreferenceDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(visibilityViewControllerModeDidChange) name:kVisibilityViewControllerModeDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(nowPlayingFileDidChange) name:kPlayerNowPlayingFileDidChangeNotification object:nil];
    
    // This prevents excess cell separators from being created.
    UIView *defaultFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    defaultFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = defaultFooterView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 115;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
    NSInteger sectionCount = [[[self fetchedResultsController]sections]count];
    if (sectionCount > 0) {
        return 3;
    }
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        if ((mode == kVisibilityViewControllerModeMultiEdit) || (mode == kVisibilityViewControllerModeAddToPlaylist)) {
            return 1;
        }
    }
    else {
        return [[[self fetchedResultsController]fetchedObjects]count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell 1";
        
        SingleAlbumHeaderCell *cell = (SingleAlbumHeaderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SingleAlbumHeaderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        NSArray *filesArray = [[self fetchedResultsController]fetchedObjects];
        NSInteger songCount = [filesArray count];
        
        // This ensures that the album hasn't been changed by the tag editor (if it has, the following references could be invalid and accessing them could cause the app to crash).
        if (songCount > 0) {
            Album *album = [delegate genreSingleAlbumViewControllerAlbum];
            
            [cell setAlbumArtworkImage:[album artwork]];
            cell.artistLabel.text = album.artist.name;
            cell.albumLabel.text = album.name;
            
            NSInteger seconds = 0;
            
            for (int i = 0; i < [filesArray count]; i++) {
                File *file = [filesArray objectAtIndex:i];
                seconds += [file.duration integerValue];
            }
            
            NSInteger minutes = 0;
            
            NSInteger remainder = (seconds % 60);
            if (remainder > 0) {
                minutes = (((seconds - remainder) / 60.0) + 1);
            }
            else {
                minutes = (seconds / 60.0);
            }
            
            NSString *songCountString = nil;
            if (songCount == 1) {
                songCountString = NSLocalizedString(@"ALBUM_INFO_SONGS_SINGULAR", @"");
            }
            else {
                songCountString = [NSString stringWithFormat:NSLocalizedString(@"ALBUM_INFO_SONGS_FORMAT_PLURAL", @""), songCount];
            }
            
            NSString *minuteCountString = nil;
            if (minutes == 1) {
                minuteCountString = NSLocalizedString(@"ALBUM_INFO_TIME_SINGULAR", @"");
            }
            else {
                minuteCountString = [NSString stringWithFormat:NSLocalizedString(@"ALBUM_INFO_TIME_FORMAT_PLURAL", @""), minutes];
            }
            
            NSNumber *year = [album year];
            if (year) {
                cell.detailLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"ALBUM_HEADER_RELEASE_DATE_FORMAT", @""), year];
                cell.detailLabel2.text = [[songCountString stringByAppendingString:NSLocalizedString(@"ALBUM_INFO_SEPARATOR", @"")]stringByAppendingString:minuteCountString];
            }
            else {
                cell.detailLabel1.text = [[songCountString stringByAppendingString:NSLocalizedString(@"ALBUM_INFO_SEPARATOR", @"")]stringByAppendingString:minuteCountString];
                cell.detailLabel2.text = nil;
            }
        }
        
        cell.shuffleButton.hidden = ((mode == kVisibilityViewControllerModeEdit) || (mode == kVisibilityViewControllerModeMultiEdit) || (mode == kVisibilityViewControllerModeAddToPlaylist) || (songCount <= 1));
        [cell.shuffleButton addTarget:self action:@selector(shuffleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"Cell 2";
        
        SingleAlbumSelectAllCell *cell = (SingleAlbumSelectAllCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SingleAlbumSelectAllCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (mode == kVisibilityViewControllerModeMultiEdit) {
            cell.titleLabel.text = @"Select All";
        }
        else {
            cell.titleLabel.text = NSLocalizedString(@"Add All Songs", @"");
            
            UIImageView *addButtonAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 29, 29)];
            addButtonAccessoryView.contentMode = UIViewContentModeCenter;
            addButtonAccessoryView.image = [UIImage iOS7SkinImageNamed:@"Add_Button"];
            addButtonAccessoryView.highlightedImage = [UIImage iOS7SkinImageNamed:@"Add_Button-Selected"];
            cell.accessoryView = addButtonAccessoryView;
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 3";
        
        SingleAlbumSongCell *cell = (SingleAlbumSongCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SingleAlbumSongCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return ((mode != kVisibilityViewControllerModeMultiEdit) && (mode != kVisibilityViewControllerModeAddToPlaylist) && (mode != kVisibilityViewControllerModeMultiEdit) && (indexPath.section == 2));
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        File *file = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        
        if ([file.iPodMusicLibraryFile boolValue]) {
            UIAlertView *cannotDeleteAlert = [[UIAlertView alloc]
                                              initWithTitle:@"Cannot Delete Song"
                                              message:@"You cannot delete songs from your iPod music library."
                                              delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
            [cannotDeleteAlert show];
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [[DataManager sharedDataManager]deleteFile:file];
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
    
    if (indexPath.section == 1) {
        if (mode == kVisibilityViewControllerModeMultiEdit) {
            NSArray *songsArray = [[self fetchedResultsController]fetchedObjects];
            if ([selectedFilesArray containsObjectsInArray:songsArray]) {
                [selectedFilesArray removeAllObjects];
            }
            else {
                [selectedFilesArray setArray:songsArray];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [songSelectorDelegate songSelectorDidSelectFiles:[[self fetchedResultsController]fetchedObjects]];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if (indexPath.section == 2) {
        if (mode == kVisibilityViewControllerModeNone) {
            Player *player = [Player sharedPlayer];
            [player setPlaylistItems:[[self fetchedResultsController]fetchedObjects]];
            [player setCurrentFileWithIndex:indexPath.row];
            
            PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
            [self.navigationController pushViewController:playerViewController animated:YES];
        }
        else if (mode == kVisibilityViewControllerModeMultiEdit) {
            File *file = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            if ([selectedFilesArray containsObject:file]) {
                [selectedFilesArray removeObject:file];
            }
            else {
                [selectedFilesArray addObject:file];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (mode == kVisibilityViewControllerModeAddToPlaylist) {
            File *file = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [songSelectorDelegate songSelectorDidSelectFile:file];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
    [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForFiles:currentFetchedResultsController.fetchedObjects fileIndex:indexPath.row fromIndexPath:indexPath inTableView:tableView canDelete:NO];
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if ((mode == kVisibilityViewControllerModeEdit) || (mode == kVisibilityViewControllerModeMultiEdit)) {
        if (!editingFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *trackSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"track" ascending:YES];
            NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO];
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:trackSortDescriptor, titleSortDescriptor, albumByAlbumArtistSortDescriptor, albumByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, creationDateSortDescriptor, nil]];
            }
            else {
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:trackSortDescriptor, titleSortDescriptor, albumByArtistSortDescriptor, albumByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, creationDateSortDescriptor, nil]];
            }
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(genreRef == %@) AND (albumRefForAlbumArtistGroup == %@) AND (iPodMusicLibraryFile == %@)", [delegate genreSingleAlbumViewControllerGenre], [delegate genreSingleAlbumViewControllerAlbum], [NSNumber numberWithBool:NO]]];
            }
            else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(genreRef == %@) AND (albumRefForArtistGroup == %@) AND (iPodMusicLibraryFile == %@)", [delegate genreSingleAlbumViewControllerGenre], [delegate genreSingleAlbumViewControllerAlbum], [NSNumber numberWithBool:NO]]];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            aFetchedResultsController.delegate = self;
            editingFetchedResultsController = aFetchedResultsController;
            
            NSError *error = nil;
            if (![editingFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        return editingFetchedResultsController;
    }
    else {
        if (!fetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *trackSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"track" ascending:YES];
            NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO];
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:trackSortDescriptor, titleSortDescriptor, albumByAlbumArtistSortDescriptor, albumByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, creationDateSortDescriptor, nil]];
            }
            else {
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:trackSortDescriptor, titleSortDescriptor, albumByArtistSortDescriptor, albumByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, creationDateSortDescriptor, nil]];
            }
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(genreRef == %@) AND (albumRefForAlbumArtistGroup == %@)", [delegate genreSingleAlbumViewControllerGenre], [delegate genreSingleAlbumViewControllerAlbum]]];
            }
            else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(genreRef == %@) AND (albumRefForArtistGroup == %@)", [delegate genreSingleAlbumViewControllerGenre], [delegate genreSingleAlbumViewControllerAlbum]]];
            }
            
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
}

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!searching) {
        if ((viewIsVisible) && (![self safeModalViewController]) && ([controller.fetchedObjects count] <= 0)) {
            // This prevents the table view from reloading after the view controller has been pushed off the stack and deallocated (which would cause the app to crash).
            [self.tableView setEditing:NO];
            [self.tableView reloadData];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self.tableView reloadData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self safeModalViewController]) {
        if ([[[self fetchedResultsController]fetchedObjects]count] <= 0) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    [super viewWillAppear:animated];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SingleAlbumSongCell *singleAlbumSongCell = (SingleAlbumSongCell *)cell;
    
    File *file = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    singleAlbumSongCell.trackNumberLabel.text = [NSString stringWithFormat:@"%i", [file standardizedTrack]];
    singleAlbumSongCell.titleLabel.text = file.title;
    singleAlbumSongCell.nowPlayingImageView.hidden = (![[[Player sharedPlayer]nowPlayingFile]isEqual:file]);
    singleAlbumSongCell.durationLabel.text = [NSDateFormatter formattedDuration:[file.duration integerValue]];
    
    if (mode == kVisibilityViewControllerModeAddToPlaylist) {
        UIImageView *addButtonAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 29, 29)];
        addButtonAccessoryView.contentMode = UIViewContentModeCenter;
        addButtonAccessoryView.image = [UIImage iOS7SkinImageNamed:@"Add_Button"];
        addButtonAccessoryView.highlightedImage = [UIImage iOS7SkinImageNamed:@"Add_Button-Selected"];
        cell.accessoryView = addButtonAccessoryView;
        
        if ([[songSelectorDelegate songSelectorSelectedFiles]containsObject:file]) {
            singleAlbumSongCell.trackNumberLabel.alpha = (1.0 / 3.0);
            singleAlbumSongCell.titleLabel.alpha = (1.0 / 3.0);
            singleAlbumSongCell.durationLabel.alpha = (1.0 / 3.0);
        }
        else {
            singleAlbumSongCell.trackNumberLabel.alpha = 1;
            singleAlbumSongCell.titleLabel.alpha = 1;
            singleAlbumSongCell.durationLabel.alpha = 1;
        }
    }
    else {
        if (mode == kVisibilityViewControllerModeEdit) {
            singleAlbumSongCell.checkmarkOverlayView.hidden = YES;
            singleAlbumSongCell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        else if (mode == kVisibilityViewControllerModeMultiEdit) {
            singleAlbumSongCell.checkmarkOverlayView.hidden = ![selectedFilesArray containsObject:file];
            singleAlbumSongCell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            singleAlbumSongCell.checkmarkOverlayView.hidden = YES;
            singleAlbumSongCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    UIColor *color1 = nil;
    UIColor *color2 = nil;
    
    if ([SkinManager iOS6Skin]) {
        color1 = [SkinManager iOS6SkinTableViewSectionHeaderShadowColor];
        color2 = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        if ([SkinManager iOS7Skin]) {
            color1 = [UIColor whiteColor];
            color2 = [UIColor whiteColor];
        }
        else {
            color1 = [UIColor whiteColor];
            color2 = [UIColor colorWithWhite:(245.0 / 255.0) alpha:1];
        }
    }
    
    if ((mode == kVisibilityViewControllerModeAddToPlaylist) || (mode == kVisibilityViewControllerModeMultiEdit)) {
        if ((indexPath.row % 2) == 0) {
            singleAlbumSongCell.fullBackgroundView.backgroundColor = color2;
        }
        else {
            singleAlbumSongCell.fullBackgroundView.backgroundColor = color1;
        }
    }
    else {
        if ((indexPath.row % 2) == 0) {
            singleAlbumSongCell.fullBackgroundView.backgroundColor = color1;
        }
        else {
            singleAlbumSongCell.fullBackgroundView.backgroundColor = color2;
        }
    }
}

- (void)dealloc {
    fetchedResultsController.delegate = nil;
    editingFetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
