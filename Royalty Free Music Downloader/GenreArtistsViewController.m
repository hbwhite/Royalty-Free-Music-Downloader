//
//  GenreArtistsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "GenreArtistsViewController.h"
#import "VisibilityViewController.h"
#import "SettingsViewController.h"
#import "DataManager.h"
#import "GenreArtist.h"
#import "GenreAlbum.h"
#import "Artist.h"
#import "Album.h"
#import "CheckmarkOverlayCell.h"
#import "GenreSingleAlbumViewController.h"
#import "GenreAlbumsViewController.h"
#import "OptionsActionSheetHandler.h"
#import "StandardCell.h"
#import "SkinManager.h"
#import "NSArray+Equivalence.h"
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "UILocalizedIndexedCollation+StandardizedSectionIndexTitles.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface GenreArtistsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *editingFetchedResultsController;
@property (nonatomic, strong) UILabel *artistCountLabel;
@property (nonatomic, strong) Album *selectedAlbum;
@property (nonatomic, strong) GenreArtist *selectedGenreArtist;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)visibilityViewControllerModeDidChange;
- (void)didFinishSearching;
- (void)updateArtistCountLabel;
- (NSArray *)songsForGenreAlbum:(GenreAlbum *)genreAlbum;
- (NSArray *)genreAlbumsForGenreArtist:(GenreArtist *)genreArtist;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation GenreArtistsViewController

// Public
@synthesize delegate;

// Private
@synthesize fetchedResultsController;
@synthesize editingFetchedResultsController;
@synthesize artistCountLabel;
@synthesize selectedAlbum;
@synthesize selectedGenreArtist;

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
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        fetchedResultsController = nil;
        
        // Fetch new objects.
        [self fetchedResultsController];
        
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
        
        GenreArtist *genreArtist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
        
        NSSet *files = nil;
        
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
            files = [genreArtist filesForAlbumArtistGroup];
        }
        else {
            files = [genreArtist filesForArtistGroup];
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
            [[DataManager sharedDataManager]deleteGenreArtist:genreArtist];
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
            selectedAlbum = nil;
            selectedGenreArtist = nil;
            
            GenreAlbumsViewController *genreAlbumsViewController = [[GenreAlbumsViewController alloc]initWithDelegate:self];
            genreAlbumsViewController.songSelectorDelegate = songSelectorDelegate;
            genreAlbumsViewController.title = NSLocalizedString(@"Albums", @"");
            [self.navigationController pushViewController:genreAlbumsViewController animated:YES];
        }
        else if (mode == kVisibilityViewControllerModeMultiEdit) {
            NSArray *genreArtistsArray = [[self fetchedResultsController]fetchedObjects];
            if ([selectedItemsArray containsObjectsInArray:genreArtistsArray]) {
                [selectedItemsArray removeAllObjects];
                [selectedFilesArray removeAllObjects];
            }
            else {
                [selectedItemsArray setArray:genreArtistsArray];
                
                [selectedFilesArray removeAllObjects];
                for (int i = 0; i < [genreArtistsArray count]; i++) {
                    GenreArtist *genreArtist = [genreArtistsArray objectAtIndex:i];
                    [selectedFilesArray addObjectsFromArray:[genreArtist.filesForAlbumArtistGroup allObjects]];
                }
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([tableView numberOfSections] - 1))] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (mode == kVisibilityViewControllerModeAddToPlaylist) {
            NSArray *genreArtistsArray = [[self fetchedResultsController]fetchedObjects];
            for (int i = 0; i < [genreArtistsArray  count]; i++) {
                GenreArtist *genreArtist = [genreArtistsArray objectAtIndex:i];
                NSArray *genreAlbumsArray = [self genreAlbumsForGenreArtist:genreArtist];
                for (int j = 0; j < [genreAlbumsArray count]; j++) {
                    GenreAlbum *genreAlbum = [genreAlbumsArray objectAtIndex:j];
                    [songSelectorDelegate songSelectorDidSelectFiles:[self songsForGenreAlbum:genreAlbum]];
                }
            }
        }
    }
    else {
        if (mode == kVisibilityViewControllerModeMultiEdit) {
            GenreArtist *genreArtist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            if ([selectedItemsArray containsObject:genreArtist]) {
                [selectedItemsArray removeObject:genreArtist];
                [selectedFilesArray removeObjectsInArray:[self songsForGenreArtist:genreArtist]];
            }
            else {
                [selectedItemsArray addObject:genreArtist];
                [selectedFilesArray addObjectsFromArray:[self songsForGenreArtist:genreArtist]];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            selectedGenreArtist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            
            NSArray *genreArtistGenreAlbumsArray = [self genreAlbumsForGenreArtist:selectedGenreArtist];
            if ([genreArtistGenreAlbumsArray count] == 1) {
                selectedAlbum = [[genreArtistGenreAlbumsArray objectAtIndex:0]album];
                
                GenreSingleAlbumViewController *genreSingleAlbumViewController = [[GenreSingleAlbumViewController alloc]initWithDelegate:self];
                genreSingleAlbumViewController.songSelectorDelegate = songSelectorDelegate;
                genreSingleAlbumViewController.title = selectedGenreArtist.artist.name;
                [self.navigationController pushViewController:genreSingleAlbumViewController animated:YES];
            }
            else {
                GenreAlbumsViewController *genreAlbumsViewController = [[GenreAlbumsViewController alloc]initWithDelegate:self];
                genreAlbumsViewController.songSelectorDelegate = songSelectorDelegate;
                genreAlbumsViewController.title = NSLocalizedString(@"Albums", @"");
                [self.navigationController pushViewController:genreAlbumsViewController animated:YES];
            }
        }
    }
}

