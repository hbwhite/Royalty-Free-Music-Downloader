//
//  GenresViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "GenresViewController.h"
#import "VisibilityViewController.h"
#import "GenreArtistsViewController.h"
#import "SettingsViewController.h"
#import "AlbumsViewController.h"
#import "DataManager.h"
#import "Genre.h"
#import "CheckmarkOverlayCell.h"
#import "MultipleTagEditorNavigationController.h"
#import "OptionsActionSheetHandler.h"
#import "StandardCell.h"
#import "NSArray+Equivalence.h"
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "UILocalizedIndexedCollation+StandardizedSectionIndexTitles.h"

@interface GenresViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *editingFetchedResultsController;
@property (nonatomic, strong) UILabel *genreCountLabel;
@property (nonatomic, strong) Genre *selectedGenre;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)visibilityViewControllerModeDidChange;
- (void)didFinishSearching;
- (void)updateGenreCountLabel;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation GenresViewController

// Private
@synthesize fetchedResultsController;
@synthesize editingFetchedResultsController;
@synthesize genreCountLabel;
@synthesize selectedGenre;

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
    
    genreCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    genreCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    genreCountLabel.font = [UIFont systemFontOfSize:20];
    genreCountLabel.textAlignment = UITextAlignmentCenter;
    genreCountLabel.textColor = [UIColor grayColor];
    genreCountLabel.backgroundColor = [UIColor clearColor];
    if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
        [self updateGenreCountLabel];
        self.tableView.tableFooterView = genreCountLabel;
    }
}

- (void)groupByAlbumArtistPreferenceDidChange {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        // [NSFetchedResultsController deleteCacheWithName:@"Local_Genre_Cache"];
        // [NSFetchedResultsController deleteCacheWithName:@"Universal_Genre_Cache"];
        
        fetchedResultsController = nil;
        
        // Fetch new objects.
        [self fetchedResultsController];
        
        if ([[[self fetchedResultsController]fetchedObjects]count] > 0) {
            [self.tableView reloadData];
            
            if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
                [self updateGenreCountLabel];
                self.tableView.tableFooterView = genreCountLabel;
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
                [self updateGenreCountLabel];
                self.tableView.tableFooterView = genreCountLabel;
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
            [self updateGenreCountLabel];
            self.tableView.tableFooterView = genreCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    });
}

- (void)updateGenreCountLabel {
    genreCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LISTING_COUNT_GENRES_FORMAT", @""), [[[self fetchedResultsController]fetchedObjects]count]];
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
        if (mode == kVisibilityViewControllerModeMultiEdit) {
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
        
        if (mode == kVisibilityViewControllerModeMultiEdit) {
            cell.textLabel.text = @"Select All";
            cell.imageView.image = nil;
            cell.imageView.highlightedImage = nil;
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
        
        Genre *genre = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
        
        if ([[genre.files filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"iPodMusicLibraryFile == %@", [NSNumber numberWithBool:YES]]]count] > 0) {
            UIAlertView *cannotDeleteAlert = [[UIAlertView alloc]
                                              initWithTitle:@"Cannot Delete Genre"
                                              message:@"You cannot delete genres with songs from your iPod music library."
                                              delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
            [cannotDeleteAlert show];
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [[DataManager sharedDataManager]deleteGenre:genre];
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
    
    if (mode == kVisibilityViewControllerModeMultiEdit) {
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        if (indexPath.section == 0) {
            NSArray *genresArray = currentFetchedResultsController.fetchedObjects;
            if ([selectedItemsArray containsObjectsInArray:genresArray]) {
                [selectedItemsArray removeAllObjects];
                [selectedFilesArray removeAllObjects];
            }
            else {
                [selectedItemsArray setArray:genresArray];
                
                [selectedFilesArray removeAllObjects];
                for (int i = 0; i < [genresArray count]; i++) {
                    Genre *genre = [genresArray objectAtIndex:i];
                    [selectedFilesArray addObjectsFromArray:[genre.files allObjects]];
                }
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([tableView numberOfSections] - 1))] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            Genre *genre = [currentFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            NSArray *files = [genre.files allObjects];
            if ([selectedItemsArray containsObject:genre]) {
                [selectedItemsArray removeObject:genre];
                [selectedFilesArray removeObjectsInArray:files];
            }
            else {
                [selectedItemsArray addObject:genre];
                [selectedFilesArray addObjectsFromArray:files];
            }
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else {
        selectedGenre = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
        
        GenreArtistsViewController *genreArtistsViewController = [[GenreArtistsViewController alloc]initWithDelegate:self];
        genreArtistsViewController.songSelectorDelegate = songSelectorDelegate;
        genreArtistsViewController.title = selectedGenre.name;
        [self.navigationController pushViewController:genreArtistsViewController animated:YES];
    }
}

- (Genre *)genreArtistsViewControllerGenre {
    return selectedGenre;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Genre *genre = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    
    NSArray *files = [genre.files allObjects];
    
    [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForMultipleFiles:files fromIndexPath:indexPath inTableView:tableView searchString:genre.name canDelete:NO];
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if ((mode == kVisibilityViewControllerModeEdit) || (mode == kVisibilityViewControllerModeMultiEdit)) {
        if (!editingFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Genre" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"SUBQUERY(files, $x, $x.iPodMusicLibraryFile == %@).@count == 0", [NSNumber numberWithBool:YES]]];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"genreSectionTitle" cacheName:/* @"Local_Genre_Cache" */ nil];
            aFetchedResultsController.delegate = self;
            editingFetchedResultsController = aFetchedResultsController;
            
            // @try {
                if (![editingFetchedResultsController performFetch:nil]) {
                    aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* @"Local_Genre_Cache" */ nil];
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
                [NSFetchedResultsController deleteCacheWithName:@"Local_Genre_Cache"];
                
                if (![editingFetchedResultsController performFetch:nil]) {
                    aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Local_Genre_Cache"];
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
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Genre" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"genreSectionTitle" cacheName:/* @"Universal_Genre_Cache" */ nil];
            aFetchedResultsController.delegate = self;
            fetchedResultsController = aFetchedResultsController;
            
            // @try {
                if (![fetchedResultsController performFetch:nil]) {
                    aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* @"Universal_Genre_Cache" */ nil];
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
                [NSFetchedResultsController deleteCacheWithName:@"Universal_Genre_Cache"];
                
                if (![fetchedResultsController performFetch:nil]) {
                    aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Universal_Genre_Cache"];
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
        [self.tableView reloadData];
        
        if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
            [self updateGenreCountLabel];
            self.tableView.tableFooterView = genreCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
        
        /*
        // The genres view controller is the highest-level view controller in the application, and leaving this code in could transition to the more navigation controller of the tab bar controller when the last genre is deleted.
        if ((viewIsVisible) || ([self safeModalViewController])) {
            if ([controller.fetchedObjects count] <= 0) {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    while ([self safeModalViewController]);
                    
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                });
            }
        }
        */
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CheckmarkOverlayCell *checkmarkOverlayCell = (CheckmarkOverlayCell *)cell;
    
    Genre *genre = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    checkmarkOverlayCell.textLabel.text = genre.name;
    
    if (mode == kVisibilityViewControllerModeEdit) {
        checkmarkOverlayCell.checkmarkOverlayView.hidden = YES;
        checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (mode == kVisibilityViewControllerModeMultiEdit) {
        checkmarkOverlayCell.checkmarkOverlayView.hidden = ![selectedItemsArray containsObject:genre];
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
