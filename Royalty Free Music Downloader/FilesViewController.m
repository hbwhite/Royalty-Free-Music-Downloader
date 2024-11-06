//
//  FilesViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "FilesViewController.h"
#import "VisibilityViewController.h"
#import "AppDelegate.h"
#import "TagEditorNavigationController.h"
#import "SettingsViewController.h"
#import "FilesEditBar.h"
#import "DataManager.h"
#import "File.h"
#import "File+Extensions.h"
#import "Directory.h"
#import "Directory+Path.h"
#import "Archive.h"
#import "Archive+Path.h"
#import "Album.h"
#import "Artist.h"
#import "CheckmarkOverlayCell.h"
#import "ShuffleCell.h"
#import "SongCell.h"
#import "DownloadCell.h"
#import "SongsViewController.h"
#import "PlayerViewController.h"
#import "Player.h"
#import "OptionsActionSheetHandler.h"
#import "StandardCell.h"
#import "TTTUnitOfInformationFormatter.h"
#import "MBProgressHUD.h"
#import "ZipArchive.h"
#import "Unrar4iOS.h"
#import "SkinManager.h"
#import "FilePaths.h"
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "NSArray+Equivalence.h"
#import "NSDateFormatter+Duration.h"
#import "UIImage+SkinImage.h"

#include <math.h>

static NSString *kSortIndexKey      = @"Sort Index";
static NSString *kSortAscendingKey  = @"Sort Ascending";

static NSString *kCopyFormatStr     = @" (%i)";

@interface FilesViewController ()

@property (nonatomic, strong) NSFetchedResultsController *foldersFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *archivesFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *songsFetchedResultsController;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UILabel *itemCountLabel;
@property (nonatomic, strong) Directory *selectedDirectory;
@property (nonatomic, strong) Archive *pendingArchive;
@property (nonatomic) CGRect pendingRect;

@property (nonatomic) kEditButtonIdentifier lastButtonIdentifier;
@property (readwrite) BOOL sortAscending;

- (void)editBarNameButtonPressed;
- (void)editBarDateButtonPressed;
- (void)editBarSizeButtonPressed;
- (void)editBarTimeButtonPressed;
- (NSInteger)itemCount;
- (void)visibilityViewControllerModeDidChange;
- (void)nowPlayingFileDidChange;
- (void)didFinishSearching;
- (void)updateItemCountLabel;
- (NSArray *)arrayForSection:(NSInteger)section;
- (BOOL)fileExistsWithName:(NSString *)fileName parentDirectory:(Directory *)parentDirectory;
- (NSString *)finalFileNameForFileWithName:(NSString *)fileName parentDirectory:(Directory *)parentDirectory;
- (NSString *)destinationPathForFileWithName:(NSString *)fileName parentDirectory:(Directory *)parentDirectory;
- (void)performFetch;
- (NSFetchedResultsController *)foldersFetchedResultsController;
- (NSFetchedResultsController *)archivesFetchedResultsController;
- (NSFetchedResultsController *)songsFetchedResultsController;
- (NSInteger)sectionIndexForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation FilesViewController

// Public
@synthesize delegate;

// Private
@synthesize foldersFetchedResultsController;
@synthesize archivesFetchedResultsController;
@synthesize songsFetchedResultsController;
@synthesize documentInteractionController;
@synthesize dateFormatter;
@synthesize itemCountLabel;
@synthesize selectedDirectory;
@synthesize pendingArchive;
@synthesize pendingRect;

@synthesize lastButtonIdentifier;
@synthesize sortAscending;

- (void)editBarNameButtonPressed {
    if (lastButtonIdentifier == kEditButtonIdentifierName) {
        sortAscending = !sortAscending;
    }
    else {
        sortAscending = YES;
        lastButtonIdentifier = kEditButtonIdentifierName;
    }
    
    [filesEditBar setNameButtonAscending:sortAscending];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:kSortIndexName forKey:kSortIndexKey];
    [defaults setBool:sortAscending forKey:kSortAscendingKey];
    [defaults synchronize];
    
    // Fetch new objects.
    [self performFetch];
    
    [self.tableView reloadData];
}

