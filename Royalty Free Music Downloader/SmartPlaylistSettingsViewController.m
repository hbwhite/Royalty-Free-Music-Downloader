//
//  SmartPlaylistSettingsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SmartPlaylistSettingsViewController.h"
#import "SwitchCell.h"

static NSString *kTop25MostPlayedSmartPlaylistEnabledKey    = @"Top 25 Most Played Smart Playlist Enabled";
static NSString *kMyTopRatedSmartPlaylistEnabledKey         = @"My Top Rated Smart Playlist Enabled";
static NSString *kRecentlyPlayedSmartPlaylistEnabledKey     = @"Recently Played Smart Playlist Enabled";
static NSString *kRecentlyAddedSmartPlaylistEnabledKey      = @"Recently Added Smart Playlist Enabled";

@implementation SmartPlaylistSettingsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    // The user can disable smart playlists from the PlaylistsViewController, so this is necessary to ensure that their respective switches are in the correct positions when the settings view is presented (in case is was already open when those playlists were disabled).
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    NSString *key = nil;
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Top 25 Most Played";
            cell.imageView.image = nil;
            key = kTop25MostPlayedSmartPlaylistEnabledKey;
            cell.cellSwitch.tag = 0;
            break;
        case 1:
            cell.textLabel.text = @"My Top Rated";
            cell.imageView.image = nil;
            key = kMyTopRatedSmartPlaylistEnabledKey;
            cell.cellSwitch.tag = 1;
            break;
        case 2:
            cell.textLabel.text = @"Recently Played";
            cell.imageView.image = nil;
            key = kRecentlyPlayedSmartPlaylistEnabledKey;
            cell.cellSwitch.tag = 2;
            break;
        case 3:
            cell.textLabel.text = @"Recently Added";
            cell.imageView.image = nil;
            key = kRecentlyAddedSmartPlaylistEnabledKey;
            cell.cellSwitch.tag = 3;
            break;
    }
    
    cell.cellSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:key];
    [cell.cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (void)switchValueChanged:(id)sender {
    UISwitch *theSwitch = sender;
    NSString *key = nil;
    
    switch (theSwitch.tag) {
        case 0:
            key = kTop25MostPlayedSmartPlaylistEnabledKey;
            break;
        case 1:
            key = kMyTopRatedSmartPlaylistEnabledKey;
            break;
        case 2:
            key = kRecentlyPlayedSmartPlaylistEnabledKey;
            break;
        case 3:
            key = kRecentlyAddedSmartPlaylistEnabledKey;
            break;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:theSwitch.on forKey:key];
    [defaults synchronize];
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
