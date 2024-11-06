//
//  ArtistsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "ArtistsViewController.h"
#import "VisibilityViewController.h"
#import "SingleAlbumViewController.h"
#import "AlbumsViewController.h"
#import "SettingsViewController.h"
#import "DataManager.h"
#import "Album.h"
#import "Artist.h"
#import "CheckmarkOverlayCell.h"
#import "SongsViewController.h"
#import "OptionsActionSheetHandler.h"
#import "StandardCell.h"
#import "SkinManager.h"
#import "NSArray+Equivalence.h"
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+SafeModal.h"
#import "UILocalizedIndexedCollation+StandardizedSectionIndexTitles.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface ArtistsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *editingFetchedResultsController;
@property (nonatomic, strong) UILabel *artistCountLabel;
@property (nonatomic, strong) Album *selectedAlbum;
@property (nonatomic, strong) Artist *selectedArtist;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)visibilityViewControllerModeDidChange;
- (void)didFinishSearching;
- (void)updateArtistCountLabel;
- (NSArray *)songsForArtist:(Artist *)artist;
- (NSArray *)songsForAlbum:(Album *)album;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ArtistsViewController

// Private
@synthesize fetchedResultsController;
@synthesize editingFetchedResultsController;
@synthesize artistCountLabel;
@synthesize selectedAlbum;
@synthesize selectedArtist;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(groupByAlbumArtistPreferenceDidChange) name:kGroupByAlbumArtistPreferenceDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(visibilityViewControllerModeDidChange) name:kVisibilityViewControllerModeDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didFinishSearching) name:kVisibilityViewControllerDidFinishSearchingNotification object:nil];
    
    artistCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    artistCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    artistCountLabel.font = [UIFont systemFontOfSize:20];
    artistCountLabel.textAlignment = UITextAlignmentCenter;
    artistCountLabel.textColor = [UIColor grayColor];
    artistCountLabel.backgroundColor = [UIColor clearColor];
    if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
        [self updateArtistCountLabel];
        self.tableView.tableFooterView = artistCountLabel;
    }
}

- (void)groupByAlbumArtistPreferenceDidChange {
    // [NSFetchedResultsController deleteCacheWithName:@"Local_Artist_Cache"];
    // [NSFetchedResultsController deleteCacheWithName:@"Universal_Artist_Cache"];
    
    fetchedResultsController = nil;
    
    // Fetch new objects.
    [self fetchedResultsController];
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        if ([[[self fetchedResultsController]fetchedObjects]count] > 0) {
            [self.tableView reloadData];
            
            if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
                [self updateArtistCountLabel];
                self.tableView.tableFooterView = artistCountLabel;
            }
            else {
                self.tableView.tableFooterView = nil;
            }
        }
    });
}

- (void)visibilityViewControllerModeDidChange {
    if ((viewIsVisible) && (!searching)) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [self.tableView reloadData];
            
            if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
                [self updateArtistCountLabel];
                self.tableView.tableFooterView = artistCountLabel;
            }
            else {
                self.tableView.tableFooterView = nil;
            }
        });
    }
}

- (void)didFinishSearching {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
            [self updateArtistCountLabel];
            self.tableView.tableFooterView = artistCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    });
}

