//
//  TextInputViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "TextInputViewController.h"
#import "TextFieldCell.h"
#import "SkinManager.h"
#import "UIViewController+SafeModal.h"
#import "UITableView+SafeReload.h"

@interface TextInputViewController ()

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSString *titleField;
@property (readwrite) BOOL didAssignFirstResponder;

- (void)cancelButtonPressed;
- (void)doneButtonPressed;
- (void)didFinishTextEntry;

@end

@implementation TextInputViewController

// Public
@synthesize delegate;

// Private
@synthesize cancelButton;
@synthesize doneButton;
@synthesize titleField;
@synthesize didAssignFirstResponder;

#pragma mark - View lifecycle

- (void)cancelButtonPressed {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(textInputViewControllerDidCancel)]) {
            [delegate textInputViewControllerDidCancel];
        }
    }
}

- (void)doneButtonPressed {
    [self didFinishTextEntry];
}

- (void)didFinishTextEntry {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(textInputViewControllerDidReceiveTextInput:)]) {
            [delegate textInputViewControllerDidReceiveTextInput:titleField];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.title = [delegate textInputViewControllerNavigationBarTitle];
    titleField = [delegate textInputViewControllerDefaultText];
    [self.tableView safelyReloadData];
    
    if ([SkinManager iOS6Skin]) {
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
        self.tableView.backgroundView.hidden = YES;
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return [delegate textInputViewControllerHeader];
    }
    else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 1) {
        return 1;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    cell.textField.text = titleField;
    cell.textField.placeholder = [delegate textInputViewControllerPlaceholder];
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.enablesReturnKeyAutomatically = YES;
    cell.textField.delegate = self;
    [cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventAllEditingEvents];
    
    if (!didAssignFirstResponder) {
        [cell.textField becomeFirstResponder];
        didAssignFirstResponder = YES;
    }
    
    return cell;
}

- (void)textFieldEditingChanged:(id)sender {
    UITextField *textField = sender;
    titleField = textField.text;
    doneButton.enabled = ([textField.text length] > 0);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self didFinishTextEntry];
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
