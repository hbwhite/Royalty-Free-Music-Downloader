//
//  PasscodeRequirementDelayViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/11/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import "PasscodeRequirementDelayViewController.h"
#import "StandardGroupedCell.h"

#define kPasscodeRequirementDelayArray							[NSArray arrayWithObjects:@"Immediately", @"After 1 minute", @"After 5 minutes", @"After 15 minutes", @"After 1 hour", @"After 4 hours", nil]

#define IMMEDIATE_PASSCODE_REQUIREMENT_DELAY_INDEX				0
#define ONE_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		1
#define FIVE_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		2
#define FIFTEEN_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX	3
#define ONE_HOUR_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX			4
#define FOUR_HOUR_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		5

static NSString *kPasscodeRequirementDelayIndexKey				= @"Passcode Requirement Delay Index";

@implementation PasscodeRequirementDelayViewController

@synthesize selectedRow;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	selectedRow = [[NSUserDefaults standardUserDefaults]integerForKey:kPasscodeRequirementDelayIndexKey];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	if ([self.navigationController.topViewController isEqual:self]) {
		[self.navigationController popToRootViewControllerAnimated:NO];
	}
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"Shorter times are more secure.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    StandardGroupedCell *cell = (StandardGroupedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[StandardGroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
	
	cell.textLabel.text = [kPasscodeRequirementDelayArray objectAtIndex:indexPath.row];
	if (indexPath.row == selectedRow) {
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
	
	if (indexPath.row != selectedRow) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setInteger:indexPath.row forKey:kPasscodeRequirementDelayIndexKey];
		[defaults synchronize];
        
        [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]]setAccessoryType:UITableViewCellAccessoryNone];
		selectedRow = indexPath.row;
		[[tableView cellForRowAtIndexPath:indexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
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
