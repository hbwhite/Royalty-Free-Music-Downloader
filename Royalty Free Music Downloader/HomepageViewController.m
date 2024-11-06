//
//  HomepageViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "HomepageViewController.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "TabBarController.h"
#import "BrowserViewController.h"
#import "TextFieldCell.h"
#import "StandardGroupedCell.h"
#import "UITableView+SafeReload.h"

static NSString *kHomepageKey       = @"Homepage";

static NSString *kFAQURLStr         = @"http://www.harrisonapps.com/royaltyfreemusic/";
static NSString *kBlankPageURLStr   = @"about:blank";

@interface HomepageViewController ()

@property (nonatomic, strong) NSString *currentPageTitle;
@property (nonatomic, strong) NSString *currentPageURL;
@property (nonatomic) kHomepageOption homepageOption;

- (void)textFieldDidFinishEditing:(UITextField *)textField;

@end

@implementation HomepageViewController

// Private
@synthesize currentPageTitle;
@synthesize currentPageURL;
@synthesize homepageOption;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    currentPageTitle = nil;
    currentPageURL = nil;
    
    NSArray *viewControllers = [[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]viewControllers];
    for (int i = 0; i < [viewControllers count]; i++) {
        UIViewController *viewController = [[viewControllers objectAtIndex:i]topViewController];
        if ([viewController isKindOfClass:[BrowserViewController class]]) {
            BrowserViewController *browserViewController = (BrowserViewController *)viewController;
            currentPageTitle = browserViewController.title;
            currentPageURL = [browserViewController.currentURL absoluteString];
            break;
        }
    }
    
    NSString *homepageURL = [[NSUserDefaults standardUserDefaults]objectForKey:kHomepageKey];
    
    if ([homepageURL isEqualToString:kFAQURLStr]) {
        homepageOption = kHomepageOptionFAQ;
    }
    else if ([homepageURL isEqualToString:kBlankPageURLStr]) {
        homepageOption = kHomepageOptionBlankPage;
    }
    else {
        homepageOption = kHomepageOptionNone;
    }
    
    [self.tableView safelyReloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    UITextField *textField = [(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField];
    if ([textField isFirstResponder]) {
        [self textFieldDidFinishEditing:textField];
    }
    [super viewWillDisappear:animated];
}

- (void)textFieldDidFinishEditing:(UITextField *)textField {
    NSString *homepageURL = textField.text;
    
    if ([homepageURL length] > 0) {
        while ([homepageURL hasPrefix:@" "]) {
            homepageURL = [homepageURL substringFromIndex:1];
        }
        
        while ([homepageURL hasSuffix:@" "]) {
            homepageURL = [homepageURL substringToIndex:([homepageURL length] - 1)];
        }
        
        if ([homepageURL rangeOfString:@":"].length <= 0) {
            homepageURL = [@"http://" stringByAppendingString:homepageURL];
        }
        
        if (![homepageURL hasSuffix:@"/"]) {
            homepageURL = [homepageURL stringByAppendingString:@"/"];
        }
        
        homepageURL = [homepageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:homepageURL forKey:kHomepageKey];
        [defaults synchronize];
        
        if ([homepageURL isEqualToString:kFAQURLStr]) {
            homepageOption = kHomepageOptionFAQ;
        }
        else if ([homepageURL isEqualToString:kBlankPageURLStr]) {
            homepageOption = kHomepageOptionBlankPage;
        }
        else {
            homepageOption = kHomepageOptionNone;
        }
    }
    
    [self.tableView safelyReloadData];
    
    [textField resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (currentPageURL) {
        return 3;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 1) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Current Homepage";
    }
    else if (section == 2) {
        return @"Current Page In Browser";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell 1";
        
        TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[TextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textField.placeholder = @"Address";
        cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.textField.keyboardType = UIKeyboardTypeURL;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.delegate = self;
        cell.textField.text = [[NSUserDefaults standardUserDefaults]objectForKey:kHomepageKey];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 2";
        
        StandardGroupedCell *cell = (StandardGroupedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[StandardGroupedCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"FAQ";
                cell.detailTextLabel.text = kFAQURLStr;
                
                if (homepageOption == kHomepageOptionFAQ) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            else {
                cell.textLabel.text = @"Blank Page";
                cell.detailTextLabel.text = @"about:blank";
                
                if (homepageOption == kHomepageOptionBlankPage) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
        else {
            cell.textLabel.text = currentPageTitle;
            cell.detailTextLabel.text = currentPageURL;
        }
        
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
    
    if (indexPath.section > 0) {
        if (indexPath.section == 1) {
            if (homepageOption != kHomepageOptionNone) {
                NSIndexPath *previousSelectedIndexPath = nil;
                
                if (homepageOption == kHomepageOptionFAQ) {
                    previousSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                }
                else {
                    previousSelectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                }
                
                [[tableView cellForRowAtIndexPath:previousSelectedIndexPath]setAccessoryType:UITableViewCellAccessoryNone];
            }
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if (indexPath.row == 0) {
                [defaults setObject:kFAQURLStr forKey:kHomepageKey];
                homepageOption = kHomepageOptionFAQ;
            }
            else {
                [defaults setObject:kBlankPageURLStr forKey:kHomepageKey];
                homepageOption = kHomepageOptionBlankPage;
            }
            
            [defaults synchronize];
            [[tableView cellForRowAtIndexPath:indexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            [tableView safelyReloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:currentPageURL forKey:kHomepageKey];
            [defaults synchronize];
            
            if ([currentPageURL isEqualToString:kFAQURLStr]) {
                homepageOption = kHomepageOptionFAQ;
            }
            else if ([currentPageURL isEqualToString:kBlankPageURLStr]) {
                homepageOption = kHomepageOptionBlankPage;
            }
            else {
                homepageOption = kHomepageOptionNone;
            }
            
            [tableView safelyReloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];
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
