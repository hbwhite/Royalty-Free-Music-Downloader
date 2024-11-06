//
//  DownloadsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "DownloadsViewController.h"
#import "VisibilityViewController.h"
#import "AppDelegate.h"
#import "TagEditorNavigationController.h"
#import "SettingsViewController.h"
#import "FilesEditBar.h"
#import "DataManager.h"
#import "File.h"
#import "Directory.h"
#import "Downloader.h"
#import "Download.h"
#import "DownloadRequest.h"
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
#import "NSManagedObject+SectionTitles.h"
#import "UINavigationItem+SafeAnimation.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "NSArray+Equivalence.h"

#include <math.h>

@interface DownloadsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)visibilityViewControllerModeDidChange;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DownloadsViewController

// Private
@synthesize fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(visibilityViewControllerModeDidChange) name:kVisibilityViewControllerModeDidChangeNotification object:nil];
    
    self.tableView.rowHeight = 55;
}

- (void)visibilityViewControllerModeDidChange {
    if ((viewIsVisible) && (!searching)) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController]sections]objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    DownloadCell *cell = (DownloadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DownloadCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Download *download = [[self fetchedResultsController]objectAtIndexPath:indexPath];
        [[DataManager sharedDataManager]deleteDownload:download];
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
}

#pragma mark -
#pragma mark - Fetched results controllers

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSArray *sortDescriptors = nil;
        
        NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:YES];
        sortDescriptors = [NSArray arrayWithObjects:creationDateSortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:/* @"Download_Cache" */ nil];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
        
        // @try {
            NSError *error = nil;
            if (![fetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        // }
        /*
        @catch (NSException *exception) {
            [NSFetchedResultsController deleteCacheWithName:@"Download_Cache"];
            
            NSError *error = nil;
            if (![fetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        */
    }
    
    return fetchedResultsController;
}

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!searching) {
        [self.tableView reloadData];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *downloadCell = (DownloadCell *)cell;
    
    // This prevents download requests from conflicting with each other if they are using a cell that has been re-used.
    DownloadRequest *downloadRequest = downloadCell.downloadRequest;
    if (downloadRequest) {
        downloadRequest.downloadRequestProgressDelegate = nil;
        downloadRequest.downloadRequestDataDelegate = nil;
    }
    
    Download *download = [[self fetchedResultsController]objectAtIndexPath:indexPath];
    DownloadRequest *request = [[Downloader sharedDownloader]requestForDownload:download];
    
    // Decode the plus signs used in place of spaces on many websites (such as last.fm).
    downloadCell.titleLabel.text = [download.name stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    
    downloadCell.downloadRequest = request;
    
    request.downloadRequestProgressDelegate = downloadCell.downloadProgressSlider;
    request.downloadRequestDataDelegate = downloadCell.detailLabel;
    
    NSInteger downloadState = [download.state integerValue];
    
    if (downloadState == kDownloadStateDownloading) {
        if (request.totalBytesRead > 0) {
            // The app will crash if the float value of the progress is NaN and it tries to set the value of the download progress slider accordingly.
            float progress = request.calculatedProgress;
            if (isnan(progress)) {
                downloadCell.downloadProgressSlider.value = 0;
            }
            else {
                downloadCell.downloadProgressSlider.value = progress;
            }
        }
        else {
            downloadCell.downloadProgressSlider.value = 0;
        }
    }
    else if (downloadState == kDownloadStateProcessing) {
        downloadCell.downloadProgressSlider.value = 1;
    }
    else {
        downloadCell.downloadProgressSlider.value = 0;
    }
    
    switch (downloadState) {
        case kDownloadStateWaiting:
            downloadCell.detailLabel.text = @"Waiting...";
            
            // This is functionally equivalent.
            [downloadCell setPaused];
            break;
        case kDownloadStateDownloading:
            downloadCell.detailLabel.text = [request detailLabelText];
            [downloadCell setDownloading];
            break;
        case kDownloadStatePaused:
            downloadCell.detailLabel.text = @"Tap to resume download";
            [downloadCell setPaused];
            break;
        case kDownloadStateFailed:
            downloadCell.detailLabel.text = @"Failed";
            
            // This is functionally equivalent.
            [downloadCell setPaused];
            break;
        case kDownloadStateProcessing:
            downloadCell.detailLabel.text = @"Processing...";
            [downloadCell setProcessing];
            break;
    }
    
    downloadCell.download = download;
}

- (void)dealloc {
    fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
