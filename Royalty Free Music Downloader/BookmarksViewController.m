//
//  BookmarksViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "BookmarksViewController.h"
#import "EditBookmarkViewController.h"
#import "EditBookmarkFolderViewController.h"
#import "DataManager.h"
#import "BookmarkItem.h"
#import "Bookmark.h"
#import "BookmarkFolder.h"
#import "StandardCell.h"
#import "SkinManager.h"
#import "UINavigationItem+SafeAnimation.h"

static NSString *kHelpURLStr    = @"http://www.harrisonapps.com/royaltyfreemusic/";

@interface BookmarksViewController ()

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *editDoneButton;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpaceBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *createNewFolderButton;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) BookmarkItem *selectedBookmarkFolder;

- (void)doneButtonPressed;
- (void)editButtonPressed;
- (void)editDoneButtonPressed;
- (void)createNewFolderButtonPressed;

@end

@implementation BookmarksViewController

@synthesize delegate;

@synthesize doneButton;
@synthesize editButton;
@synthesize editDoneButton;
@synthesize flexibleSpaceBarButtonItem;
@synthesize createNewFolderButton;
@synthesize fetchedResultsController;
@synthesize selectedBookmarkFolder;

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Initialization code
        
        self.tableView.allowsSelectionDuringEditing = YES;
    }
    return self;
}

- (void)doneButtonPressed {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(bookmarksViewControllerDoneButtonPressed)]) {
            [delegate bookmarksViewControllerDoneButtonPressed];
        }
    }
}

- (void)editButtonPressed {
    [self.navigationItem safelySetRightBarButtonItemAnimated:nil];
    [self.tableView setEditing:YES animated:YES];
    [self setToolbarItems:[NSArray arrayWithObjects:editDoneButton, flexibleSpaceBarButtonItem, createNewFolderButton, nil] animated:YES];
}

- (void)editDoneButtonPressed {
    // Save the bookmark order (in case it has been changed).
    [[DataManager sharedDataManager]saveContext];
    
    [self.navigationItem safelySetRightBarButtonItemAnimated:doneButton];
    [self.tableView setEditing:NO animated:YES];
    [self setToolbarItems:[NSArray arrayWithObjects:editButton, flexibleSpaceBarButtonItem, nil] animated:YES];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationItem safelySetRightBarButtonItemAnimated:nil];
    [self setToolbarItems:[NSArray arrayWithObjects:editDoneButton, flexibleSpaceBarButtonItem, nil] animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationItem safelySetRightBarButtonItemAnimated:doneButton];
    [self setToolbarItems:[NSArray arrayWithObjects:editButton, flexibleSpaceBarButtonItem, nil] animated:YES];
}

- (void)createNewFolderButtonPressed {
    selectedBookmarkItem = nil;
    
    EditBookmarkFolderViewController *editBookmarkFolderViewController = [[EditBookmarkFolderViewController alloc]initWithStyle:UITableViewStyleGrouped];
    editBookmarkFolderViewController.title = @"New Folder";
    editBookmarkFolderViewController.delegate = self;
    editBookmarkFolderViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editBookmarkFolderViewController animated:YES];
}

- (BookmarkFolder *)editBookmarkFolderViewControllerBookmarkFolder {
    return selectedBookmarkItem.bookmarkFolderRef;
}

- (BookmarkFolder *)editBookmarkFolderViewControllerParentBookmarkFolder {
    return [delegate bookmarksViewControllerParentBookmarkFolder];
}

