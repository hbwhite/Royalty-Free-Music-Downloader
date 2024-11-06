//
//  GenreSongsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "GenreSongsViewController.h"
#import "VisibilityViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "DataManager.h"
#import "File.h"
#import "Album.h"
#import "Artist.h"
#import "ShuffleCell.h"
#import "SongCell.h"
#import "PlayerViewController.h"
#import "Player.h"
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

@interface GenreSongsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *editingFetchedResultsController;
@property (nonatomic, strong) UILabel *songCountLabel;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)visibilityViewControllerModeDidChange;
- (void)nowPlayingFileDidChange;
- (void)didFinishSearching;
- (void)updateSongCountLabel;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation GenreSongsViewController

// Public
@synthesize delegate;

// Private
@synthesize fetchedResultsController;
@synthesize editingFetchedResultsController;
@synthesize songCountLabel;

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
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        fetchedResultsController = nil;
        
        // Fetch new objects.
        [self fetchedResultsController];
        
        if ([[[self fetchedResultsController]fetchedObjects]count] > 0) {
            [self.tableView reloadData];
            
            if ([[[self fetchedResultsController]fetchedObjects]count] >= 20) {
                [self updateSongCountLabel];
                self.tableView.tableFooterView = songCountLabel;
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
                [self updateSongCountLabel];
                self.tableView.tableFooterView = songCountLabel;
            }
            else {
                self.tableView.tableFooterView = nil;
            }
        });
    }
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return ((mode != kVisibilityViewControllerModeAddToPlaylist) && (mode != kVisibilityViewControllerModeMultiEdit) && (indexPath.section > 0));
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        File *file = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
        
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
    
    if (mode == kVisibilityViewControllerModeNone) {
        Player *player = [Player sharedPlayer];
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        [player setPlaylistItems:currentFetchedResultsController.fetchedObjects];
        
        if (indexPath.section == 0) {
            [player shuffle];
        }
        else {
            File *file = [currentFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            [player setCurrentFileWithIndex:[currentFetchedResultsController.fetchedObjects indexOfObject:file]];
        }
        
        PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
        [self.navigationController pushViewController:playerViewController animated:YES];
    }
    else if (mode == kVisibilityViewControllerModeMultiEdit) {
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        if (indexPath.section == 0) {
            NSArray *songsArray = currentFetchedResultsController.fetchedObjects;
            if ([selectedFilesArray containsObjectsInArray:songsArray]) {
                [selectedFilesArray removeAllObjects];
            }
            else {
                [selectedFilesArray setArray:songsArray];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([tableView numberOfSections] - 1))] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            File *file = [currentFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            if ([selectedFilesArray containsObject:file]) {
                [selectedFilesArray removeObject:file];
            }
            else {
                [selectedFilesArray addObject:file];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if (mode == kVisibilityViewControllerModeAddToPlaylist) {
        NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
        if (indexPath.section == 0) {
            [songSelectorDelegate songSelectorDidSelectFiles:currentFetchedResultsController.fetchedObjects];
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForRowsInRect:CGRectMake(0, self.tableView.contentOffset.y, self.tableView.frame.size.width, self.tableView.frame.size.height)] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            File *file = [currentFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
            [songSelectorDelegate songSelectorDidSelectFile:file];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSFetchedResultsController *currentFetchedResultsController = [self fetchedResultsController];
    File *file = [currentFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForFiles:currentFetchedResultsController.fetchedObjects fileIndex:[currentFetchedResultsController.fetchedObjects indexOfObject:file] fromIndexPath:indexPath inTableView:tableView canDelete:NO];
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
            
            NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *trackSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"track" ascending:YES];
            NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO];
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:titleSortDescriptor, albumByAlbumArtistSortDescriptor, albumByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, trackSortDescriptor, creationDateSortDescriptor, nil]];
            }
            else {
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:titleSortDescriptor, albumByArtistSortDescriptor, albumByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, trackSortDescriptor, creationDateSortDescriptor, nil]];
            }
            
            GenreArtist *genreArtist = nil;
            Genre *genre = nil;
            if (delegate) {
                if ([delegate respondsToSelector:@selector(genreSongsViewControllerGenreArtist)]) {
                    genreArtist = [delegate genreSongsViewControllerGenreArtist];
                }
                if ([delegate respondsToSelector:@selector(genreSongsViewControllerGenre)]) {
                    genre = [delegate genreSongsViewControllerGenre];
                }
            }
            if (genreArtist) {
                if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(genreArtistRefForAlbumArtistGroup == %@) AND (iPodMusicLibraryFile == %@)", genreArtist, [NSNumber numberWithBool:NO]]];
                }
                else {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(genreArtistRefForArtistGroup == %@) AND (iPodMusicLibraryFile == %@)", genreArtist, [NSNumber numberWithBool:NO]]];
                }
            }
            else if (genre) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(genreRef == %@) AND (iPodMusicLibraryFile == %@)", genre, [NSNumber numberWithBool:NO]]];
            }
            else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"iPodMusicLibraryFile == %@", [NSNumber numberWithBool:NO]]];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"fileSectionTitle" cacheName:nil];
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
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *trackSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"track" ascending:YES];
            NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO];
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:titleSortDescriptor, albumByAlbumArtistSortDescriptor, albumByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, trackSortDescriptor, creationDateSortDescriptor, nil]];
            }
            else {
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:titleSortDescriptor, albumByArtistSortDescriptor, albumByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, trackSortDescriptor, creationDateSortDescriptor, nil]];
            }
            
            GenreArtist *genreArtist = nil;
            Genre *genre = nil;
            if (delegate) {
                if ([delegate respondsToSelector:@selector(genreSongsViewControllerGenreArtist)]) {
                    genreArtist = [delegate genreSongsViewControllerGenreArtist];
                }
                if ([delegate respondsToSelector:@selector(genreSongsViewControllerGenre)]) {
                    genre = [delegate genreSongsViewControllerGenre];
                }
            }
            if (genreArtist) {
                if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"genreArtistRefForAlbumArtistGroup == %@", genreArtist]];
                }
                else {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"genreArtistRefForArtistGroup == %@", genreArtist]];
                }
            }
            else if (genre) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"genreRef == %@", genre]];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"fileSectionTitle" cacheName:nil];
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
            [self updateSongCountLabel];
            self.tableView.tableFooterView = songCountLabel;
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
    SongCell *songCell = (SongCell *)cell;
    
    File *file = [[self fetchedResultsController]objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)]];
    
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
    editingFetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
