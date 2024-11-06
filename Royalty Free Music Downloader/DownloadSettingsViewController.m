//
//  DownloadSettingsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "DownloadSettingsViewController.h"
#import "SimultaneousDownloadsViewController.h"
#import "DownloadAttemptsViewController.h"
#import "SwitchCell.h"
#import "DetailCell.h"

static NSString *kAutomaticallyRenameDownloadsKey   = @"Automatically Rename Downloads";
static NSString *kIncludeArtistInFileNameKey        = @"Include Artist In File Name";
static NSString *kDownloadNotificationsKey          = @"Download Notifications";
static NSString *kPreventSleepModeKey               = @"Prevent Sleep Mode";
static NSString *kSimultaneousDownloadsKey          = @"Simultaneous Downloads";
static NSString *kDownloadAttemptsKey               = @"Download Attempts";

@interface DownloadSettingsViewController ()

@property (nonatomic) BOOL automaticallyRenameDownloads;

@end

@implementation DownloadSettingsViewController

// Private
@synthesize automaticallyRenameDownloads;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    automaticallyRenameDownloads = [[NSUserDefaults standardUserDefaults]boolForKey:kAutomaticallyRenameDownloadsKey];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return @"Enable this feature to prevent your device from sleeping while downloading files.";
    }
    else if (section == 3) {
        return @"This allows you to regulate the number of files downloaded at the same time.";
    }
    else if (section == 4) {
        return @"If a download fails, the app will attempt to restart it this many times.";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (section == 0) {
        if (automaticallyRenameDownloads) {
            return 2;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 3) {
        static NSString *CellIdentifier = @"Cell 1";
        
        SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Automatically Rename Downloads";
                cell.textLabel.numberOfLines = 2;
                cell.cellSwitch.on = automaticallyRenameDownloads;
                cell.cellSwitch.tag = 0;
            }
            else {
                cell.textLabel.text = @"Include Artist In File Name";
                cell.textLabel.numberOfLines = 2;
                cell.cellSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:kIncludeArtistInFileNameKey];
                cell.cellSwitch.tag = 1;
            }
        }
        else if (indexPath.section == 1) {
            cell.textLabel.text = @"Download Notifications";
            cell.cellSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:kDownloadNotificationsKey];
            cell.cellSwitch.tag = 2;
        }
        else {
            cell.textLabel.text = @"Prevent Sleep Mode";
            cell.cellSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:kPreventSleepModeKey];
            cell.cellSwitch.tag = 3;
        }
        
        [cell.cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 2";
        
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (indexPath.section == 3) {
            cell.textLabel.text = @"Simultaneous Downloads";
            
            NSInteger simultaneousDownloads = [[NSUserDefaults standardUserDefaults]integerForKey:kSimultaneousDownloadsKey];
            if ((simultaneousDownloads > 0) && (simultaneousDownloads <= 50)) {
                cell.detailLabel.text = [NSString stringWithFormat:@"%i", simultaneousDownloads];
            }
            else {
                cell.detailLabel.text = @"5";
            }
        }
        else {
            cell.textLabel.text = @"Download Attempts";
            
            NSInteger downloadAttempts = [[NSUserDefaults standardUserDefaults]integerForKey:kDownloadAttemptsKey];
            if ((downloadAttempts > 0) && (downloadAttempts <= 50)) {
                cell.detailLabel.text = [NSString stringWithFormat:@"%i", downloadAttempts];
            }
            else {
                cell.detailLabel.text = @"5";
            }
        }
        
        return cell;
    }
}

- (void)switchValueChanged:(id)sender {
    UISwitch *theSwitch = sender;
    NSString *key = nil;
    
    switch (theSwitch.tag) {
        case 0:
            key = kAutomaticallyRenameDownloadsKey;
            break;
        case 1:
            key = kIncludeArtistInFileNameKey;
            break;
        case 2:
            key = kDownloadNotificationsKey;
            break;
        case 3:
            key = kPreventSleepModeKey;
            break;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:theSwitch.on forKey:key];
    [defaults synchronize];
    
    if (theSwitch.tag == 0) {
        automaticallyRenameDownloads = theSwitch.on;
        [self.tableView reloadData];
    }
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
    
    if (indexPath.section == 3) {
        SimultaneousDownloadsViewController *simultaneousDownloadsViewController = [[SimultaneousDownloadsViewController alloc]init];
        simultaneousDownloadsViewController.title = @"Simultaneous Downloads";
        [self.navigationController pushViewController:simultaneousDownloadsViewController animated:YES];
    }
    else if (indexPath.section == 4) {
        DownloadAttemptsViewController *downloadAttemptsViewController = [[DownloadAttemptsViewController alloc]init];
        downloadAttemptsViewController.title = @"Download Attempts";
        [self.navigationController pushViewController:downloadAttemptsViewController animated:YES];
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
