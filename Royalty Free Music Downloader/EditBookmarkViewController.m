//
//  EditBookmarkViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "EditBookmarkViewController.h"
#import "MoveBookmarkItemViewController.h"
#import "TextFieldCell.h"
#import "BookmarkItem.h"
#import "BookmarkFolder.h"
#import "BookmarkFolderCell.h"
#import "SkinManager.h"
#import "UITableView+SafeReload.h"

@interface EditBookmarkViewController ()

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) NSString *bookmarkName;
@property (nonatomic, strong) NSString *bookmarkURL;
@property (nonatomic, strong) BookmarkFolder *parentBookmarkFolder;
@property (readwrite) BOOL didSave;
@property (readwrite) BOOL didPushViewController;
@property (readwrite) BOOL didCancel;

- (UIBarButtonItem *)cancelButton;
- (UIBarButtonItem *)saveButton;
- (void)cancelButtonPressed;
- (void)saveButtonPressed;
- (void)save;
- (void)formatBookmarkURL;

@end

@implementation EditBookmarkViewController

// Public
@synthesize delegate;

// Private
@synthesize cancelButton;
@synthesize saveButton;
@synthesize bookmarkName;
@synthesize bookmarkURL;
@synthesize parentBookmarkFolder;
@synthesize didSave;
@synthesize didPushViewController;
@synthesize didCancel;

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Initialization code
    }
    return self;
}

// Lazy-load these since they are not needed when a bookmark is being edited.

- (UIBarButtonItem *)cancelButton {
    if (!cancelButton) {
        cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    }
    return cancelButton;
}

- (UIBarButtonItem *)saveButton {
    if (!saveButton) {
        saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];;
    }
    return saveButton;
}

- (void)cancelButtonPressed {
    didCancel = YES;
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(editBookmarkViewControllerDidCancel)]) {
            [delegate editBookmarkViewControllerDidCancel];
        }
    }
}

- (void)saveButtonPressed {
    [self save];
}

- (void)save {
    didSave = YES;
    
    [self formatBookmarkURL];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(editBookmarkViewControllerDidChooseBookmarkName:url:parentBookmarkFolder:)]) {
            [delegate editBookmarkViewControllerDidChooseBookmarkName:bookmarkName url:bookmarkURL parentBookmarkFolder:parentBookmarkFolder];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([delegate editBookmarkViewControllerMode] == kEditBookmarkViewControllerModeAddBookmark) {
        self.navigationItem.leftBarButtonItem = [self cancelButton];
        self.navigationItem.rightBarButtonItem = [self saveButton];
    }
    
    bookmarkName = [delegate editBookmarkViewControllerBookmarkName];
    bookmarkURL = [delegate editBookmarkViewControllerBookmarkURL];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(editBookmarkViewControllerParentBookmarkFolder)]) {
            parentBookmarkFolder = [delegate editBookmarkViewControllerParentBookmarkFolder];
        }
    }
    
    [self.tableView safelyReloadData];
    
    if ([SkinManager iOS6Skin]) {
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
        self.tableView.backgroundView.hidden = YES;
    }
    else if ([SkinManager iOS7Skin]) {
        self.tableView.backgroundColor = [SkinManager iOS7SkinTableViewBackgroundColor];
        self.tableView.backgroundView.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // This prevents the bookmark structure from changing while the user is editing the current bookmark or if the user pressed the cancel button.
    if (!didCancel) {
        if (!didPushViewController) {
            if (!didSave) {
                [self formatBookmarkURL];
                
                if (delegate) {
                    if ([delegate respondsToSelector:@selector(editBookmarkViewControllerDidChooseBookmarkName:url:parentBookmarkFolder:)]) {
                        [delegate editBookmarkViewControllerDidChooseBookmarkName:bookmarkName url:bookmarkURL parentBookmarkFolder:parentBookmarkFolder];
                    }
                }
            }
        }
    }
    
    [super viewWillDisappear:animated];
}

- (void)formatBookmarkURL {
    if ([bookmarkURL length] > 0) {
        // Safari automatically changes capital letters in URLs to lowercase letters.
        // However, uppercase letters are sometimes necessary in URL queries, such as "http://www.youtube.com/watch?v=...".
        // Rather than create a filter to prevent changing URL queries to lowercase, it is a safer approach to avoid changing the URL to lowercase altogether.
        // bookmarkURL = [bookmarkURL lowercaseString];
        
        while ([bookmarkURL hasPrefix:@" "]) {
            bookmarkURL = [bookmarkURL substringFromIndex:1];
        }
        
        while ([bookmarkURL hasSuffix:@" "]) {
            bookmarkURL = [bookmarkURL substringToIndex:([bookmarkURL length] - 1)];
        }
        
        if ([bookmarkURL rangeOfString:@":"].length <= 0) {
            bookmarkURL = [@"http://" stringByAppendingString:bookmarkURL];
        }
        
        // This prevents the app from adding a slash to non-standard URLs (such as javascript commands with an address starting with "javascript:").
        // Because the URL isn't initially converted to lowercase (see above), a copy of it must be converted to lowercase before checking for the "http" prefix.
        if ([[bookmarkURL lowercaseString]hasPrefix:@"http"]) {
            if (![bookmarkURL hasSuffix:@"/"]) {
                bookmarkURL = [bookmarkURL stringByAppendingString:@"/"];
            }
        }
        
        bookmarkURL = [bookmarkURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([[UIScreen mainScreen]bounds].size.height == 568) {
            if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
                return @"\n\n";
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
    if (section == 0) {
        return 2;
    }
    else {
        return 1;
    }
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
        
        if (indexPath.row == 0) {
            cell.textField.text = bookmarkName;
            cell.textField.placeholder = @"Title";
            cell.textField.tag = 0;
            cell.textField.enabled = YES;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            
            if (![[(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]textField]isFirstResponder]) {
                [cell.textField becomeFirstResponder];
            }
        }
        else {
            cell.textField.text = bookmarkURL;
            cell.textField.placeholder = @"Address";
            cell.textField.tag = 1;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.keyboardType = UIKeyboardTypeURL;
            
            if ([delegate editBookmarkViewControllerMode] == kEditBookmarkViewControllerModeAddBookmark) {
                cell.textField.enabled = NO;
                cell.textField.textColor = [UIColor grayColor];
            }
            else {
                cell.textField.enabled = YES;
            }
        }
        
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.enablesReturnKeyAutomatically = YES;
        cell.textField.delegate = self;
        [cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventAllEditingEvents];
        
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (saveButton) {
        saveButton.enabled = ([textField.text length] > 0);
    }
}

- (void)textFieldEditingChanged:(id)sender {
    UITextField *textField = sender;
    
    if (textField.tag == 0) {
        bookmarkName = textField.text;
    }
    else {
        bookmarkURL = textField.text;
    }
    
    if (saveButton) {
        saveButton.enabled = ([textField.text length] > 0);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self save];
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