- (void)editBarDateButtonPressed {
    if (lastButtonIdentifier == kEditButtonIdentifierDate) {
        sortAscending = !sortAscending;
    }
    else {
        sortAscending = YES;
        lastButtonIdentifier = kEditButtonIdentifierDate;
    }
    
    [filesEditBar setDateButtonAscending:sortAscending];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:kSortIndexDate forKey:kSortIndexKey];
    [defaults setBool:sortAscending forKey:kSortAscendingKey];
    [defaults synchronize];
    
    // Fetch new objects.
    [self performFetch];
    
    [self.tableView reloadData];
}

- (void)editBarSizeButtonPressed {
    if (lastButtonIdentifier == kEditButtonIdentifierSize) {
        sortAscending = !sortAscending;
    }
    else {
        sortAscending = YES;
        lastButtonIdentifier = kEditButtonIdentifierSize;
    }
    
    [filesEditBar setSizeButtonAscending:sortAscending];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:kSortIndexSize forKey:kSortIndexKey];
    [defaults setBool:sortAscending forKey:kSortAscendingKey];
    [defaults synchronize];
    
    // Fetch new objects.
    [self performFetch];
    
    [self.tableView reloadData];
}

- (void)editBarTimeButtonPressed {
    if (lastButtonIdentifier == kEditButtonIdentifierTime) {
        sortAscending = !sortAscending;
    }
    else {
        sortAscending = YES;
        lastButtonIdentifier = kEditButtonIdentifierTime;
    }
    
    [filesEditBar setTimeButtonAscending:sortAscending];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:kSortIndexTime forKey:kSortIndexKey];
    [defaults setBool:sortAscending forKey:kSortAscendingKey];
    [defaults synchronize];
    
    // Fetch new objects.
    [self performFetch];
    
    [self.tableView reloadData];
}

