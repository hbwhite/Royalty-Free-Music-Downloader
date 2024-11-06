//
//  MoveBookmarkItemViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "MoveBookmarkItemViewController.h"
#import "AppDelegate.h"
#import "DirectoryCell.h"
#import "DataManager.h"
#import "SkinManager.h"
#import "MoveBookmarkFolder.h"
#import "BookmarkFolder.h"
#import "BookmarkItem.h"

@interface MoveBookmarkItemViewController ()

@property (nonatomic, strong) NSMutableArray *bookmarkFolders;
@property (nonatomic, strong) MoveBookmarkFolder *selectedBookmarkFolder;

- (void)addItemsToArrayWithParentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder tier:(NSInteger)tier;
- (NSArray *)bookmarkFoldersWithParentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder;

@end

@implementation MoveBookmarkItemViewController

// Public
@synthesize delegate;

// Private
@synthesize bookmarkFolders;
@synthesize selectedBookmarkFolder;

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    bookmarkFolders = [[NSMutableArray alloc]init];
    
    MoveBookmarkFolder *bookmarksFolder = [[MoveBookmarkFolder alloc]init];
    bookmarksFolder.tier = 0;
    [bookmarkFolders addObject:bookmarksFolder];
    
    NSArray *bookmarkFoldersArray = [self bookmarkFoldersWithParentBookmarkFolder:nil];
    for (int i = 0; i < [bookmarkFoldersArray count]; i++) {
        BookmarkFolder *bookmarkFolder = [bookmarkFoldersArray objectAtIndex:i];
        [self addItemsToArrayWithParentBookmarkFolder:bookmarkFolder tier:1];
    }
    
    BookmarkFolder *parentBookmarkFolder = [delegate moveBookmarkItemViewControllerParentBookmarkFolder];
    if (parentBookmarkFolder) {
        // Skip the bookmarks folder.
        for (int i = 1; i < [bookmarkFolders count]; i++) {
            MoveBookmarkFolder *bookmarkFolder = [bookmarkFolders objectAtIndex:i];
            if ([bookmarkFolder.bookmarkFolderRef isEqual:parentBookmarkFolder]) {
                selectedBookmarkFolder = bookmarkFolder;
                break;
            }
        }
    }
    else {
        selectedBookmarkFolder = bookmarksFolder;
    }
    
    [self.tableView reloadData];
    
    if ([SkinManager iOS6Skin]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else if ([SkinManager iOS7Skin]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)addItemsToArrayWithParentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder tier:(NSInteger)tier {
    MoveBookmarkFolder *bookmarkFolder = [[MoveBookmarkFolder alloc]init];
    bookmarkFolder.bookmarkFolderRef = parentBookmarkFolder;
    bookmarkFolder.tier = tier;
    
    BOOL enabled = YES;
    
    BookmarkFolder *delegateBookmarkFolder = nil;
    if (delegate) {
        if ([delegate respondsToSelector:@selector(moveBookmarkItemViewControllerBookmarkFolder)]) {
            delegateBookmarkFolder = [delegate moveBookmarkItemViewControllerBookmarkFolder];
        }
    }
    
    if (delegateBookmarkFolder) {
        BookmarkFolder *currentParentBookmarkFolder = parentBookmarkFolder;
        while (currentParentBookmarkFolder) {
            if ([delegateBookmarkFolder isEqual:currentParentBookmarkFolder]) {
                enabled = NO;
                break;
            }
            currentParentBookmarkFolder = currentParentBookmarkFolder.bookmarkItemRef.parentBookmarkFolderRef;
        }
    }
    
    if (enabled) {
        [bookmarkFolders addObject:bookmarkFolder];
    }
    
    NSArray *bookmarkFoldersArray = [self bookmarkFoldersWithParentBookmarkFolder:parentBookmarkFolder];
    for (int i = 0; i < [bookmarkFoldersArray count]; i++) {
        BookmarkFolder *bookmarkFolder = [bookmarkFoldersArray objectAtIndex:i];
        [self addItemsToArrayWithParentBookmarkFolder:bookmarkFolder tier:(tier + 1)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [bookmarkFolders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    DirectoryCell *cell = (DirectoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DirectoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    MoveBookmarkFolder *bookmarkFolder = [bookmarkFolders objectAtIndex:indexPath.row];
    
    cell.tier = bookmarkFolder.tier;
    
    if (bookmarkFolder.tier > 0) {
        cell.textLabel.text = bookmarkFolder.bookmarkFolderRef.name;
        
        if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
            cell.imageView.image = [UIImage imageNamed:@"Folder-Dark-Small"];
            
            if ([SkinManager iOS6Skin]) {
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Folder-Dark-Small-Selected"];
            }
            else {
                cell.imageView.highlightedImage = cell.imageView.image;
            }
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"Folder-Small"];
            cell.imageView.highlightedImage = cell.imageView.image;
        }
    }
    else {
        cell.textLabel.text = @"Bookmarks";
        
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
    }
    
    if ([bookmarkFolder isEqual:selectedBookmarkFolder]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
     [detailViewController release];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MoveBookmarkFolder *proposedSelectedBookmarkFolder = [bookmarkFolders objectAtIndex:indexPath.row];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(moveBookmarkItemViewControllerDidSelectBookmarkFolder:)]) {
            [delegate moveBookmarkItemViewControllerDidSelectBookmarkFolder:proposedSelectedBookmarkFolder.bookmarkFolderRef];
        }
    }
    
    if (selectedBookmarkFolder) {
        NSIndexPath *previousSelectedDirectoryIndexPath = [NSIndexPath indexPathForRow:[bookmarkFolders indexOfObject:selectedBookmarkFolder] inSection:0];
        [[tableView cellForRowAtIndexPath:previousSelectedDirectoryIndexPath]setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    selectedBookmarkFolder = proposedSelectedBookmarkFolder;
    NSIndexPath *currentSelectedDirectoryIndexPath = [NSIndexPath indexPathForRow:[bookmarkFolders indexOfObject:selectedBookmarkFolder] inSection:0];
    [[tableView cellForRowAtIndexPath:currentSelectedDirectoryIndexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSArray *)bookmarkFoldersWithParentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder {
    NSManagedObjectContext *currentManagedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookmarkFolder" inManagedObjectContext:currentManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *indexSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"bookmarkItemRef.index" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:indexSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = nil;
    if (parentBookmarkFolder) {
        predicate = [NSPredicate predicateWithFormat:@"bookmarkItemRef.parentBookmarkFolderRef == %@", parentBookmarkFolder];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"bookmarkItemRef.parentBookmarkFolderRef == nil"];
    }
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:currentManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController.fetchedObjects;
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
