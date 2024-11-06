//
//  PasscodeSettingsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 11/17/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import "PasscodeSettingsViewController.h"
#import "LoginNavigationController.h"
#import "PasscodeRequirementDelayViewController.h"
#import "AppDelegate.h"
#import "DetailCell.h"
#import "SwitchCell.h"
#import "StandardGroupedCell.h"
#import "UIViewController+SafeModal.h"

#define kPasscodeRequirementDelayArray							[NSArray arrayWithObjects:@"Immediately", @"After 1 min.", @"After 5 min.", @"After 15 min.", @"After 1 hour", @"After 4 hours", nil]

#define IMMEDIATE_PASSCODE_REQUIREMENT_DELAY_INDEX				0
#define ONE_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		1
#define FIVE_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		2
#define FIFTEEN_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX	3
#define ONE_HOUR_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX			4
#define FOUR_HOUR_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		5

static NSString *kPasscodeKey									= @"Passcode";
static NSString *kPasscodeRequirementDelayIndexKey				= @"Passcode Requirement Delay Index";
static NSString *kSimplePasscodeKey								= @"Simple Passcode";

@interface PasscodeSettingsViewController ()

@property (readwrite) BOOL disablingPasscode;

@end

@implementation PasscodeSettingsViewController

// Private
@synthesize disablingPasscode;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return @"A simple passcode is a 4 digit number.";
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"Cell 1";
		
		StandardGroupedCell *cell = (StandardGroupedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[StandardGroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
        
        [cell configure];
		
		// Configure the cell...
		
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		BOOL passcodeSet = ([[NSUserDefaults standardUserDefaults]objectForKey:kPasscodeKey] != nil);
		if (indexPath.row == 0) {
			if (passcodeSet) {
				cell.textLabel.text = @"Turn Passcode Off";
			}
			else {
				cell.textLabel.text = @"Turn Passcode On";
			}
		}
		else {
			cell.textLabel.text = @"Change Passcode";
			cell.textLabel.enabled = passcodeSet;
			cell.userInteractionEnabled = passcodeSet;
		}
		
		return cell;
	}
	else if ((indexPath.section == 1) && (indexPath.row == 0)) {
		static NSString *CellIdentifier = @"Cell 2";
		
		DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[DetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
        
        [cell configure];
		
		// Configure the cell...
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL passcodeSet = ([defaults stringForKey:kPasscodeKey] != nil);
		
		cell.textLabel.text = @"Require Passcode";
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		cell.detailLabel.text = [kPasscodeRequirementDelayArray objectAtIndex:[defaults integerForKey:kPasscodeRequirementDelayIndexKey]];
		cell.textLabel.enabled = passcodeSet;
		cell.detailLabel.enabled = passcodeSet;
		cell.userInteractionEnabled = passcodeSet;
		
		return cell;
	}
	else {
		static NSString *CellIdentifier = @"Cell 3";
		
		SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
        
        [cell configure];
		
		// Configure the cell...
		
		cell.textLabel.text = @"Simple Passcode";
        cell.cellSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:kSimplePasscodeKey];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		[cell.cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
		
		return cell;
	}
}

- (void)switchValueChanged:(id)sender {
	UISwitch *theSwitch = sender;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	if ([defaults objectForKey:kPasscodeKey]) {
        disablingPasscode = NO;
        
        LoginNavigationController *loginNavigationController = nil;
        
        if ([defaults boolForKey:kSimplePasscodeKey]) {
            loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:kLoginViewTypeFourDigit secondSegmentType:kLoginViewTypeTextField loginType:kLoginTypeChangePasscode];
        }
        else {
            loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:kLoginViewTypeTextField secondSegmentType:kLoginViewTypeFourDigit loginType:kLoginTypeChangePasscode];
        }
        
        loginNavigationController.loginNavigationControllerDelegate = self;
        [self safelyPresentModalViewController:loginNavigationController animated:YES completion:nil];
    }
    else {
        [defaults setBool:theSwitch.on forKey:kSimplePasscodeKey];
        [defaults synchronize];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (indexPath.section == 0) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		kLoginViewType universalLoginViewType;
		if ([defaults boolForKey:kSimplePasscodeKey]) {
			universalLoginViewType = kLoginViewTypeFourDigit;
		}
		else {
			universalLoginViewType = kLoginViewTypeTextField;
		}
		
        LoginNavigationController *loginNavigationController = nil;
        
		if (indexPath.row == 0) {
			if ([[NSUserDefaults standardUserDefaults]objectForKey:kPasscodeKey]) {
                disablingPasscode = YES;
                
				loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:universalLoginViewType secondSegmentType:universalLoginViewType loginType:kLoginTypeAuthenticate];
			}
			else {
                disablingPasscode = NO;
                
				loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:universalLoginViewType secondSegmentType:universalLoginViewType loginType:kLoginTypeCreatePasscode];
			}
		}
		else {
            disablingPasscode = NO;
            
            loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:universalLoginViewType secondSegmentType:universalLoginViewType loginType:kLoginTypeChangePasscode];
		}
        
        loginNavigationController.loginNavigationControllerDelegate = self;
		[self safelyPresentModalViewController:loginNavigationController animated:YES completion:nil];
	}
	else if ((indexPath.section == 1) && (indexPath.row == 0)) {
		PasscodeRequirementDelayViewController *passcodeRequirementDelayViewController = [[PasscodeRequirementDelayViewController alloc]init];
		passcodeRequirementDelayViewController.title = @"Require Passcode";
		[self.navigationController pushViewController:passcodeRequirementDelayViewController animated:YES];
	}
}

- (void)loginNavigationControllerDidAuthenticate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kPasscodeKey];
    [defaults synchronize];
}

- (void)loginNavigationControllerDidFinish {
    [self.tableView reloadData];
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
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
