//
//  UserAgentViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "UserAgentViewController.h"
#import "BrowserViewController.h"
#import "TextFieldCell.h"
#import "StandardGroupedCell.h"
#import "UITableView+SafeReload.h"

// This is a system key that should not be changed.
static NSString *kUserAgentKey          = @"UserAgent";

static NSString *kUserAgentIndexKey     = @"User Agent Index";
static NSString *kCustomUserAgentKey    = @"Custom User Agent";

static NSString *kiPhoneUserAgentStr    = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Mobile/8J2";
static NSString *kiPadUserAgentStr      = @"Mozilla/5.0 (iPad; U; CPU OS 4_2 like Mac OS X; ru-ru) AppleWebKit/533.17.9 (KHTML, like Gecko) Mobile/8C134";
static NSString *kFirefoxUserAgentStr   = @"Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20110506 Firefox/4.0.1";

@interface UserAgentViewController ()

@property (nonatomic) NSInteger userAgentIndex;

- (void)textFieldDidFinishEditing:(UITextField *)textField;

@end

@implementation UserAgentViewController

// Private
@synthesize userAgentIndex;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    userAgentIndex = [[NSUserDefaults standardUserDefaults]integerForKey:kUserAgentIndexKey];
    [self.tableView safelyReloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults]integerForKey:kUserAgentIndexKey] == 3) {
        UITextField *textField = [(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]textField];
        if ([textField isFirstResponder]) {
            if ([textField.text length] > 0) {
                [self textFieldDidFinishEditing:textField];
            }
            else {
                [textField resignFirstResponder];
            }
        }
    }
    [super viewWillDisappear:animated];
}

- (void)textFieldDidFinishEditing:(UITextField *)textField {
    NSDictionary *customUserAgentDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:textField.text, kUserAgentKey, nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:kCustomUserAgentKey];
    [defaults registerDefaults:customUserAgentDictionary];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kBrowserSettingsDidChangeNotification object:nil];
    
    [textField resignFirstResponder];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Custom User Agent";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if ([[NSUserDefaults standardUserDefaults]integerForKey:kUserAgentIndexKey] == 3) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 4;
    }
    return 1;
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
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Default (Recommended)";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"iPad";
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Firefox";
        }
        else {
            cell.textLabel.text = @"Custom";
        }
        
        if (userAgentIndex == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 2";
        
        TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[TextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textField.text = [[NSUserDefaults standardUserDefaults]objectForKey:kCustomUserAgentKey];
        cell.textField.placeholder = @"User Agent";
        cell.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.delegate = self;
        
        return cell;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self textFieldDidFinishEditing:textField];
    return NO;
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
        if (indexPath.row != userAgentIndex) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if (indexPath.row == 0) {
                NSMutableDictionary *registrationDomain = [NSMutableDictionary dictionaryWithDictionary:[defaults volatileDomainForName:NSRegistrationDomain]];
                [registrationDomain removeObjectForKey:kUserAgentKey];
                [defaults setVolatileDomain:registrationDomain forName:NSRegistrationDomain];
            }
            else if (indexPath.row < 3) {
                NSString *customUserAgent = nil;
                
                if (indexPath.row == 1) {
                    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        customUserAgent = kiPadUserAgentStr;
                    }
                    else {
                        customUserAgent = kiPhoneUserAgentStr;
                    }
                }
                else {
                    customUserAgent = kFirefoxUserAgentStr;
                }
                
                NSDictionary *customUserAgentDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:customUserAgent, kUserAgentKey, nil];
                [defaults registerDefaults:customUserAgentDictionary];
            }
            else {
                NSDictionary *customUserAgentDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[defaults objectForKey:kCustomUserAgentKey], kUserAgentKey, nil];
                [defaults registerDefaults:customUserAgentDictionary];
            }
            
            [defaults setInteger:indexPath.row forKey:kUserAgentIndexKey];
            [defaults synchronize];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kBrowserSettingsDidChangeNotification object:nil];
            
            if (indexPath.row == 3) {
                [tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            }
            else if (userAgentIndex == 3) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:userAgentIndex inSection:0]]setAccessoryType:UITableViewCellAccessoryNone];
            userAgentIndex = indexPath.row;
            [[tableView cellForRowAtIndexPath:indexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
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
