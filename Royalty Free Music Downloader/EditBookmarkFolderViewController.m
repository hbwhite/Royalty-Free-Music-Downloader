//
//  EditBookmarkFolderViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "EditBookmarkFolderViewController.h"
#import "MoveBookmarkItemViewController.h"
#import "TextFieldCell.h"
#import "BookmarkFolder.h"
#import "BookmarkFolderCell.h"
#import "SkinManager.h"
#import "UIViewController+NibSelect.h"
#import "UITableView+SafeReload.h"

@interface EditBookmarkFolderViewController ()

@property (nonatomic, strong) NSString *bookmarkFolderName;
@property (nonatomic, strong) BookmarkFolder *parentBookmarkFolder;
@property (readwrite) BOOL didSave;
@property (readwrite) BOOL didPushViewController;

@end

@implementation EditBookmarkFolderViewController

// Public
@synthesize delegate;

// Private
@synthesize bookmarkFolderName;
@synthesize parentBookmarkFolder;
@synthesize didSave;
@synthesize didPushViewController;

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(editBookmarkFolderViewControllerBookmarkFolder)]) {
            BookmarkFolder *bookmarkFolder = [delegate editBookmarkFolderViewControllerBookmarkFolder];
            bookmarkFolderName = bookmarkFolder.name;
        }
        if ([delegate respondsToSelector:@selector(editBookmarkFolderViewControllerParentBookmarkFolder)]) {
            parentBookmarkFolder = [delegate editBookmarkFolderViewControllerParentBookmarkFolder];
        }
        
        [self.tableView safelyReloadData];
    }
    
    if ([SkinManager iOS6Skin]) {
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
        self.tableView.backgroundView.hidden = YES;
    }
    else if ([SkinManager iOS7Skin]) {
        self.tableView.backgroundColor = [SkinManager iOS7SkinTableViewBackgroundColor];
        self.tableView.backgroundView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // This allows the app to save the bookmark folder by pressing the back button after returning from a pushed view controller.
    if (didPushViewController) {
        didPushViewController = NO;
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    // This prevents the bookmark folder structure from changing while the user is editing the current bookmark folder.
    if (!didPushViewController) {
        if (!didSave) {
            if ([bookmarkFolderName length] > 0) {
                if (delegate) {
                    if ([delegate respondsToSelector:@selector(editBookmarkFolderViewControllerDidChooseBookmarkFolderName:parentBookmarkFolder:)]) {
                        [delegate editBookmarkFolderViewControllerDidChooseBookmarkFolderName:bookmarkFolderName parentBookmarkFolder:parentBookmarkFolder];
                    }
                }
            }
        }
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([[UIScreen mainScreen]bounds].size.height == 568) {
            if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
                return @"\n\n\n";
            }
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
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
        
        cell.textField.text = bookmarkFolderName;
        cell.textField.placeholder = @"Title";
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.enablesReturnKeyAutomatically = YES;
        cell.textField.delegate = self;
        [cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventAllEditingEvents];
        [cell.textField becomeFirstResponder];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 2";
        
        BookmarkFolderCell *cell = (BookmarkFolderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[BookmarkFolderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (parentBookmarkFolder) {
            cell.textLabel.text = parentBookmarkFolder.name;
        }
        else {
            cell.textLabel.text = @"Bookmarks";
        }
        
        return cell;
    }
}

- (void)textFieldEditingChanged:(id)sender {
    UITextField *textField = sender;
    bookmarkFolderName = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    didSave = YES;
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(editBookmarkFolderViewControllerDidChooseBookmarkFolderName:parentBookmarkFolder:)]) {
            [delegate editBookmarkFolderViewControllerDidChooseBookmarkFolderName:bookmarkFolderName parentBookmarkFolder:parentBookmarkFolder];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
    
    if (indexPath.section == 1) {
        didPushViewController = YES;
        
        MoveBookmarkItemViewController *moveBookmarkItemViewController = [[MoveBookmarkItemViewController alloc]initWithStyle:UITableViewStylePlain];
        moveBookmarkItemViewController.title = @"Bookmarks";
        moveBookmarkItemViewController.delegate = self;
        moveBookmarkItemViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:moveBookmarkItemViewController animated:YES];
    }
}

- (BookmarkFolder *)moveBookmarkItemViewControllerBookmarkFolder {
    return [delegate editBookmarkFolderViewControllerBookmarkFolder];
}

- (BookmarkFolder *)moveBookmarkItemViewControllerParentBookmarkFolder {
    return parentBookmarkFolder;
}

- (void)moveBookmarkItemViewControllerDidSelectBookmarkFolder:(BookmarkFolder *)bookmarkFolder {
    parentBookmarkFolder = bookmarkFolder;
    
    // This ensures that the keyboard will not be dismissed.
    [self.tableView safelyReloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    
    didPushViewController = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// iOS 6 Rotation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
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
