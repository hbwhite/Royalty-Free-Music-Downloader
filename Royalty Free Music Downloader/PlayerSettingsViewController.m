//
//  PlayerSettingsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "PlayerSettingsViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "Player.h"
#import "PlayerState.h"
#import "SwitchCell.h"
#import "MBProgressHUD.h"

static NSString *kGroupByAlbumArtistKey                     = @"Group By Album Artist";
static NSString *kCoverFlowEnabledKey                       = @"Cover Flow Enabled";

static NSString *kiPodMusicLibraryKey                       = @"iPod Music Library";

static NSString *kShakeToShuffleKey                         = @"Shake to Shuffle";
static NSString *kSwipeGestureKey                           = @"Swipe Gesture";
static NSString *kSavePlaybackTimeKey                       = @"Save Playback Time";

@implementation PlayerSettingsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"This allows you to import the songs from your iPod music library into this app in order to combine them with your downloaded songs.";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 5;
        default:
            return 0;
    }
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
    if (indexPath.section == 0) {
        cell.textLabel.text = @"iPod Music Library";
        cell.imageView.image = nil;
        key = kiPodMusicLibraryKey;
        cell.cellSwitch.tag = 0;
    }
    else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Group By Album Artist";
                
                // The switches on devices running iOS 4 are larger and will truncate this text if it isn't automatically resized as needed.
                cell.textLabel.minimumFontSize = 12;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                
                cell.imageView.image = nil;
                key = kGroupByAlbumArtistKey;
                cell.cellSwitch.tag = 1;
                break;
            case 1:
                cell.textLabel.text = @"Cover Flow";
                cell.imageView.image = nil;
                key = kCoverFlowEnabledKey;
                cell.cellSwitch.tag = 2;
                break;
            case 2:
                cell.textLabel.text = @"Shake to Shuffle";
                cell.imageView.image = nil;
                key = kShakeToShuffleKey;
                cell.cellSwitch.tag = 3;
                break;
            case 3:
                cell.textLabel.text = @"Swipe Gesture";
                cell.imageView.image = nil;
                key = kSwipeGestureKey;
                cell.cellSwitch.tag = 4;
                break;
            case 4:
                cell.textLabel.text = @"Save Playback Time";
                cell.imageView.image = nil;
                key = kSavePlaybackTimeKey;
                cell.cellSwitch.tag = 5;
                break;
        }
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
            key = kiPodMusicLibraryKey;
            break;
        case 1:
            key = kGroupByAlbumArtistKey;
            break;
        case 2:
            key = kCoverFlowEnabledKey;
            break;
        case 3:
            key = kShakeToShuffleKey;
            break;
        case 4:
            key = kSwipeGestureKey;
            break;
        case 5:
            key = kSavePlaybackTimeKey;
            break;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:theSwitch.on forKey:key];
    [defaults synchronize];
    
    if (theSwitch.tag == 0) {
        DataManager *dataManager = [DataManager sharedDataManager];
        if (theSwitch.on) {
            [dataManager updateLibraryWithUpdateType:kLibraryUpdateTypeiPodMusicLibrary];
        }
        else {
            [dataManager removeiPodMusicLibrarySongs];
        }
    }
    else if (theSwitch.tag == 1) {
        UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:window];
        hud.dimBackground = YES;
        hud.labelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_MESSAGE", @"");
        hud.detailsLabelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_SUBTITLE", @"");
        [window addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kGroupByAlbumArtistPreferenceDidChangeNotification object:nil];
        }];
    }
    else if (theSwitch.tag == 6) {
        if (!theSwitch.on) {
            [[[Player sharedPlayer]playerState]setPlaybackTime:[NSNumber numberWithDouble:0]];
            [[DataManager sharedDataManager]saveContext];
        }
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