- (void)editBookmarkFolderViewControllerDidChooseBookmarkFolderName:(NSString *)folderName parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder {
    if (selectedBookmarkItem) {
        DataManager *dataManager = [DataManager sharedDataManager];
        
        selectedBookmarkItem.bookmarkFolderRef.name = folderName;
        
        // If this isn't checked, the index will be unnecessarily incremented.
        if (((parentBookmarkFolder) || (selectedBookmarkItem.parentBookmarkFolderRef)) && (![parentBookmarkFolder isEqual:selectedBookmarkItem.parentBookmarkFolderRef])) {
            NSInteger index = 0;
            
            NSArray *contentItems = [dataManager bookmarkItemsWithParentBookmarkFolder:parentBookmarkFolder];
            if ([contentItems count] > 0) {
                index = ([[[contentItems lastObject]index]integerValue] + 1);
            }
            
            selectedBookmarkItem.index = [NSNumber numberWithInteger:index];
            selectedBookmarkItem.parentBookmarkFolderRef = parentBookmarkFolder;
            [parentBookmarkFolder addContentBookmarkItemRefsObject:selectedBookmarkItem];
        }
        
        // The bookmark item must be refreshed to reflect changes in the table view because it itself isn't modified; only its references are.
        [[dataManager managedObjectContext]refreshObject:selectedBookmarkItem mergeChanges:YES];
        
        [dataManager saveContext];
    }
    else {
        [[DataManager sharedDataManager]createBookmarkFolderWithName:folderName parentBookmarkFolder:parentBookmarkFolder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    editDoneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editDoneButtonPressed)];
    flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    createNewFolderButton = [[UIBarButtonItem alloc]initWithTitle:@"New Folder" style:UIBarButtonItemStyleBordered target:self action:@selector(createNewFolderButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.toolbarItems = [NSArray arrayWithObjects:editButton, flexibleSpaceBarButtonItem, nil];
    
    if ([SkinManager iOS6Skin]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else if ([SkinManager iOS7Skin]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.tableView.editing) {
        // Save the bookmark order (in case it has been changed).
        [[DataManager sharedDataManager]saveContext];
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    /*
    if (![delegate bookmarksViewControllerParentBookmarkFolder]) {
        return 2;
    }
    return 1;
    */
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (section == 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController]sections]objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    StandardCell *cell = (StandardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[StandardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.section == 0);
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        BookmarkItem *bookmarkItem = [[self fetchedResultsController]objectAtIndexPath:indexPath];
        [[DataManager sharedDataManager]deleteBookmarkItem:bookmarkItem];
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
                BookmarkItem *bookmarkItem = [fetchedObjects objectAtIndex:index];
                bookmarkItem.index = [NSNumber numberWithInteger:(index - 1)];
			}
            
            BookmarkItem *movedBookmarkItem = [fetchedObjects objectAtIndex:fromIndexPath.row];
            movedBookmarkItem.index = [NSNumber numberWithInteger:toIndexPath.row];
		}
		else {
            BookmarkItem *movedBookmarkItem = [fetchedObjects objectAtIndex:fromIndexPath.row];
            movedBookmarkItem.index = [NSNumber numberWithInteger:toIndexPath.row];
            
			for (int i = toIndexPath.row; i < fromIndexPath.row; i++) {
				BookmarkItem *bookmarkItem = [fetchedObjects objectAtIndex:i];
				bookmarkItem.index = [NSNumber numberWithInteger:(i + 1)];
			}
		}
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section > 0) {
        return [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:0] - 1) inSection:0];
    }
    return proposedDestinationIndexPath;
}

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
     [detailViewController release];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        BookmarkItem *bookmarkItem = [[self fetchedResultsController]objectAtIndexPath:indexPath];
        
        if (self.tableView.editing) {
            selectedBookmarkItem = bookmarkItem;
            
            if ([bookmarkItem.bookmark boolValue]) {
                EditBookmarkViewController *editBookmarkViewController = [[EditBookmarkViewController alloc]initWithStyle:UITableViewStyleGrouped];
                editBookmarkViewController.title = @"Edit Bookmark";
                editBookmarkViewController.delegate = self;
                editBookmarkViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:editBookmarkViewController animated:YES];
            }
            else {
                EditBookmarkFolderViewController *editBookmarkFolderViewController = [[EditBookmarkFolderViewController alloc]initWithStyle:UITableViewStyleGrouped];
                editBookmarkFolderViewController.title = @"Edit Folder";
                editBookmarkFolderViewController.delegate = self;
                editBookmarkFolderViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:editBookmarkFolderViewController animated:YES];
            }
        }
        else {
            if ([bookmarkItem.bookmark boolValue]) {
                if (delegate) {
                    if ([delegate respondsToSelector:@selector(bookmarksViewControllerDidSelectBookmarkForURL:)]) {
                        [delegate bookmarksViewControllerDidSelectBookmarkForURL:[NSURL URLWithString:bookmarkItem.bookmarkRef.url]];
                    }
                }
            }
            else {
                selectedBookmarkItem = bookmarkItem;
                
                BookmarksViewController *bookmarksViewController = [[BookmarksViewController alloc]init];
                bookmarksViewController.title = bookmarkItem.bookmarkFolderRef.name;
                bookmarksViewController.delegate = self;
                [self.navigationController pushViewController:bookmarksViewController animated:YES];
            }
        }
    }
    else {
        if (delegate) {
            if ([delegate respondsToSelector:@selector(bookmarksViewControllerDidSelectBookmarkForURL:)]) {
                [delegate bookmarksViewControllerDidSelectBookmarkForURL:[NSURL URLWithString:kHelpURLStr]];
            }
        }
    }
}

- (kEditBookmarkViewControllerMode)editBookmarkViewControllerMode {
    return kEditBookmarkViewControllerModeEditBookmark;
}

- (NSString *)editBookmarkViewControllerBookmarkName {
    return selectedBookmarkItem.bookmarkRef.name;
}

- (NSString *)editBookmarkViewControllerBookmarkURL {
    return selectedBookmarkItem.bookmarkRef.url;
}

- (BookmarkFolder *)editBookmarkViewControllerParentBookmarkFolder {
    return selectedBookmarkItem.parentBookmarkFolderRef;
}

