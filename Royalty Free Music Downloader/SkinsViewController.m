//
//  SkinsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SkinsViewController.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "StandardGroupedCell.h"
#import "SkinManager.h"
#import "MBProgressHUD.h"

static NSString *kSkinIndexKey  = @"Skin Index";

@interface SkinsViewController ()

@property (nonatomic) NSInteger skinIndex;

@end

@implementation SkinsViewController

// Private
@synthesize skinIndex;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    skinIndex = [[NSUserDefaults standardUserDefaults]integerForKey:kSkinIndexKey];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    StandardGroupedCell *cell = (StandardGroupedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[StandardGroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Default Skin";
    }
    else {
        cell.textLabel.text = @"iOS 6 Skin";
    }
    
    if (indexPath.row == skinIndex) {
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
    
    if (indexPath.row != skinIndex) {
        NSInteger index = indexPath.row;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:index forKey:kSkinIndexKey];
        [defaults synchronize];
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        TabBarController *tabBarController = delegate.tabBarController;
        UIView *view = tabBarController.view;
        MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:view];
        hud.dimBackground = YES;
        hud.mode = MBProgressHUDModeIndeterminate;
        [view addSubview:hud];
        
        [hud showAnimated:YES whileExecutingBlock:^{
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            
            dispatch_async(mainQueue, ^{
                [SkinManager applySkinWithIndex:index];
            });
            
            // Propagate changes to visible portions of the app.
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                dispatch_async(mainQueue, ^{
                    NSString *title = viewController.title;
                    viewController.title = nil;
                    viewController.title = title;
                });
            }
            for (UIViewController *viewController in self.tabBarController.moreNavigationController.viewControllers) {
                dispatch_async(mainQueue, ^{
                    NSString *title = viewController.title;
                    viewController.title = nil;
                    viewController.title = title;
                });
            }
            
            for (UIWindow *window in [[UIApplication sharedApplication]windows]) {
                for (UIView *view in window.subviews) {
                    dispatch_async(mainQueue, ^{
                        [view removeFromSuperview];
                        [window addSubview:view];
                    });
                }
            }
            
            dispatch_async(mainQueue, ^{
                [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:skinIndex inSection:0]]setAccessoryType:UITableViewCellAccessoryNone];
                skinIndex = indexPath.row;
                [[tableView cellForRowAtIndexPath:indexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
            });
        }];
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
