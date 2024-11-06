//
//  MoveItemsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "MoveItemsViewController.h"
#import "AppDelegate.h"
#import "DirectoryCell.h"
#import "DataManager.h"
#import "Player.h"
#import "MBProgressHUD.h"
#import "SkinManager.h"
#import "MoveDirectory.h"
#import "Directory.h"
#import "Directory+Path.h"
#import "Archive.h"
#import "Archive+Path.h"
#import "File.h"
#import "File+Extensions.h"
#import "FilePaths.h"

@interface MoveItemsViewController ()

@property (nonatomic, strong) MoveDirectory *selectedDirectory;

- (void)cancelButtonPressed;
- (void)doneButtonPressed;
- (void)_moveItemsWithHUD:(MBProgressHUD *)hud;
- (void)addItemsToArrayWithParentDirectory:(Directory *)parentDirectory tier:(NSInteger)tier;
- (NSArray *)directoriesWithParentDirectory:(Directory *)parentDirectory;

@end

@implementation MoveItemsViewController

// Public
@synthesize delegate;
@synthesize directories;
@synthesize items;

// Private
@synthesize selectedDirectory;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        directories = [[NSMutableArray alloc]init];
        items = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)cancelButtonPressed {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(moveItemsViewControllerDidCancel)]) {
            [delegate moveItemsViewControllerDidCancel];
        }
    }
}

- (void)doneButtonPressed {
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:window];
    hud.dimBackground = YES;
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_MESSAGE", @"");
    hud.detailsLabelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_SUBTITLE", @"");
    [window addSubview:hud];
    
    [hud showWhileExecuting:@selector(_moveItemsWithHUD:) onTarget:self withObject:hud animated:YES];
}