- (void)editBookmarkViewControllerDidChooseBookmarkName:(NSString *)bookmarkName url:(NSString *)url parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder {
    if (selectedBookmarkItem) {
        DataManager *dataManager = [DataManager sharedDataManager];
        
        selectedBookmarkItem.bookmarkRef.name = bookmarkName;
        selectedBookmarkItem.bookmarkRef.url = url;
        
        // If this isn't checked, the index will be unnecessarily incremented.
        if (((parentBookmarkFolder) || (selectedBookmarkItem.parentBookmarkFolderRef)) && (![parentBookmarkFolder isEqual:selectedBookmarkItem.parentBookmarkFolderRef])) {
            NSInteger index = 0;
            
            NSArray *contentItems = [dataManager bookmarkItemsWithParentBookmarkFolder:parentBookmarkFolder];
            if ([contentItems count] > 0) {
                index = ([[[contentItems lastObject]index]integerValue] + 1);
            }
            
            selectedBookmarkItem.index = [NSNumber numberWithInteger:index];
            selectedBookmarkItem.parentBookmarkFolderRef = parentBookmarkFolder;
            [parentBookmarkFolder addContentBookmarkItemRefsObject:selectedBookmarkItem];
        }
        
        // The bookmark item must be refreshed to reflect changes in the table view because it itself isn't modified; only its references are.
        [[dataManager managedObjectContext]refreshObject:selectedBookmarkItem mergeChanges:YES];
        
        [dataManager saveContext];
    }
    else {
        [[DataManager sharedDataManager]createBookmarkWithName:bookmarkName url:url parentBookmarkFolder:parentBookmarkFolder];
    }
}

- (BookmarkFolder *)bookmarksViewControllerParentBookmarkFolder {
    return selectedBookmarkItem.bookmarkFolderRef;
}

- (void)bookmarksViewControllerDoneButtonPressed {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(bookmarksViewControllerDoneButtonPressed)]) {
            [delegate bookmarksViewControllerDoneButtonPressed];
        }
    }
}

- (void)bookmarksViewControllerDidSelectBookmarkForURL:(NSURL *)url {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(bookmarksViewControllerDidSelectBookmarkForURL:)]) {
            [delegate bookmarksViewControllerDidSelectBookmarkForURL:url];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// iOS 6 Rotation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookmarkItem" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *indexSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"index" ascending:YES];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:indexSortDescriptor]];
        
        BookmarkFolder *parentBookmarkFolder = [delegate bookmarksViewControllerParentBookmarkFolder];
        if (parentBookmarkFolder) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentBookmarkFolderRef == %@", parentBookmarkFolder]];
        }
        else {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentBookmarkFolderRef == nil"]];
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
        {
            if (!self.tableView.editing) {
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BookmarkItem *bookmarkItem = [[self fetchedResultsController]objectAtIndexPath:indexPath];
        if ([bookmarkItem.bookmark boolValue]) {
            cell.textLabel.text = bookmarkItem.bookmarkRef.name;
            
            if ([SkinManager iOS6Skin]) {
                cell.imageView.image = [UIImage imageNamed:@"Bookmark-Gray"];
            }
            else {
                if ([SkinManager iOS7Skin]) {
                    cell.imageView.image = [UIImage imageNamed:@"Bookmark-7"];
                }
                else {
                    cell.imageView.image = [UIImage imageNamed:@"Bookmark-Blue"];
                }
            }
            
            if ([SkinManager iOS7Skin]) {
                cell.imageView.image = [UIImage imageNamed:@"Bookmark-7"];
            }
            else {
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Bookmark-White"];
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.textLabel.text = bookmarkItem.bookmarkFolderRef.name;
            
            if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
                cell.imageView.image = [UIImage imageNamed:@"Folder-Dark"];
                
                if ([SkinManager iOS6Skin]) {
                    cell.imageView.highlightedImage = [UIImage imageNamed:@"Folder-Dark-Selected"];
                }
                else {
                    cell.imageView.highlightedImage = cell.imageView.image;
                }
            }
            else {
                cell.imageView.image = [UIImage imageNamed:@"Folder"];
                cell.imageView.highlightedImage = cell.imageView.image;
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else {
        cell.textLabel.text = @"Help / Info";
        
        if ([SkinManager iOS6Skin]) {
            cell.imageView.image = [UIImage imageNamed:@"Bookmark-Gray"];
        }
        else {
            if ([SkinManager iOS7Skin]) {
                cell.imageView.image = [UIImage imageNamed:@"Bookmark-7"];
            }
            else {
                cell.imageView.image = [UIImage imageNamed:@"Bookmark-Blue"];
            }
        }
        
        if ([SkinManager iOS7Skin]) {
            cell.imageView.image = [UIImage imageNamed:@"Bookmark-7"];
        }
        else {
            cell.imageView.highlightedImage = [UIImage imageNamed:@"Bookmark-White"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