- (NSInteger)itemCount {
    return ([[[self foldersFetchedResultsController]fetchedObjects]count] + [[[self archivesFetchedResultsController]fetchedObjects]count] + [[[self songsFetchedResultsController]fetchedObjects]count]);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(visibilityViewControllerModeDidChange) name:kVisibilityViewControllerModeDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(nowPlayingFileDidChange) name:kPlayerNowPlayingFileDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didFinishSearching) name:kVisibilityViewControllerDidFinishSearchingNotification object:nil];
    
    [filesEditBar.nameButton addTarget:self action:@selector(editBarNameButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [filesEditBar.dateButton addTarget:self action:@selector(editBarDateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [filesEditBar.sizeButton addTarget:self action:@selector(editBarSizeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [filesEditBar.timeButton addTarget:self action:@selector(editBarTimeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    kSortIndex sortIndex = [defaults integerForKey:kSortIndexKey];
    sortAscending = [defaults boolForKey:kSortAscendingKey];
    
    if (sortIndex == kSortIndexName) {
        lastButtonIdentifier = kEditButtonIdentifierName;
        [filesEditBar setNameButtonAscending:sortAscending];
    }
    else if (sortIndex == kSortIndexDate) {
        lastButtonIdentifier = kEditButtonIdentifierDate;
        [filesEditBar setDateButtonAscending:sortAscending];
    }
    else if (sortIndex == kSortIndexSize) {
        lastButtonIdentifier = kEditButtonIdentifierSize;
        [filesEditBar setSizeButtonAscending:sortAscending];
    }
    else {
        lastButtonIdentifier = kEditButtonIdentifierTime;
        [filesEditBar setTimeButtonAscending:sortAscending];
    }
    
    formatter = [[TTTUnitOfInformationFormatter alloc]init];
    [formatter setDisplaysInTermsOfBytes:YES];
    [formatter setUsesIECBinaryPrefixesForCalculation:NO];
    [formatter setUsesIECBinaryPrefixesForDisplay:NO];
    
    dateFormatter = [[NSDateFormatter alloc]init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    itemCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    itemCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    itemCountLabel.font = [UIFont systemFontOfSize:20];
    itemCountLabel.textAlignment = UITextAlignmentCenter;
    itemCountLabel.textColor = [UIColor grayColor];
    itemCountLabel.backgroundColor = [UIColor clearColor];
    
    if ([self itemCount] >= 20) {
        [self updateItemCountLabel];
        self.tableView.tableFooterView = itemCountLabel;
    }
    else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)visibilityViewControllerModeDidChange {
    if ((viewIsVisible) && (!searching)) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [self.tableView reloadData];
            
            if (mode == kVisibilityViewControllerModeMultiEdit) {
                if ([[[self songsFetchedResultsController]fetchedObjects]count] >= 20) {
                    [self updateItemCountLabel];
                    self.tableView.tableFooterView = itemCountLabel;
                }
                else {
                    self.tableView.tableFooterView = nil;
                }
            }
            else {
                if ([self itemCount] >= 20) {
                    [self updateItemCountLabel];
                    self.tableView.tableFooterView = itemCountLabel;
                }
                else {
                    self.tableView.tableFooterView = nil;
                }
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
        if ([self itemCount] >= 20) {
            [self updateItemCountLabel];
            self.tableView.tableFooterView = itemCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    });
}

- (void)updateItemCountLabel {
    if (mode == kVisibilityViewControllerModeMultiEdit) {
        itemCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LISTING_COUNT_SONGS_FORMAT", @""), [[[self songsFetchedResultsController]fetchedObjects]count]];
    }
    else {
        itemCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LISTING_COUNT_GENERIC_ITEMS_FORMAT", @""), [self itemCount]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)arrayForSection:(NSInteger)section {
    if (section == 1) {
        return [[self foldersFetchedResultsController]fetchedObjects];
    }
    else if (section == 2) {
        return [[self archivesFetchedResultsController]fetchedObjects];
    }
    else {
        return [[self songsFetchedResultsController]fetchedObjects];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
    
    if (section > 0) {
        if (((mode != kVisibilityViewControllerModeMultiEdit) || ((mode == kVisibilityViewControllerModeMultiEdit) && (section == 3))) &&
            ((mode != kVisibilityViewControllerModeAddToPlaylist) || ((mode == kVisibilityViewControllerModeAddToPlaylist) && (section != 2)))) {
            
            return [[self arrayForSection:section]count];
        }
    }
    else if ([[[self songsFetchedResultsController]fetchedObjects]count] > 1) {
        if (mode != kVisibilityViewControllerModeEdit) {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ((mode == kVisibilityViewControllerModeAddToPlaylist) || (mode == kVisibilityViewControllerModeMultiEdit) || (mode == kVisibilityViewControllerModeMove)) {
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
    else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"Cell 3";
        
        CheckmarkOverlayCell *cell = (CheckmarkOverlayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CheckmarkOverlayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    else if (indexPath.section == 2) {
        static NSString *CellIdentifier = @"Cell 4";
        
        CheckmarkOverlayCell *cell = (CheckmarkOverlayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CheckmarkOverlayCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 5";
        
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
    return ((mode != kVisibilityViewControllerModeAddToPlaylist) && (mode != kVisibilityViewControllerModeMultiEdit) && (mode != kVisibilityViewControllerModeMultiEdit) && (indexPath.section > 0));
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        DataManager *dataManager = [DataManager sharedDataManager];
        
        if (indexPath.section == 1) {
            Directory *directory = [[[self foldersFetchedResultsController]fetchedObjects]objectAtIndex:indexPath.row];
            [dataManager deleteDirectory:directory];
        }
        else if (indexPath.section == 2) {
            Archive *archive = [[[self archivesFetchedResultsController]fetchedObjects]objectAtIndex:indexPath.row];
            [dataManager deleteArchive:archive];
        }
        else {
            File *file = [[[self songsFetchedResultsController]fetchedObjects]objectAtIndex:indexPath.row];
            [dataManager deleteFile:file];
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
        NSArray *itemsArray = [[self songsFetchedResultsController]fetchedObjects];
        
        if (mode == kVisibilityViewControllerModeMove) {
            if ([selectedItemsArray containsObjectsInArray:itemsArray]) {
                [selectedItemsArray removeAllObjects];
            }
            else {
                [selectedItemsArray setArray:itemsArray];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([tableView numberOfSections] - 1))] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            NSArray *filesArray = [[self songsFetchedResultsController]fetchedObjects];
            
            if (mode == kVisibilityViewControllerModeNone) {
                Player *player = [Player sharedPlayer];
                [player setPlaylistItems:filesArray];
                [player shuffle];
                
                PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
                [self.navigationController pushViewController:playerViewController animated:YES];
            }
            else if (mode == kVisibilityViewControllerModeMultiEdit) {
                if ([selectedFilesArray containsObjectsInArray:filesArray]) {
                    [selectedFilesArray removeAllObjects];
                }
                else {
                    [selectedFilesArray setArray:filesArray];
                }
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([tableView numberOfSections] - 1))] withRowAnimation:UITableViewRowAnimationNone];
            }
            else if (mode == kVisibilityViewControllerModeAddToPlaylist) {
                [songSelectorDelegate songSelectorDidSelectFiles:filesArray];
                [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForRowsInRect:CGRectMake(0, self.tableView.contentOffset.y, self.tableView.frame.size.width, self.tableView.frame.size.height)] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
    else {
        id item = [[self arrayForSection:indexPath.section]objectAtIndex:indexPath.row];
        if (mode == kVisibilityViewControllerModeMove) {
            if ([selectedItemsArray containsObject:item]) {
                [selectedItemsArray removeObject:item];
            }
            else {
                [selectedItemsArray addObject:item];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            if ([item isKindOfClass:[Directory class]]) {
                selectedDirectory = item;
                
                FilesViewController *filesViewController = [[FilesViewController alloc]initWithDelegate:self];
                filesViewController.songSelectorDelegate = songSelectorDelegate;
                filesViewController.title = selectedDirectory.name;
                [self.navigationController pushViewController:filesViewController animated:YES];
            }
            else if ([item isKindOfClass:[Archive class]]) {
                pendingArchive = item;
                
                pendingRect = [[tableView cellForRowAtIndexPath:indexPath]frame];
                
                UIActionSheet *optionsActionSheet = [[UIActionSheet alloc]
                                                     initWithTitle:pendingArchive.fileName
                                                     delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                     destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Extract", @"Email", @"Open In...", nil];
                [optionsActionSheet showFromRect:pendingRect inView:self.tableView animated:YES];
            }
            else if ([item isKindOfClass:[File class]]) {
                if (mode == kVisibilityViewControllerModeNone) {
                    Player *player = [Player sharedPlayer];
                    
                    [player setPlaylistItems:[[self songsFetchedResultsController]fetchedObjects]];
                    [player setCurrentFileWithIndex:indexPath.row];
                    
                    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
                    [self.navigationController pushViewController:playerViewController animated:YES];
                }
                else if (mode == kVisibilityViewControllerModeMultiEdit) {
                    if ([selectedFilesArray containsObject:item]) {
                        [selectedFilesArray removeObject:item];
                    }
                    else {
                        [selectedFilesArray addObject:item];
                    }
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                else if (mode == kVisibilityViewControllerModeAddToPlaylist) {
                    [songSelectorDelegate songSelectorDidSelectFile:item];
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    id item = [[self arrayForSection:indexPath.section]objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[Directory class]]) {
        [self renameDirectory:item];
    }
    else if ([item isKindOfClass:[Archive class]]) {
        [self renameArchive:item];
    }
    else {
        [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForFiles:[[self songsFetchedResultsController]fetchedObjects] fileIndex:indexPath.row fromIndexPath:indexPath inTableView:tableView canDelete:NO];
    }
}

- (Directory *)filesViewControllerParentDirectory {
    return selectedDirectory;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSString *pendingArchivePath = [pendingArchive path];
        NSString *extractionPath = [self destinationPathForFileWithName:[pendingArchive.fileName stringByDeletingPathExtension] parentDirectory:pendingArchive.parentDirectoryRef];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];
        hud.dimBackground = YES;
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Extracting...";
        [self.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            BOOL success = NO;
            
            if ([[[pendingArchivePath pathExtension]lowercaseString]isEqualToString:@"zip"]) {
                ZipArchive *zipArchive = [[ZipArchive alloc]init];
                
                if ([zipArchive UnzipOpenFile:pendingArchivePath]) {
                    if ([zipArchive UnzipFileTo:extractionPath overWrite:NO]) {
                        if ([zipArchive UnzipCloseFile]) {
                            success = YES;
                        }
                    }
                }
            }
            else {
                Unrar4iOS *unrar = [[Unrar4iOS alloc]init];
                
                if ([unrar unrarOpenFile:pendingArchivePath]) {
                    if ([unrar unrarFileTo:extractionPath overWrite:NO]) {
                        if ([unrar unrarCloseFile]) {
                            success = YES;
                        }
                    }
                }
            }
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [[DataManager sharedDataManager]updateLibraryWithUpdateType:kLibraryUpdateTypeFiles];
                
                if (!success) {
                    UIAlertView *errorAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Extraction Error"
                                               message:@"The app encountered an error while trying to extract the contents of the archive. The archive may be corrupt or in a format that the app doesn't recognize."
                                               delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil];
                    [errorAlert show];
                }
            });
        }];
    }
    else if (buttonIndex == 1) {
        NSString *pendingArchivePath = [pendingArchive path];
        
        NSString *mimeTypeString = nil;
        
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[pendingArchivePath pathExtension], NULL);
        CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        if (mimeType) {
            mimeTypeString = (__bridge NSString *)mimeType;
        }
        else {
            mimeTypeString = @"application/octet-stream";
        }
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
            mailComposeViewController.mailComposeDelegate = self;
            
            // Apple will reject apps that use full screen modal view controllers on the iPad.
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            
            [mailComposeViewController addAttachmentData:[NSData dataWithContentsOfFile:pendingArchivePath] mimeType:mimeTypeString fileName:[pendingArchivePath lastPathComponent]];
            [self safelyPresentModalViewController:mailComposeViewController animated:YES completion:nil];
        }
        else {
            UIAlertView *cannotSendMailAlert = [[UIAlertView alloc]
                                                initWithTitle:@"Cannot Send Email"
                                                message:@"You must configure your device to work with your email account in order to send email. Would you like to do this now?"
                                                delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            [cannotSendMailAlert show];
        }
    }
    else if (buttonIndex == 2) {
        documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[pendingArchive path]]];
        documentInteractionController.delegate = self;
        [documentInteractionController presentOptionsMenuFromRect:pendingRect inView:self.tableView animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto:"]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultFailed) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error"
                                   message:@"Your message could not be sent. This could be due to little or no Internet connectivity."
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (BOOL)fileExistsWithName:(NSString *)fileName parentDirectory:(Directory *)parentDirectory {
    NSString *formattedFileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (parentDirectory) {
        return [fileManager fileExistsAtPath:[[parentDirectory path]stringByAppendingPathComponent:formattedFileName]];
    }
    else {
        return [fileManager fileExistsAtPath:[kMusicDirectoryPathStr stringByAppendingPathComponent:formattedFileName]];
    }
}

- (NSString *)finalFileNameForFileWithName:(NSString *)fileName parentDirectory:(Directory *)parentDirectory {
    NSString *finalFileName = @"Untitled";
    if ((fileName) && ([fileName length] > 0)) {
        finalFileName = fileName;
    }
    
    if ([self fileExistsWithName:finalFileName parentDirectory:parentDirectory]) {
        NSString *filePathExtension = [finalFileName pathExtension];
        if ([filePathExtension length] > 0) {
            NSString *baseFileName = [finalFileName stringByDeletingPathExtension];
            
            NSInteger copyNumber = 2;
            while ([self fileExistsWithName:[[baseFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]stringByAppendingPathExtension:filePathExtension] parentDirectory:parentDirectory]) {
                copyNumber += 1;
            }
            return [[baseFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]stringByAppendingPathExtension:filePathExtension];
        }
        else {
            NSInteger copyNumber = 2;
            while ([self fileExistsWithName:[finalFileName stringByAppendingFormat:kCopyFormatStr, copyNumber] parentDirectory:parentDirectory]) {
                copyNumber += 1;
            }
            return [finalFileName stringByAppendingFormat:kCopyFormatStr, copyNumber];
        }
    }
    else {
        return finalFileName;
    }
}

- (NSString *)destinationPathForFileWithName:(NSString *)fileName parentDirectory:(Directory *)parentDirectory {
    NSString *formattedFileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *finalFileName = [self finalFileNameForFileWithName:formattedFileName parentDirectory:parentDirectory];
    
    if (parentDirectory) {
        return [[parentDirectory path]stringByAppendingPathComponent:finalFileName];
    }
    else {
        return [kMusicDirectoryPathStr stringByAppendingPathComponent:finalFileName];
    }
}

#pragma mark -
#pragma mark - Fetched results controllers

- (void)performFetch {
    foldersFetchedResultsController = nil;
    archivesFetchedResultsController = nil;
    songsFetchedResultsController = nil;
    
    // The fetched results controllers automatically fetch new objects when they are initialized, so calling performFetch: is unnecessary.
    [self foldersFetchedResultsController];
    [self archivesFetchedResultsController];
    [self songsFetchedResultsController];
}

- (NSFetchedResultsController *)foldersFetchedResultsController {
    if (!foldersFetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Directory" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSArray *sortDescriptors = nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        kSortIndex sortIndex = [defaults integerForKey:kSortIndexKey];
        BOOL savedSortAscending = [defaults integerForKey:kSortAscendingKey];
        
        // Default to the name sort descriptor.
        if (sortIndex == kSortIndexDate) {
            NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:savedSortAscending];
            sortDescriptors = [NSArray arrayWithObjects:creationDateSortDescriptor, nil];
        }
        else {
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:savedSortAscending];
            sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
        }
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        Directory *parentDirectory = nil;
        
        if (delegate) {
            parentDirectory = [delegate filesViewControllerParentDirectory];
        }
        
        if (parentDirectory) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentDirectoryRef == %@", parentDirectory]];
        }
        else {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentDirectoryRef == nil"]];
        }
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* (!parentDirectory) ? @"Directory_Cache" : */ nil];
        aFetchedResultsController.delegate = self;
        foldersFetchedResultsController = aFetchedResultsController;
        
        // @try {
            NSError *error = nil;
            if (![foldersFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        // }
        /*
        @catch (NSException *exception) {
            [NSFetchedResultsController deleteCacheWithName:@"Directory_Cache"];
            
            NSError *error = nil;
            if (![foldersFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        */
    }
    
    return foldersFetchedResultsController;
}

- (NSFetchedResultsController *)archivesFetchedResultsController {
    if (!archivesFetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Archive" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSArray *sortDescriptors = nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        kSortIndex sortIndex = [defaults integerForKey:kSortIndexKey];
        BOOL savedSortAscending = [defaults integerForKey:kSortAscendingKey];
        
        // Default to the name sort descriptor.
        if (sortIndex == kSortIndexDate) {
            NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:savedSortAscending];
            sortDescriptors = [NSArray arrayWithObjects:creationDateSortDescriptor, nil];
        }
        else if (sortIndex == kSortIndexSize) {
            NSSortDescriptor *sizeSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"bytes" ascending:savedSortAscending];
            sortDescriptors = [NSArray arrayWithObjects:sizeSortDescriptor, nil];
        }
        else {
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"fileName" ascending:savedSortAscending];
            sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
        }
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        Directory *parentDirectory = nil;
        
        if (delegate) {
            parentDirectory = [delegate filesViewControllerParentDirectory];
        }
        
        if (parentDirectory) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentDirectoryRef == %@", parentDirectory]];
        }
        else {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentDirectoryRef == nil"]];
        }
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* (!parentDirectory) ? @"Archive_Cache" : */ nil];
        aFetchedResultsController.delegate = self;
        archivesFetchedResultsController = aFetchedResultsController;
        
        // @try {
            NSError *error = nil;
            if (![archivesFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        // }
        /*
        @catch (NSException *exception) {
            [NSFetchedResultsController deleteCacheWithName:@"Archive_Cache"];
            
            NSError *error = nil;
            if (![archivesFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        */
    }
    
    return archivesFetchedResultsController;
}

- (NSFetchedResultsController *)songsFetchedResultsController {
    if (!songsFetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSArray *sortDescriptors = nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        kSortIndex sortIndex = [defaults integerForKey:kSortIndexKey];
        BOOL savedSortAscending = [defaults integerForKey:kSortAscendingKey];
        
        if (sortIndex == kSortIndexName) {
            NSSortDescriptor *fileNameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"fileName" ascending:savedSortAscending selector:@selector(localizedStandardCompare:)];
            sortDescriptors = [NSArray arrayWithObjects:fileNameSortDescriptor, nil];
        }
        else if (sortIndex == kSortIndexDate) {
            NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:savedSortAscending];
            sortDescriptors = [NSArray arrayWithObjects:creationDateSortDescriptor, nil];
        }
        else if (sortIndex == kSortIndexSize) {
            NSSortDescriptor *sizeSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"bytes" ascending:savedSortAscending];
            sortDescriptors = [NSArray arrayWithObjects:sizeSortDescriptor, nil];
        }
        else {
            NSSortDescriptor *durationSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"duration" ascending:savedSortAscending];
            sortDescriptors = [NSArray arrayWithObjects:durationSortDescriptor, nil];
        }
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        Directory *parentDirectory = nil;
        
        if (delegate) {
            parentDirectory = [delegate filesViewControllerParentDirectory];
        }
        
        if (parentDirectory) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(iPodMusicLibraryFile == %@) AND (parentDirectoryRef == %@)", [NSNumber numberWithBool:NO], parentDirectory]];
        }
        else {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(iPodMusicLibraryFile == %@) AND (parentDirectoryRef == nil)", [NSNumber numberWithBool:NO]]];
        }
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* (!parentDirectory) ? @"File_Cache" : */ nil];
        aFetchedResultsController.delegate = self;
        songsFetchedResultsController = aFetchedResultsController;
        
        // @try {
            NSError *error = nil;
            if (![songsFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        // }
        /*
        @catch (NSException *exception) {
            [NSFetchedResultsController deleteCacheWithName:@"File_Cache"];
            
            NSError *error = nil;
            if (![songsFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        */
    }
    
    return songsFetchedResultsController;
}

- (NSInteger)sectionIndexForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    if ([fetchedResultsController isEqual:foldersFetchedResultsController]) {
        return 1;
    }
    else if ([fetchedResultsController isEqual:archivesFetchedResultsController]) {
        return 2;
    }
    else {
        return 3;
    }
}

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!searching) {
        [self.tableView reloadData];
        
        if ([self itemCount] >= 20) {
            [self updateItemCountLabel];
            self.tableView.tableFooterView = itemCountLabel;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        CheckmarkOverlayCell *checkmarkOverlayCell = (CheckmarkOverlayCell *)cell;
        
        Directory *directory = [[[self foldersFetchedResultsController]fetchedObjects]objectAtIndex:indexPath.row];
        
        checkmarkOverlayCell.textLabel.text = directory.name;
        
        if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
            checkmarkOverlayCell.imageView.image = [UIImage imageNamed:@"Folder-Dark"];
            
            if ([SkinManager iOS6Skin]) {
                checkmarkOverlayCell.imageView.highlightedImage = [UIImage imageNamed:@"Folder-Dark-Selected"];
            }
            else {
                checkmarkOverlayCell.imageView.highlightedImage = cell.imageView.image;
            }
        }
        else {
            checkmarkOverlayCell.imageView.image = [UIImage imageNamed:@"Folder"];
            checkmarkOverlayCell.imageView.highlightedImage = cell.imageView.image;
        }
        
        if (mode == kVisibilityViewControllerModeMove) {
            checkmarkOverlayCell.checkmarkOverlayView.hidden = ![selectedItemsArray containsObject:directory];
        }
        else {
            checkmarkOverlayCell.checkmarkOverlayView.hidden = YES;
        }
        
        if (mode == kVisibilityViewControllerModeAddToPlaylist) {
            checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        
        checkmarkOverlayCell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else if (indexPath.section == 2) {
        CheckmarkOverlayCell *checkmarkOverlayCell = (CheckmarkOverlayCell *)cell;
        
        Archive *archive = [[[self archivesFetchedResultsController]fetchedObjects]objectAtIndex:indexPath.row];
        
        checkmarkOverlayCell.textLabel.text = archive.fileName;
        
        NSString *fileSizeString = [formatter stringFromNumber:archive.bytes ofUnit:TTTByte];
        NSString *creationDateString = [dateFormatter stringFromDate:archive.creationDate];
        
        checkmarkOverlayCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", fileSizeString, creationDateString];
        
        checkmarkOverlayCell.imageView.image = [UIImage imageNamed:@"File"];
        
        if ([SkinManager iOS7Skin]) {
            checkmarkOverlayCell.imageView.highlightedImage = [UIImage imageNamed:@"File"];
        }
        else {
            checkmarkOverlayCell.imageView.highlightedImage = [UIImage imageNamed:@"File-Selected"];
        }
        
        if (mode == kVisibilityViewControllerModeMove) {
            checkmarkOverlayCell.checkmarkOverlayView.hidden = ![selectedItemsArray containsObject:archive];
        }
        else {
            checkmarkOverlayCell.checkmarkOverlayView.hidden = YES;
        }
        
        checkmarkOverlayCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        checkmarkOverlayCell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else {
        SongCell *songCell = (SongCell *)cell;
        
        File *file = [[[self songsFetchedResultsController]fetchedObjects]objectAtIndex:indexPath.row];
        
        songCell.textLabel.text = file.fileName;
        
        NSString *durationString = [NSDateFormatter formattedDuration:[file.duration longValue]];
        NSString *fileSizeString = [formatter stringFromNumber:file.bytes ofUnit:TTTByte];
        NSString *creationDateString = [dateFormatter stringFromDate:file.creationDate];
        
        songCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@ / %@", durationString, fileSizeString, creationDateString];
        
        songCell.imageView.image = [UIImage imageNamed:@"Song"];
        
        if ([SkinManager iOS7Skin]) {
            songCell.imageView.highlightedImage = [UIImage imageNamed:@"Song"];
        }
        else {
            songCell.imageView.highlightedImage = [UIImage imageNamed:@"Song-Selected"];
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
            else if (mode == kVisibilityViewControllerModeMove) {
                songCell.checkmarkOverlayView.hidden = ![selectedItemsArray containsObject:file];
            }
            else {
                songCell.checkmarkOverlayView.hidden = YES;
            }
            
            songCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            songCell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        
        songCell.nowPlayingImageView.hidden = ![[[Player sharedPlayer]nowPlayingFile]isEqual:file];
    }
}

- (void)dealloc {
    foldersFetchedResultsController.delegate = nil;
    archivesFetchedResultsController.delegate = nil;
    songsFetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
