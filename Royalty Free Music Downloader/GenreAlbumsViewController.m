//
//  GenreAlbumsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "GenreAlbumsViewController.h"
#import "VisibilityViewController.h"
#import "SettingsViewController.h"
#import "DataManager.h"
#import "GenreAlbum.h"
#import "Album.h"
#import "Album+Extensions.h"
#import "GenreArtist.h"
#import "Artist.h"
#import "ArtworkCell.h"
#import "ThumbnailLoader.h"
#import "MultipleTagEditorNavigationController.h"
#import "OptionsActionSheetHandler.h"
#import "SkinManager.h"
#import "StandardCell.h"
#import "NSArray+Equivalence.h"
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "UILocalizedIndexedCollation+StandardizedSectionIndexTitles.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface GenreAlbumsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *editingFetchedResultsController;
@property (nonatomic, strong) UILabel *albumCountLabel;
@property (nonatomic, strong) GenreAlbum *selectedGenreAlbum;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)visibilityViewControllerModeDidChange;
- (void)didFinishSearching;
- (void)updateAlbumCountLabel;
- (NSArray *)songsForGenreAlbum:(GenreAlbum *)genreAlbum;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation GenreAlbumsViewController

// Public
@synthesize delegate;

// Private
@synthesize fetchedResultsController;
@synthesize editingFetchedResultsController;
@synthesize albumCountLabel;
@synthesize selectedGenreAlbum;

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
    
    albumCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    albumCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    albumCountLabel.font = [UIFont systemFontOfSize:20];
    albumCountLabel.textAlignment = UITextAlignmentCenter;
    albumCountLabel.textColor = [UIColor grayColor];
    albumCountLabel.backgroundColor = [UIColor clearColor];
    if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
        [self updateAlbumCountLabel];
        self.tableView.tableFooterView = albumCountLabel;
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
                [self updateAlbumCountLabel];
                self.tableView.tableFooterView = albumCountLabel;
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
                [self updateAlbumCountLabel];
                self.tableView.tableFooterView = albumCountLabel;
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
            [self updateAlbumCountLabel];
            self.tableView.tableFooterView = albumCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    });
}

- (void)updateAlbumCountLabel {
    albumCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LISTING_COUNT_ALBUMS_FORMAT", @""), [[[self fetchedResultsController]fetchedObjects]count]];
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
            cell.textLabel.text = NSLocalizedString(@"Add All Songs", @"");
            
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
            cell.textLabel.text = NSLocalizedString(@"All Songs", @"");
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
        
        ArtworkCell *cell = (ArtworkCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ArtworkCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
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
        
        GenreAlbum *genreAlbum = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
        
        NSSet *files = nil;
        
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
            files = [genreAlbum filesForAlbumArtistGroup];
        }
        else {
            files = [genreAlbum filesForArtistGroup];
        }
        
        if ([[files filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"iPodMusicLibraryFile == %@", [NSNumber numberWithBool:YES]]]count] > 0) {
            UIAlertView *cannotDeleteAlert = [[UIAlertView alloc]
                                              initWithTitle:@"Cannot Delete Album"
                                              message:@"You cannot delete albums with songs from your iPod music library."
                                              delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
            [cannotDeleteAlert show];
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [[DataManager sharedDataManager]deleteGenreAlbum:genreAlbum];
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
            selectedGenreAlbum = nil;
            
            GenreSongsViewController *genreSongsViewController = [[GenreSongsViewController alloc]initWithDelegate:self];
            genreSongsViewController.songSelectorDelegate = songSelectorDelegate;
            genreSongsViewController.title = NSLocalizedString(@"Songs", @"");
            [self.navigationController pushViewController:genreSongsViewController animated:YES];
        }
        else if (mode == kVisibilityViewControllerModeMultiEdit) {
            NSArray *genreAlbumsArray = [[self fetchedResultsController]fetchedObjects];
            if ([selectedItemsArray containsObjectsInArray:genreAlbumsArray]) {
                [selectedItemsArray removeAllObjects];
                [selectedFilesArray removeAllObjects];
            }
            else {
                [selectedItemsArray setArray:genreAlbumsArray];
                
                [selectedFilesArray removeAllObjects];
                for (int i = 0; i < [genreAlbumsArray count]; i++) {
                    GenreAlbum *genreAlbum = [genreAlbumsArray objectAtIndex:i];
                    [selectedFilesArray addObjectsFromArray:[self songsForGenreAlbum:genreAlbum]];
                }
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([tableView numberOfSections] - 1))] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (mode == kVisibilityViewControllerModeAddToPlaylist) {
            NSArray *genreAlbumsArray = [[self fetchedResultsController]fetchedObjects];
            for (int i = 0; i < [genreAlbumsArray  count]; i++) {
                GenreAlbum *genreAlbum = [genreAlbumsArray objectAtIndex:i];
                [songSelectorDelegate songSelectorDidSelectFiles:[self songsForGenreAlbum:genreAlbum]];
            }
        }
    }
    else {
        if (mode == kVisibilityViewControllerModeMultiEdit) {
            GenreAlbum *genreAlbum = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            if ([selectedItemsArray containsObject:genreAlbum]) {
                [selectedItemsArray removeObject:genreAlbum];
                [selectedFilesArray removeObjectsInArray:[self songsForGenreAlbum:genreAlbum]];
            }
            else {
                [selectedItemsArray addObject:genreAlbum];
                [selectedFilesArray addObjectsFromArray:[self songsForGenreAlbum:genreAlbum]];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            selectedGenreAlbum = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            
            GenreSingleAlbumViewController *genreSingleAlbumViewController = [[GenreSingleAlbumViewController alloc]initWithDelegate:self];
            genreSingleAlbumViewController.songSelectorDelegate = songSelectorDelegate;
            genreSingleAlbumViewController.title = selectedGenreAlbum.album.name;
            [self.navigationController pushViewController:genreSingleAlbumViewController animated:YES];
        }
    }
}