- (void)updateArtistCountLabel {
    artistCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LISTING_COUNT_ARTISTS_FORMAT", @""), [[[self fetchedResultsController]fetchedObjects]count]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
    return ([[[self fetchedResultsController]sections]count] + 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        if ([currentFetchedResultsController.fetchedObjects count] >= 30) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [currentFetchedResultsController.sections objectAtIndex:(section - 1)];
            return [sectionInfo name];
        }
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
    if (([currentFetchedResultsController.fetchedObjects count] >= 30) && (currentFetchedResultsController.sectionNameKeyPath)) {
        if (![self.searchBar isFirstResponder]) {
                NSArray *sectionIndexTitles = [[UILocalizedIndexedCollation currentCollation]standardizedSectionIndexTitles];
                if (mode == kVisibilityViewControllerModeEdit) {
                    return sectionIndexTitles;
                }
                else {
                    return [[NSArray arrayWithObject:UITableViewIndexSearch]arrayByAddingObjectsFromArray:sectionIndexTitles];
                }
            }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	if (index == 0) {
        [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    else {
        // The -sectionIndexTitles property of NSFetchedResultsController is inaccurate because it does not return all of the current section titles.
        // For example, "LL" in Spanish is excluded. As a result, the section must be determined by looping through the current section titles.
        for (int i = 0; i < [self numberOfSectionsInTableView:tableView]; i++) {
            NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:i];
            if (sectionTitle) {
                if ([sectionTitle isEqualToString:title]) {
                    return i;
                }
            }
        }
    }
    return -1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
    
    NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
    if (section > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[currentFetchedResultsController sections]objectAtIndex:(section - 1)];
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
        static NSString *CellIdentifier = @"Cell 1";
        
        StandardCell *cell = (StandardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[StandardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (mode == kVisibilityViewControllerModeAddToPlaylist) {
            cell.textLabel.text = NSLocalizedString(@"Add All Albums", @"");
            
            UIImageView *addButtonAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 29, 29)];
            addButtonAccessoryView.contentMode = UIViewContentModeCenter;
            addButtonAccessoryView.image = [UIImage iOS7SkinImageNamed:@"Add_Button"];
            addButtonAccessoryView.highlightedImage = [UIImage iOS7SkinImageNamed:@"Add_Button-Selected"];
            cell.accessoryView = addButtonAccessoryView;
        }
        else if (mode == kVisibilityViewControllerModeMultiEdit) {
            cell.textLabel.text = @"Select All";
            cell.imageView.image = nil;
            cell.imageView.highlightedImage = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"All Albums", @"");
            cell.imageView.image = nil;
            cell.imageView.highlightedImage = nil;
            
            NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
            if (([currentFetchedResultsController.fetchedObjects count] < 30) || (!currentFetchedResultsController.sectionNameKeyPath)) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 2";
        
        CheckmarkOverlayCell *cell = (CheckmarkOverlayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CheckmarkOverlayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    return ((mode != kVisibilityViewControllerModeAddToPlaylist) && (mode != kVisibilityViewControllerModeMultiEdit) && (indexPath.section > 0));
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Artist *artist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
        
        NSSet *files = nil;
        
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
            files = [artist filesForAlbumArtistGroup];
        }
        else {
            files = [artist filesForArtistGroup];
        }
        
        if ([[files filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"iPodMusicLibraryFile == %@", [NSNumber numberWithBool:YES]]]count] > 0) {
            UIAlertView *cannotDeleteAlert = [[UIAlertView alloc]
                                              initWithTitle:@"Cannot Delete Artist"
                                              message:@"You cannot delete artists with songs from your iPod music library."
                                              delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
            [cannotDeleteAlert show];
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [[DataManager sharedDataManager]deleteArtist:artist];
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
    
    if (indexPath.section == 0) {
        if (mode == kVisibilityViewControllerModeNone) {
            AlbumsViewController *albumsViewController = [[AlbumsViewController alloc]init];
            albumsViewController.songSelectorDelegate = songSelectorDelegate;
            albumsViewController.title = NSLocalizedString(@"Albums", @"");
            [self.navigationController pushViewController:albumsViewController animated:YES];
        }
        else if (mode == kVisibilityViewControllerModeMultiEdit) {
            NSArray *artistsArray = [[self fetchedResultsController]fetchedObjects];
            if ([selectedItemsArray containsObjectsInArray:artistsArray]) {
                [selectedItemsArray removeAllObjects];
                [selectedFilesArray removeAllObjects];
            }
            else {
                [selectedItemsArray setArray:artistsArray];
                
                [selectedFilesArray removeAllObjects];
                for (int i = 0; i < [artistsArray count]; i++) {
                    Artist *artist = [artistsArray objectAtIndex:i];
                    [selectedFilesArray addObjectsFromArray:[self songsForArtist:artist]];
                }
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([tableView numberOfSections] - 1))] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (mode == kVisibilityViewControllerModeAddToPlaylist) {
            NSArray *artistsArray = [[self fetchedResultsController]fetchedObjects];
            for (int i = 0; i < [artistsArray  count]; i++) {
                Artist *artist = [artistsArray objectAtIndex:i];
                NSArray *albumsArray = [artist.albums allObjects];
                for (int j = 0; j < [albumsArray count]; j++) {
                    Album *album = [albumsArray objectAtIndex:j];
                    [songSelectorDelegate songSelectorDidSelectFiles:[self songsForAlbum:album]];
                }
            }
        }
    }
    else {
        if (mode == kVisibilityViewControllerModeMultiEdit) {
            Artist *artist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            if ([selectedItemsArray containsObject:artist]) {
                [selectedItemsArray removeObject:artist];
                [selectedFilesArray removeObjectsInArray:[self songsForArtist:artist]];
            }
            else {
                [selectedItemsArray addObject:artist];
                [selectedFilesArray addObjectsFromArray:[self songsForArtist:artist]];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            selectedArtist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            
            if ([selectedArtist.albums count] == 1) {
                selectedAlbum = [[selectedArtist.albums allObjects]objectAtIndex:0];
                
                SingleAlbumViewController *singleAlbumViewController = [[SingleAlbumViewController alloc]initWithDelegate:self];
                singleAlbumViewController.songSelectorDelegate = songSelectorDelegate;
                singleAlbumViewController.title = selectedArtist.name;
                [self.navigationController pushViewController:singleAlbumViewController animated:YES];
            }
            else {
                AlbumsViewController *albumsViewController = [[AlbumsViewController alloc]initWithDelegate:self];
                albumsViewController.songSelectorDelegate = songSelectorDelegate;
                albumsViewController.title = selectedArtist.name;
                [self.navigationController pushViewController:albumsViewController animated:YES];
            }
        }
    }
}

- (NSArray *)songsForArtist:(Artist *)artist {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        return [artist.filesForAlbumArtistGroup allObjects];
    }
    else {
        return [artist.filesForArtistGroup allObjects];
    }
}

- (NSArray *)songsForAlbum:(Album *)album {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        return [album.filesForAlbumArtistGroup allObjects];
    }
    else {
        return [album.filesForArtistGroup allObjects];
    }
}

- (Album *)singleAlbumViewControllerAlbum {
    return selectedAlbum;
}

- (Artist *)albumsViewControllerArtist {
    return selectedArtist;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Artist *artist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    
    NSArray *files = nil;
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        files = [artist.filesForAlbumArtistGroup allObjects];
    }
    else {
        files = [artist.filesForArtistGroup allObjects];
    }
    
    [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForMultipleFiles:files fromIndexPath:indexPath inTableView:tableView searchString:artist.name canDelete:NO];
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if ((mode == kVisibilityViewControllerModeEdit) || (mode == kVisibilityViewControllerModeMultiEdit)) {
        if (!editingFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Artist" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == %@) AND (SUBQUERY(filesForAlbumArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0)", groupByAlbumArtist, [NSNumber numberWithBool:YES]]];
            }
            else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == %@) AND (SUBQUERY(filesForArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0)", groupByAlbumArtist, [NSNumber numberWithBool:YES]]];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"artistSectionTitle" cacheName:/* @"Local_Artist_Cache" */ nil];
            aFetchedResultsController.delegate = self;
            editingFetchedResultsController = aFetchedResultsController;
            
            // @try {
                if (![editingFetchedResultsController performFetch:nil]) {
                    aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* @"Local_Artist_Cache" */ nil];
                    aFetchedResultsController.delegate = self;
                    editingFetchedResultsController = aFetchedResultsController;
                    
                    NSError *error = nil;
                    if (![editingFetchedResultsController performFetch:&error]) {
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                }
            // }
            /*
            @catch (NSException *exception) {
                [NSFetchedResultsController deleteCacheWithName:@"Local_Artist_Cache"];
                
                if (![editingFetchedResultsController performFetch:nil]) {
                    aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Local_Artist_Cache"];
                    aFetchedResultsController.delegate = self;
                    editingFetchedResultsController = aFetchedResultsController;
             
                    NSError *error = nil;
                    if (![editingFetchedResultsController performFetch:&error]) {
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                }
            }
            */
        }
        return editingFetchedResultsController;
    }
    else {
        if (!fetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Artist" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupByAlbumArtist == %@", groupByAlbumArtist]];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"artistSectionTitle" cacheName:/* @"Universal_Artist_Cache" */ nil];
            aFetchedResultsController.delegate = self;
            fetchedResultsController = aFetchedResultsController;
            
            // @try {
                if (![fetchedResultsController performFetch:nil]) {
                    aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* @"Universal_Artist_Cache" */ nil];
                    aFetchedResultsController.delegate = self;
                    fetchedResultsController = aFetchedResultsController;
                    
                    NSError *error = nil;
                    if (![fetchedResultsController performFetch:&error]) {
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                }
            // }
            /*
            @catch (NSException *exception) {
                [NSFetchedResultsController deleteCacheWithName:@"Universal_Artist_Cache"];
                
                if (![fetchedResultsController performFetch:nil]) {
                    aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Universal_Artist_Cache"];
                    aFetchedResultsController.delegate = self;
                    fetchedResultsController = aFetchedResultsController;
                    
                    NSError *error = nil;
                    if (![fetchedResultsController performFetch:&error]) {
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                }
            }
            */
        }
        return fetchedResultsController;
    }
}

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!searching) {
        if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
            [self updateArtistCountLabel];
            self.tableView.tableFooterView = artistCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
        
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
    CheckmarkOverlayCell *checkmarkOverlayCell = (CheckmarkOverlayCell *)cell;
    
    Artist *artist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    checkmarkOverlayCell.textLabel.text = artist.name;
    
    if (mode == kVisibilityViewControllerModeEdit) {
        checkmarkOverlayCell.checkmarkOverlayView.hidden = YES;
        checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (mode == kVisibilityViewControllerModeMultiEdit) {
        checkmarkOverlayCell.checkmarkOverlayView.hidden = ![selectedItemsArray containsObject:artist];
        checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        checkmarkOverlayCell.checkmarkOverlayView.hidden = YES;
        
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        if (([currentFetchedResultsController.fetchedObjects count] < 30) || (!currentFetchedResultsController.sectionNameKeyPath)) {
            checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    checkmarkOverlayCell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}

- (void)dealloc {
    fetchedResultsController.delegate = nil;
    editingFetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