- (void)_moveItemsWithHUD:(MBProgressHUD *)hud {
    // Because this is run in the background, all item properties must be updated on the main thread. For consistency, dispatch_sync() is used instead of dispatch_async() where applicable.
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    if (selectedDirectory) {
        if (selectedDirectory.enabled) {
            NSString *selectedDirectoryPath = nil;
            if (selectedDirectory.directoryRef) {
                selectedDirectoryPath = [selectedDirectory.directoryRef path];
            }
            else {
                selectedDirectoryPath = kMusicDirectoryPathStr;
            }
            
            NSInteger itemCount = [items count];
            for (int i = 0; i < itemCount; i++) {
                id item = [items objectAtIndex:i];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([item isKindOfClass:[Directory class]]) {
                    Directory *directory = item;
                    
                    NSString *path = [directory path];
                    NSString *directoryName = [path lastPathComponent];
                    
                    NSString *destinationPath = [selectedDirectoryPath stringByAppendingPathComponent:directoryName];
                    
                    [fileManager moveItemAtPath:path toPath:destinationPath error:nil];
                    
                    dispatch_sync(mainQueue, ^{
                        // These must be updated before the URLs are updated using the function below, as it uses the following properties for reference.
                        directory.parentDirectoryRef = selectedDirectory.directoryRef;
                        [selectedDirectory.directoryRef addContentDirectoriesObject:directory];
                    });
                }
                else if ([item isKindOfClass:[Archive class]]) {
                    Archive *archive = item;
                    
                    NSString *path = [archive path];
                    NSString *fileName = [path lastPathComponent];
                    
                    NSString *destinationPath = [selectedDirectoryPath stringByAppendingPathComponent:fileName];
                    
                    [fileManager moveItemAtPath:path toPath:destinationPath error:nil];
                    
                    dispatch_sync(mainQueue, ^{
                        archive.parentDirectoryRef = selectedDirectory.directoryRef;
                        [selectedDirectory.directoryRef addContentArchivesObject:archive];
                        
                        archive.fileName = fileName;
                    });
                }
                else {
                    File *file = item;
                    
                    NSString *path = [file filePath];
                    NSString *fileName = [path lastPathComponent];
                    
                    NSString *destinationPath = [selectedDirectoryPath stringByAppendingPathComponent:fileName];
                    
                    [fileManager moveItemAtPath:path toPath:destinationPath error:nil];
                    
                    dispatch_sync(mainQueue, ^{
                        NSURL *previousURL = [file fileURL];
                        
                        file.parentDirectoryRef = selectedDirectory.directoryRef;
                        [selectedDirectory.directoryRef addContentFilesObject:file];
                        
                        file.fileName = fileName;
                        
                        [[Player sharedPlayer]updateURLForFileWithNewURL:[file fileURL] previousURL:previousURL];
                    });
                }
                
                dispatch_async(mainQueue, ^{
                    hud.progress = ((CGFloat)(i + 1) / (CGFloat)itemCount);
                });
            }
            
            dispatch_async(mainQueue, ^{
                hud.mode = MBProgressHUDModeIndeterminate;
            });
            
            dispatch_sync(mainQueue, ^{
                [[DataManager sharedDataManager]saveContext];
            });
        }
    }
    
    dispatch_sync(mainQueue, ^{
        if (delegate) {
            if ([delegate respondsToSelector:@selector(moveItemsViewControllerDidFinishMovingItems)]) {
                [delegate moveItemsViewControllerDidFinishMovingItems];
            }
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    MoveDirectory *downloadsDirectory = [[MoveDirectory alloc]init];
    downloadsDirectory.tier = 0;
    downloadsDirectory.enabled = YES;
    [directories addObject:downloadsDirectory];
    
    NSArray *directoriesArray = [self directoriesWithParentDirectory:nil];
    for (int i = 0; i < [directoriesArray count]; i++) {
        Directory *directory = [directoriesArray objectAtIndex:i];
        [self addItemsToArrayWithParentDirectory:directory tier:1];
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

- (void)addItemsToArrayWithParentDirectory:(Directory *)parentDirectory tier:(NSInteger)tier {
    MoveDirectory *directory = [[MoveDirectory alloc]init];
    directory.directoryRef = parentDirectory;
    directory.tier = tier;
    
    BOOL enabled = YES;
    Directory *currentParentDirectory = parentDirectory;
    while (currentParentDirectory) {
        if ([items containsObject:currentParentDirectory]) {
            enabled = NO;
            break;
        }
        currentParentDirectory = currentParentDirectory.parentDirectoryRef;
    }
    directory.enabled = enabled;
    
    [directories addObject:directory];
    
    NSArray *directoriesArray = [self directoriesWithParentDirectory:parentDirectory];
    for (int i = 0; i < [directoriesArray count]; i++) {
        Directory *directory = [directoriesArray objectAtIndex:i];
        [self addItemsToArrayWithParentDirectory:directory tier:(tier + 1)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [directories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    DirectoryCell *cell = (DirectoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DirectoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    MoveDirectory *directory = [directories objectAtIndex:indexPath.row];
    
    cell.tier = directory.tier;
    
    if (directory.tier > 0) {
        cell.textLabel.text = directory.directoryRef.name;
        
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
        cell.textLabel.text = @"Downloads";
        
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
    
    if (directory.enabled) {
        cell.textLabel.alpha = 1;
        cell.imageView.alpha = 1;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else {
        cell.textLabel.alpha = 0.5;
        cell.imageView.alpha = 0.5;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([directory isEqual:selectedDirectory]) {
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
    
    MoveDirectory *proposedSelectedDirectory = [directories objectAtIndex:indexPath.row];
    if (proposedSelectedDirectory.enabled) {
        if (selectedDirectory) {
            NSIndexPath *previousSelectedDirectoryIndexPath = [NSIndexPath indexPathForRow:[directories indexOfObject:selectedDirectory] inSection:0];
            [[tableView cellForRowAtIndexPath:previousSelectedDirectoryIndexPath]setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        selectedDirectory = proposedSelectedDirectory;
        NSIndexPath *currentSelectedDirectoryIndexPath = [NSIndexPath indexPathForRow:[directories indexOfObject:selectedDirectory] inSection:0];
        [[tableView cellForRowAtIndexPath:currentSelectedDirectoryIndexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

#pragma mark -
#pragma mark Fetched results controller

- (NSArray *)directoriesWithParentDirectory:(Directory *)parentDirectory {
    NSManagedObjectContext *currentManagedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Directory" inManagedObjectContext:currentManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = nil;
    if (parentDirectory) {
        predicate = [NSPredicate predicateWithFormat:@"parentDirectoryRef == %@", parentDirectory];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"parentDirectoryRef == nil"];
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