- (NSArray *)songsForGenreAlbum:(GenreAlbum *)genreAlbum {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        return [genreAlbum.filesForAlbumArtistGroup allObjects];
    }
    else {
        return [genreAlbum.filesForArtistGroup allObjects];
    }
}

- (Genre *)genreSongsViewControllerGenre {
    return [delegate genreAlbumsViewControllerGenre];
}

- (GenreArtist *)genreSongsViewControllerGenreArtist {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(genreAlbumsViewControllerGenreArtist)]) {
            return [delegate genreAlbumsViewControllerGenreArtist];
        }
    }
    return nil;
}

- (Genre *)genreSingleAlbumViewControllerGenre {
    return [delegate genreAlbumsViewControllerGenre];
}

- (Album *)genreSingleAlbumViewControllerAlbum {
    return selectedGenreAlbum.album;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    GenreAlbum *genreAlbum = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    
    NSArray *files = nil;
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        files = [genreAlbum.filesForAlbumArtistGroup allObjects];
    }
    else {
        files = [genreAlbum.filesForArtistGroup allObjects];
    }
    
    [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForMultipleFiles:files fromIndexPath:indexPath inTableView:tableView searchString:genreAlbum.album.name canDelete:NO];
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if ((mode == kVisibilityViewControllerModeEdit) || (mode == kVisibilityViewControllerModeMultiEdit)) {
        if (!editingFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"GenreAlbum" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"album.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"album.artist.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, artistSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            Artist *artist = nil;
            if (delegate) {
                if ([delegate respondsToSelector:@selector(genreAlbumsViewControllerGenreArtist)]) {
                    artist = [[delegate genreAlbumsViewControllerGenreArtist]artist];
                }
            }
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            Genre *genre = [delegate genreAlbumsViewControllerGenre];
            if (artist) {
                if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(album.groupByAlbumArtist == %@) AND (genre == %@) AND (album.artist == %@) AND (SUBQUERY(filesForAlbumArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0)", groupByAlbumArtist, genre, artist, [NSNumber numberWithBool:YES]]];
                }
                else {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(album.groupByAlbumArtist == %@) AND (genre == %@) AND (album.artist == %@) AND (SUBQUERY(filesForArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0)", groupByAlbumArtist, genre, artist, [NSNumber numberWithBool:YES]]];
                }
            }
            else {
                if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(album.groupByAlbumArtist == %@) AND (genre == %@) AND (SUBQUERY(filesForAlbumArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0)", groupByAlbumArtist, genre, [NSNumber numberWithBool:YES]]];
                }
                else {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(album.groupByAlbumArtist == %@) AND (genre == %@) AND (SUBQUERY(filesForArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0)", groupByAlbumArtist, genre, [NSNumber numberWithBool:YES]]];
                }
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"genreAlbumSectionTitle" cacheName:nil];
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
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"GenreAlbum" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"album.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"album.artist.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, artistSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            Artist *artist = nil;
            if (delegate) {
                if ([delegate respondsToSelector:@selector(genreAlbumsViewControllerGenreArtist)]) {
                    artist = [[delegate genreAlbumsViewControllerGenreArtist]artist];
                }
            }
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            Genre *genre = [delegate genreAlbumsViewControllerGenre];
            if (artist) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(album.groupByAlbumArtist == %@) AND (genre == %@) AND (album.artist == %@)", groupByAlbumArtist, genre, artist]];
            }
            else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(album.groupByAlbumArtist == %@) AND (genre == %@)", groupByAlbumArtist, genre]];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"genreAlbumSectionTitle" cacheName:nil];
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
            [self updateAlbumCountLabel];
            self.tableView.tableFooterView = albumCountLabel;
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
    ArtworkCell *artworkCell = (ArtworkCell *)cell;
    
    GenreAlbum *genreAlbum = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    Album *album = genreAlbum.album;
    
    artworkCell.textLabel.text = album.name;
    if (album.artist) {
        artworkCell.detailTextLabel.text = album.artist.name;
    }
    
    [[ThumbnailLoader sharedThumbnailLoader]loadThumbnailForCell:artworkCell atIndexPath:indexPath inTableView:self.tableView artworkContainer:album];
    
    if (mode == kVisibilityViewControllerModeEdit) {
        artworkCell.checkmarkOverlayView.hidden = YES;
        artworkCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (mode == kVisibilityViewControllerModeMultiEdit) {
        artworkCell.checkmarkOverlayView.hidden = ![selectedItemsArray containsObject:genreAlbum];
        artworkCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        artworkCell.checkmarkOverlayView.hidden = YES;
        
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        if (([currentFetchedResultsController.fetchedObjects count] < 30) || (!currentFetchedResultsController.sectionNameKeyPath)) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}

- (void)dealloc {
    fetchedResultsController.delegate = nil;
    editingFetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
