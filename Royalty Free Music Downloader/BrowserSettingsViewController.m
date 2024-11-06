//
//  BrowserSettingsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "BrowserSettingsViewController.h"
#import "BrowserViewController.h"
#import "HomepageViewController.h"
#import "UserAgentViewController.h"
#import "SwitchCell.h"
#import "DetailCell.h"
#import "StandardGroupedCell.h"

static NSString *kBlockAdsKey       = @"Block Ads";
static NSString *kHomepageKey       = @"Homepage";
static NSString *kUserAgentIndexKey = @"User Agent Index";

@interface BrowserSettingsViewController ()

- (void)switchValueChanged:(id)sender;

@end

@implementation BrowserSettingsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"Cell 1";
            
            SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell configure];
            
            // Configure the cell...
            
            cell.textLabel.text = @"Block Ads";
            cell.cellSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:kBlockAdsKey];
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
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Homepage";
                cell.detailLabel.text = [defaults objectForKey:kHomepageKey];
            }
            else {
                cell.textLabel.text = @"User Agent";
                
                NSInteger userAgentIndex = [defaults integerForKey:kUserAgentIndexKey];
                if (userAgentIndex == 0) {
                    cell.detailLabel.text = @"Default";
                }
                else if (userAgentIndex == 1) {
                    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        cell.detailLabel.text = @"iPad";
                    }
                    else {
                        cell.detailLabel.text = @"iPhone";
                    }
                }
                else if (userAgentIndex == 2) {
                    cell.detailLabel.text = @"Firefox";
                }
                else {
                    cell.detailLabel.text = @"Custom";
                }
            }
            
            return cell;
        }
    }
    else {
        static NSString *CellIdentifier = @"Cell 3";
        
        StandardGroupedCell *cell = (StandardGroupedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[StandardGroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textLabel.text = @"Clear Cookies";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        return cell;
    }
}

- (void)switchValueChanged:(id)sender {
    UISwitch *theSwitch = sender;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:theSwitch.on forKey:kBlockAdsKey];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kBrowserSettingsDidChangeNotification object:nil];
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
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            HomepageViewController *homepageViewController = [[HomepageViewController alloc]init];
            homepageViewController.title = @"Homepage";
            [self.navigationController pushViewController:homepageViewController animated:YES];
        }
        else if (indexPath.row == 2) {
            UserAgentViewController *userAgentViewController = [[UserAgentViewController alloc]init];
            userAgentViewController.title = @"User Agent";
            [self.navigationController pushViewController:userAgentViewController animated:YES];
        }
    }
    else {
        UIActionSheet *confirmActionSheet = [[UIActionSheet alloc]
                                             initWithTitle:nil
                                             delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                             destructiveButtonTitle:nil
                                             otherButtonTitles:@"Clear Cookies", nil];
        [confirmActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
            [cookieStorage deleteCookie:cookie];
        }
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