- (NSArray *)songsForGenreArtist:(GenreArtist *)genreArtist {
    NSMutableArray *songsArray = [NSMutableArray arrayWithObjects:nil];
    
    NSArray *genreAlbumsArray = [self genreAlbumsForGenreArtist:genreArtist];
    for (int i = 0; i < [genreAlbumsArray count]; i++) {
        GenreAlbum *genreAlbum = [genreAlbumsArray objectAtIndex:i];
        [songsArray addObjectsFromArray:[self songsForGenreAlbum:genreAlbum]];
    }
    
    return songsArray;
}

- (NSArray *)songsForGenreAlbum:(GenreAlbum *)genreAlbum {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        return [genreAlbum.filesForAlbumArtistGroup allObjects];
    }
    else {
        return [genreAlbum.filesForArtistGroup allObjects];
    }
}

- (Genre *)genreSingleAlbumViewControllerGenre {
    return [delegate genreArtistsViewControllerGenre];
}

- (Album *)genreSingleAlbumViewControllerAlbum {
    return selectedAlbum;
}

- (Genre *)genreAlbumsViewControllerGenre {
    return [delegate genreArtistsViewControllerGenre];
}

- (GenreArtist *)genreAlbumsViewControllerGenreArtist {
    return selectedGenreArtist;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    GenreArtist *genreArtist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    
    NSArray *files = nil;
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        files = [genreArtist.filesForAlbumArtistGroup allObjects];
    }
    else {
        files = [genreArtist.filesForArtistGroup allObjects];
    }
    
    [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForMultipleFiles:files fromIndexPath:indexPath inTableView:tableView searchString:genreArtist.artist.name canDelete:NO];
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSArray *)genreAlbumsForGenreArtist:(GenreArtist *)genreArtist {
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GenreAlbum" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"album.name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *artistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"album.artist.name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, artistSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    Artist *artist = genreArtist.artist;
    if (artist) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(album.groupByAlbumArtist == %@) AND (genre == %@) AND (album.artist == %@)", [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]], [delegate genreArtistsViewControllerGenre], artist]];
    }
    else {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(album.groupByAlbumArtist == %@) AND (genre == %@)", [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]], [delegate genreArtistsViewControllerGenre]]];
    }
    
    NSFetchedResultsController *temporaryFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
	if (![temporaryFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return temporaryFetchedResultsController.fetchedObjects;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if ((mode == kVisibilityViewControllerModeEdit) || (mode == kVisibilityViewControllerModeMultiEdit)) {
        if (!editingFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"GenreArtist" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artist.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            Genre *genre = [delegate genreArtistsViewControllerGenre];
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(artist.groupByAlbumArtist == %@) AND (genre == %@) AND (SUBQUERY(filesForAlbumArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0)", groupByAlbumArtist, genre, [NSNumber numberWithBool:YES]]];
            }
            else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(artist.groupByAlbumArtist == %@) AND (genre == %@) AND (SUBQUERY(filesForArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0)", groupByAlbumArtist, genre, [NSNumber numberWithBool:YES]]];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"genreArtistSectionTitle" cacheName:nil];
            aFetchedResultsController.delegate = self;
            editingFetchedResultsController = aFetchedResultsController;
            
            if (![editingFetchedResultsController performFetch:nil]) {
                aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
                aFetchedResultsController.delegate = self;
                editingFetchedResultsController = aFetchedResultsController;
                
                NSError *error = nil;
                if (![editingFetchedResultsController performFetch:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
        }
        return editingFetchedResultsController;
    }
    else {
        if (!fetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"GenreArtist" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artist.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            Genre *genre = [delegate genreArtistsViewControllerGenre];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(artist.groupByAlbumArtist == %@) AND (genre == %@)", groupByAlbumArtist, genre]];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"genreArtistSectionTitle" cacheName:nil];
            aFetchedResultsController.delegate = self;
            fetchedResultsController = aFetchedResultsController;
            
            if (![fetchedResultsController performFetch:nil]) {
                aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
                aFetchedResultsController.delegate = self;
                fetchedResultsController = aFetchedResultsController;
                
                NSError *error = nil;
                if (![fetchedResultsController performFetch:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
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
    
    GenreArtist *genreArtist = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    checkmarkOverlayCell.textLabel.text = genreArtist.artist.name;
    
    if (mode == kVisibilityViewControllerModeEdit) {
        checkmarkOverlayCell.checkmarkOverlayView.hidden = YES;
        checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (mode == kVisibilityViewControllerModeMultiEdit) {
        checkmarkOverlayCell.checkmarkOverlayView.hidden = ![selectedItemsArray containsObject:genreArtist];
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
