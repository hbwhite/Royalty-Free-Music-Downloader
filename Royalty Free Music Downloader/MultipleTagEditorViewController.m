//
//  MultipleTagEditorViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "MultipleTagEditorViewController.h"
#import "AppDelegate.h"
#import "TextFieldCheckmarkDetailCell.h"
#import "TagReader.h"
#import "DataManager.h"
#import "MBProgressHUD.h"
#import "FilePaths.h"
#import "File.h"
#import "File+Extensions.h"
#import "SkinManager.h"
#import "NSDateFormatter+Duration.h"
#import "UIViewController+SafeModal.h"
#import "UITableView+SafeReload.h"

static NSString *kIntegerFormatSpecifierStr = @"%i";
static NSString *kNullStr                   = @"";

@interface MultipleTagEditorViewController ()

@property (nonatomic, strong) NSArray *files;

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIImageView *albumArtworkImageView;
@property (nonatomic) NSInteger currentTextFieldTag;

@property (nonatomic, strong) UIImage *commonArtwork;
@property (nonatomic, strong) NSString *commonArtist;
@property (nonatomic, strong) NSString *commonAlbumArtist;
@property (nonatomic, strong) NSString *commonAlbum;
@property (nonatomic, strong) NSString *commonGenre;
@property (nonatomic, strong) NSNumber *commonYear;

@property (nonatomic, strong) UIImage *artwork;
@property (readwrite) BOOL didChangeArtwork;
@property (nonatomic, strong) NSString *artist;
@property (readwrite) BOOL shouldChangeArtist;
@property (nonatomic, strong) NSString *albumArtist;
@property (readwrite) BOOL shouldChangeAlbumArtist;
@property (nonatomic, strong) NSString *album;
@property (readwrite) BOOL shouldChangeAlbum;
@property (nonatomic, strong) NSString *genre;
@property (readwrite) BOOL shouldChangeGenre;
@property (nonatomic, strong) NSNumber *year;
@property (readwrite) BOOL shouldChangeYear;

- (void)cancelButtonPressed;
- (void)doneButtonPressed;
- (void)updateElements;
- (void)scrollToCurrentTextFieldIfApplicable;
- (void)albumArtworkTapped;
- (void)presentImagePickerController;
- (void)updateArtwork:(UIImage *)newArtwork;
- (void)toggleShouldChangeArtist;
- (void)toggleShouldChangeAlbumArtist;
- (void)toggleShouldChangeAlbum;
- (void)toggleShouldChangeGenre;
- (void)toggleShouldChangeYear;
- (void)textFieldEditingChanged:(UITextField *)textField;
- (BOOL)stringIsValid:(NSString *)string;
- (void)saveTags;
- (void)_saveTagsWithHUD:(MBProgressHUD *)hud;
- (TagReader *)tagReaderForFile:(File *)file;

@end

@implementation MultipleTagEditorViewController

// Public
@synthesize delegate;

// Private
@synthesize files;

@synthesize popoverController;
@synthesize albumArtworkImageView;
@synthesize currentTextFieldTag;

@synthesize commonArtwork;
@synthesize commonArtist;
@synthesize commonAlbumArtist;
@synthesize commonAlbum;
@synthesize commonGenre;
@synthesize commonYear;

@synthesize artwork;
@synthesize didChangeArtwork;
@synthesize artist;
@synthesize shouldChangeArtist;
@synthesize albumArtist;
@synthesize shouldChangeAlbumArtist;
@synthesize album;
@synthesize shouldChangeAlbum;
@synthesize genre;
@synthesize shouldChangeGenre;
@synthesize year;
@synthesize shouldChangeYear;

#pragma mark - View lifecycle

- (id)initWithFiles:(NSArray *)filesArray {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Initialization code
        
        files = [[NSArray alloc]initWithArray:filesArray];
    }
    return self;
}

- (void)cancelButtonPressed {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(multipleTagEditorViewControllerDidCancel)]) {
            [delegate multipleTagEditorViewControllerDidCancel];
        }
    }
}

- (void)doneButtonPressed {
    [self saveTags];
}

- (void)updateElements {
    for (int i = 0; i < [files count]; i++) {
        File *file = [files objectAtIndex:i];
        if (i > 0) {
            if (commonArtwork) {
                UIImage *currentArtwork = [file rawArtwork];
                if (currentArtwork) {
                    if (![UIImageJPEGRepresentation(commonArtwork, 1) isEqualToData:UIImageJPEGRepresentation(currentArtwork, 1)]) {
                        commonArtwork = nil;
                    }
                }
                else {
                    commonArtwork = nil;
                }
            }
            if (commonArtist) {
                NSString *currentArtist = file.artistName;
                if (currentArtist) {
                    if (![commonArtist isEqualToString:currentArtist]) {
                        commonArtist = nil;
                    }
                }
                else {
                    commonArtist = nil;
                }
            }
            if (commonAlbumArtist) {
                NSString *currentAlbumArtist = file.albumArtistName;
                if (currentAlbumArtist) {
                    if (![commonAlbumArtist isEqualToString:currentAlbumArtist]) {
                        commonAlbumArtist = nil;
                    }
                }
                else {
                    commonAlbumArtist = nil;
                }
            }
            if (commonAlbum) {
                NSString *currentAlbum = file.albumName;
                if (currentAlbum) {
                    if (![commonAlbum isEqualToString:currentAlbum]) {
                        commonAlbum = nil;
                    }
                }
                else {
                    commonAlbum = nil;
                }
            }
            if (commonGenre) {
                NSString *currentGenre = file.genre;
                if (currentGenre) {
                    if (![commonGenre isEqualToString:currentGenre]) {
                        commonGenre = nil;
                    }
                }
                else {
                    commonGenre = nil;
                }
            }
            if (commonYear) {
                NSNumber *currentYear = file.year;
                if (currentYear) {
                    if (![commonYear isEqualToNumber:currentYear]) {
                        commonYear = nil;
                    }
                }
                else {
                    commonYear = nil;
                }
            }
        }
        else {
            commonArtwork = [file rawArtwork];
            commonArtist = file.artistName;
            commonAlbumArtist = file.albumArtistName;
            commonAlbum = file.albumName;
            commonGenre = file.genre;
            commonYear = file.year;
        }
    }
    
    artwork = commonArtwork;
    artist = commonArtist;
    albumArtist = commonAlbumArtist;
    album = commonAlbum;
    genre = commonGenre;
    year = commonYear;
    
    if (artwork) {
        albumArtworkImageView.image = artwork;
    }
    else {
        albumArtworkImageView.image = [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork"];
    }
    
    [self.tableView safelyReloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIView *tableHeaderView = [[UIView alloc]init];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        tableHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
    }
    else {
        tableHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 144);
    }
    
    tableHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableHeaderView.backgroundColor = [UIColor clearColor];
    
    CGRect albumArtworkImageViewFrame;
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        albumArtworkImageViewFrame = CGRectMake(20, 20, 64, 64);
    }
    else {
        albumArtworkImageViewFrame = CGRectMake(44, 44, 64, 64);
    }
    
    albumArtworkImageView = [[UIImageView alloc]initWithFrame:albumArtworkImageViewFrame];
    albumArtworkImageView.layer.masksToBounds = YES;
    albumArtworkImageView.layer.cornerRadius = 3;
    albumArtworkImageView.backgroundColor = [UIColor blackColor];
    albumArtworkImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton *albumArtworkEditMaskButton = [UIButton buttonWithType:UIButtonTypeCustom];
    albumArtworkEditMaskButton.frame = albumArtworkImageViewFrame;
    [albumArtworkEditMaskButton setImage:[UIImage imageNamed:@"Artwork_Edit_Mask"] forState:UIControlStateNormal];
    [albumArtworkEditMaskButton addTarget:self action:@selector(albumArtworkTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *albumArtworkEditLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 49, 64, 15)];
    albumArtworkEditLabel.text = NSLocalizedString(@"Edit", @"");
    albumArtworkEditLabel.textAlignment = UITextAlignmentCenter;
    albumArtworkEditLabel.font = [UIFont systemFontOfSize:15];
    albumArtworkEditLabel.textColor = [UIColor whiteColor];
    albumArtworkEditLabel.backgroundColor = [UIColor clearColor];
    [albumArtworkEditMaskButton addSubview:albumArtworkEditLabel];
    
    [tableHeaderView addSubview:albumArtworkImageView];
    [tableHeaderView addSubview:albumArtworkEditMaskButton];
    
    [self updateElements];
    
    self.tableView.tableHeaderView = tableHeaderView;
    
    // This ensures that the frame of the table header view stays consistent.
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

- (void)keyboardDidShow:(NSNotification *)notification {
    [self scrollToCurrentTextFieldIfApplicable];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
    [self scrollToCurrentTextFieldIfApplicable];
}

- (void)scrollToCurrentTextFieldIfApplicable {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentTextFieldTag inSection:0];
    if (![[self.tableView indexPathsForRowsInRect:CGRectMake(0, (self.tableView.contentOffset.y - self.tableView.tableHeaderView.frame.size.height), self.tableView.frame.size.width, self.tableView.frame.size.height)]containsObject:indexPath]) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

- (void)albumArtworkTapped {
    if (artwork) {
        if ([[UIPasteboard generalPasteboard]image]) {
            UIActionSheet *chooseAlbumArtworkActionSheet = [[UIActionSheet alloc]
                                                            initWithTitle:nil
                                                            delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                            destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Choose from Photo Library", @"Paste", @"Copy", @"Save to Camera Roll", @"Delete Artwork", nil];
            chooseAlbumArtworkActionSheet.tag = 3;
            chooseAlbumArtworkActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            chooseAlbumArtworkActionSheet.destructiveButtonIndex = 4;
            [chooseAlbumArtworkActionSheet showFromRect:albumArtworkImageView.bounds inView:albumArtworkImageView animated:YES];
        }
        else {
            UIActionSheet *chooseAlbumArtworkActionSheet = [[UIActionSheet alloc]
                                                            initWithTitle:nil
                                                            delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                            destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Choose from Photo Library", @"Copy", @"Save to Camera Roll", @"Delete Artwork", nil];
            chooseAlbumArtworkActionSheet.tag = 2;
            chooseAlbumArtworkActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            chooseAlbumArtworkActionSheet.destructiveButtonIndex = 3;
            [chooseAlbumArtworkActionSheet showFromRect:albumArtworkImageView.bounds inView:albumArtworkImageView animated:YES];
        }
    }
    else {
        if ([[UIPasteboard generalPasteboard]image]) {
            UIActionSheet *chooseAlbumArtworkActionSheet = [[UIActionSheet alloc]
                                                            initWithTitle:nil
                                                            delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                            destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Choose from Photo Library", @"Paste", nil];
            chooseAlbumArtworkActionSheet.tag = 1;
            chooseAlbumArtworkActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [chooseAlbumArtworkActionSheet showFromRect:albumArtworkImageView.bounds inView:albumArtworkImageView animated:YES];
        }
        else {
            UIActionSheet *chooseAlbumArtworkActionSheet = [[UIActionSheet alloc]
                                                            initWithTitle:nil
                                                            delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                            destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Choose from Photo Library", nil];
            chooseAlbumArtworkActionSheet.tag = 0;
            chooseAlbumArtworkActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [chooseAlbumArtworkActionSheet showFromRect:albumArtworkImageView.bounds inView:albumArtworkImageView animated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet.tag == 0) {
            [self presentImagePickerController];
        }
        else if (actionSheet.tag == 1) {
            if (buttonIndex == 0) {
                [self presentImagePickerController];
            }
            else {
                [self updateArtwork:[[UIPasteboard generalPasteboard]image]];
            }
        }
        else if (actionSheet.tag == 2) {
            if (buttonIndex == 0) {
                [self presentImagePickerController];
            }
            else if (buttonIndex == 1) {
                [[UIPasteboard generalPasteboard]setImage:artwork];
            }
            else if (buttonIndex == 2) {
                UIImageWriteToSavedPhotosAlbum(artwork, nil, nil, nil);
            }
            else {
                artwork = nil;
                didChangeArtwork = YES;
                albumArtworkImageView.image = [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork"];
            }
        }
        else if (actionSheet.tag == 3) {
            if (buttonIndex == 0) {
                [self presentImagePickerController];
            }
            else if (buttonIndex == 1) {
                [self updateArtwork:[[UIPasteboard generalPasteboard]image]];
            }
            else if (buttonIndex == 2) {
                [[UIPasteboard generalPasteboard]setImage:artwork];
            }
            else if (buttonIndex == 3) {
                UIImageWriteToSavedPhotosAlbum(artwork, nil, nil, nil);
            }
            else {
                artwork = nil;
                didChangeArtwork = YES;
                albumArtworkImageView.image = [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork"];
            }
        }
    }
}

- (void)presentImagePickerController {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self safelyPresentModalViewController:imagePickerController animated:YES completion:nil];
    }
    else {
        // On the iPad, instances of UIImagePickerController must be presented using an instance of UIPopoverController.
        popoverController = [[UIPopoverController alloc]initWithContentViewController:imagePickerController];
        [popoverController presentPopoverFromRect:albumArtworkImageView.bounds inView:albumArtworkImageView permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionLeft) animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([self safeModalViewController]) {
        [self safelyDismissModalViewControllerAnimated:YES completion:nil];
    }
    else if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self updateArtwork:image];
    
    if ([self safeModalViewController]) {
        [self safelyDismissModalViewControllerAnimated:YES completion:nil];
    }
    else if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (void)updateArtwork:(UIImage *)newArtwork {
    artwork = newArtwork;
    didChangeArtwork = YES;
    if (artwork) {
        albumArtworkImageView.image = artwork;
    }
    else {
        albumArtworkImageView.image = [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    TextFieldCheckmarkDetailCell *cell = (TextFieldCheckmarkDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TextFieldCheckmarkDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    switch (indexPath.row) {
        case 0:
            cell.detailLabel.text = @"Artist";
            cell.textField.text = artist;
            cell.textField.placeholder = commonArtist;
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            [cell setCheckmarkVisible:shouldChangeArtist];
            [cell.checkmarkButton addTarget:self action:@selector(toggleShouldChangeArtist) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 1:
            cell.detailLabel.text = @"Album Artist";
            cell.textField.text = albumArtist;
            cell.textField.placeholder = commonAlbumArtist;
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            [cell setCheckmarkVisible:shouldChangeAlbumArtist];
            [cell.checkmarkButton addTarget:self action:@selector(toggleShouldChangeAlbumArtist) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 2:
            cell.detailLabel.text = @"Album";
            cell.textField.text = album;
            cell.textField.placeholder = commonAlbum;
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            [cell setCheckmarkVisible:shouldChangeAlbum];
            [cell.checkmarkButton addTarget:self action:@selector(toggleShouldChangeAlbum) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 3:
            cell.detailLabel.text = @"Genre";
            cell.textField.text = genre;
            cell.textField.placeholder = commonGenre;
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            [cell setCheckmarkVisible:shouldChangeGenre];
            [cell.checkmarkButton addTarget:self action:@selector(toggleShouldChangeGenre) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 4:
        {
            cell.detailLabel.text = @"Year";
            
            if (year) {
                cell.textField.text = [NSString stringWithFormat:kIntegerFormatSpecifierStr, [year integerValue]];
            }
            else {
                cell.textField.text = nil;
            }
            
            if (commonYear) {
                cell.textField.placeholder = [NSString stringWithFormat:kIntegerFormatSpecifierStr, [commonYear integerValue]];
            }
            else {
                cell.textField.placeholder = nil;
            }
            
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            
            [cell setCheckmarkVisible:shouldChangeYear];
            [cell.checkmarkButton addTarget:self action:@selector(toggleShouldChangeYear) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
    }
    
    cell.textField.tag = indexPath.row;
    cell.textField.delegate = self;
    [cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    cell.textField.textColor = [UIColor blackColor];
    cell.textField.userInteractionEnabled = YES;
    
    return cell;
}

- (void)toggleShouldChangeArtist {
    shouldChangeArtist = !shouldChangeArtist;
    [(TextFieldCheckmarkDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]setCheckmarkVisible:shouldChangeArtist];
}

- (void)toggleShouldChangeAlbumArtist {
    shouldChangeAlbumArtist = !shouldChangeAlbumArtist;
    [(TextFieldCheckmarkDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]setCheckmarkVisible:shouldChangeAlbumArtist];
}

- (void)toggleShouldChangeAlbum {
    shouldChangeAlbum = !shouldChangeAlbum;
    [(TextFieldCheckmarkDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]setCheckmarkVisible:shouldChangeAlbum];
}

- (void)toggleShouldChangeGenre {
    shouldChangeGenre = !shouldChangeGenre;
    [(TextFieldCheckmarkDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]]setCheckmarkVisible:shouldChangeGenre];
}

- (void)toggleShouldChangeYear {
    shouldChangeYear = !shouldChangeYear;
    [(TextFieldCheckmarkDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]]setCheckmarkVisible:shouldChangeYear];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentTextFieldTag = textField.tag;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 4) {
        return ([[textField.text stringByReplacingCharactersInRange:range withString:string]length] <= 4);
    }
    return YES;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
    switch (textField.tag) {
        case 0:
            artist = textField.text;
            if (!shouldChangeArtist) [self toggleShouldChangeArtist];
            break;
        case 1:
            albumArtist = textField.text;
            if (!shouldChangeAlbumArtist) [self toggleShouldChangeAlbumArtist];
            break;
        case 2:
            album = textField.text;
            if (!shouldChangeAlbum) [self toggleShouldChangeAlbum];
            break;
        case 3:
            genre = textField.text;
            if (!shouldChangeGenre) [self toggleShouldChangeGenre];
            break;
        case 4:
        {
            if ([textField.text length] > 0) {
                year = [NSNumber numberWithInteger:[textField.text integerValue]];
            }
            else {
                year = nil;
            }
            if (!shouldChangeYear) [self toggleShouldChangeYear];
            break;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 4) {
        // This will standardize the text input.
        [self.tableView safelyReloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)stringIsValid:(NSString *)string {
    if (string) {
        if ([string length] > 0) {
            if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)saveTags {
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:window];
    hud.dimBackground = YES;
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_MESSAGE", @"");
    hud.detailsLabelText = NSLocalizedString(@"WAITING_FOR_POST_PROCESSING_TO_FINISH_SUBTITLE", @"");
    [window addSubview:hud];
    
    [hud showWhileExecuting:@selector(_saveTagsWithHUD:) onTarget:self withObject:hud animated:YES];
}

- (void)_saveTagsWithHUD:(MBProgressHUD *)hud {
    BOOL tagsDidChange = NO;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    NSInteger fileCount = [files count];
    for (int i = 0; i < fileCount; i++) {
        File *file = [files objectAtIndex:i];
        
        NSData *artworkData = nil;
        
        TagReader *tagReader = nil;
        
        if (didChangeArtwork) {
            if (!tagReader) {
                tagReader = [self tagReaderForFile:file];
            }
            
            if (artwork) {
                artworkData = UIImageJPEGRepresentation(artwork, 1);
                tagReader.albumArt = artworkData;
            }
            else {
                tagReader.albumArt = nil;
            }
        }
        
        // Because this is run in the background, all file properties must be updated on the main thread. For consistency, dispatch_sync() is used instead of dispatch_async() where applicable.
        
        if (shouldChangeArtist) {
            if (file.artistName) {
                if ([self stringIsValid:artist]) {
                    if (![file.artistName isEqualToString:artist]) {
                        if (!tagReader) {
                            tagReader = [self tagReaderForFile:file];
                        }
                        
                        [file performSelectorOnMainThread:@selector(setArtistName:) withObject:artist waitUntilDone:YES];
                        tagReader.artist = artist;
                        tagsDidChange = YES;
                    }
                }
                else {
                    if (!tagReader) {
                        tagReader = [self tagReaderForFile:file];
                    }
                    
                    [file performSelectorOnMainThread:@selector(setArtistName:) withObject:nil waitUntilDone:YES];
                    tagReader.artist = kNullStr;
                    tagsDidChange = YES;
                }
            }
            else if ([self stringIsValid:artist]) {
                if (!tagReader) {
                    tagReader = [self tagReaderForFile:file];
                }
                
                [file performSelectorOnMainThread:@selector(setArtistName:) withObject:artist waitUntilDone:YES];
                tagReader.artist = artist;
                tagsDidChange = YES;
            }
        }
        
        if (shouldChangeAlbumArtist) {
            if (file.albumArtistName) {
                if ([self stringIsValid:albumArtist]) {
                    if (![file.albumArtistName isEqualToString:albumArtist]) {
                        if (!tagReader) {
                            tagReader = [self tagReaderForFile:file];
                        }
                        
                        [file performSelectorOnMainThread:@selector(setAlbumArtistName:) withObject:albumArtist waitUntilDone:YES];
                        tagReader.albumArtist = albumArtist;
                        tagsDidChange = YES;
                    }
                }
                else {
                    if (!tagReader) {
                        tagReader = [self tagReaderForFile:file];
                    }
                    
                    [file performSelectorOnMainThread:@selector(setAlbumArtistName:) withObject:nil waitUntilDone:YES];
                    tagReader.albumArtist = kNullStr;
                    tagsDidChange = YES;
                }
            }
            else if ([self stringIsValid:albumArtist]) {
                if (!tagReader) {
                    tagReader = [self tagReaderForFile:file];
                }
                
                [file performSelectorOnMainThread:@selector(setAlbumArtistName:) withObject:albumArtist waitUntilDone:YES];
                tagReader.albumArtist = albumArtist;
                tagsDidChange = YES;
            }
        }
        
        if (shouldChangeAlbum) {
            if (file.albumName) {
                if ([self stringIsValid:album]) {
                    if (![file.albumName isEqualToString:album]) {
                        if (!tagReader) {
                            tagReader = [self tagReaderForFile:file];
                        }
                        
                        [file performSelectorOnMainThread:@selector(setAlbumName:) withObject:album waitUntilDone:YES];
                        tagReader.album = album;
                        tagsDidChange = YES;
                    }
                }
                else {
                    if (!tagReader) {
                        tagReader = [self tagReaderForFile:file];
                    }
                    
                    [file performSelectorOnMainThread:@selector(setAlbumName:) withObject:nil waitUntilDone:YES];
                    tagReader.album = kNullStr;
                    tagsDidChange = YES;
                }
            }
            else if ([self stringIsValid:album]) {
                if (!tagReader) {
                    tagReader = [self tagReaderForFile:file];
                }
                
                [file performSelectorOnMainThread:@selector(setAlbumName:) withObject:album waitUntilDone:YES];
                tagReader.album = album;
                tagsDidChange = YES;
            }
        }
        
        if (shouldChangeGenre) {
            if (file.genre) {
                if ([self stringIsValid:genre]) {
                    if (![file.genre isEqualToString:genre]) {
                        if (!tagReader) {
                            tagReader = [self tagReaderForFile:file];
                        }
                        
                        [file performSelectorOnMainThread:@selector(setGenre:) withObject:genre waitUntilDone:YES];
                        tagReader.genre = genre;
                        tagsDidChange = YES;
                    }
                }
                else {
                    if (!tagReader) {
                        tagReader = [self tagReaderForFile:file];
                    }
                    
                    [file performSelectorOnMainThread:@selector(setGenre:) withObject:nil waitUntilDone:YES];
                    tagReader.genre = kNullStr;
                    tagsDidChange = YES;
                }
            }
            else if ([self stringIsValid:genre]) {
                if (!tagReader) {
                    tagReader = [self tagReaderForFile:file];
                }
                
                [file performSelectorOnMainThread:@selector(setGenre:) withObject:genre waitUntilDone:YES];
                tagReader.genre = genre;
                tagsDidChange = YES;
            }
        }
        
        if (shouldChangeYear) {
            if (file.year) {
                if (year) {
                    if (![file.year isEqualToNumber:year]) {
                        if (!tagReader) {
                            tagReader = [self tagReaderForFile:file];
                        }
                        
                        [file performSelectorOnMainThread:@selector(setYear:) withObject:year waitUntilDone:YES];
                        tagReader.year = year;
                        tagsDidChange = YES;
                    }
                }
                else {
                    if (!tagReader) {
                        tagReader = [self tagReaderForFile:file];
                    }
                    
                    [file performSelectorOnMainThread:@selector(setYear:) withObject:nil waitUntilDone:YES];
                    tagReader.year = nil;
                    tagsDidChange = YES;
                }
            }
            else if (year) {
                if (!tagReader) {
                    tagReader = [self tagReaderForFile:file];
                }
                
                [file performSelectorOnMainThread:@selector(setYear:) withObject:year waitUntilDone:YES];
                tagReader.year = year;
                tagsDidChange = YES;
            }
        }
        
        if ((didChangeArtwork) || (tagsDidChange)) {
            // Don't update the database if the tag reader isn't able to save the file and crashes first.
            [tagReader save];
            
            dispatch_sync(mainQueue, ^{
                DataManager *dataManager = [DataManager sharedDataManager];
                if (didChangeArtwork) {
                    [dataManager updateThumbnailForFile:file artworkData:artworkData];
                }
                if (tagsDidChange) {
                    [dataManager updateRefsForFile:file];
                }
            });
        }
        
        dispatch_async(mainQueue, ^{
            hud.progress = ((CGFloat)(i + 1) / (CGFloat)fileCount);
        });
    }
    
    dispatch_async(mainQueue, ^{
        hud.mode = MBProgressHUDModeIndeterminate;
    });
    
    dispatch_sync(mainQueue, ^{
        if ((didChangeArtwork) || (tagsDidChange)) {
            [[DataManager sharedDataManager]saveContext];
        }
        
        if (delegate) {
            if ([delegate respondsToSelector:@selector(multipleTagEditorViewControllerDidFinishEditingTags)]) {
                [delegate multipleTagEditorViewControllerDidFinishEditingTags];
            }
        }
    });
}

- (TagReader *)tagReaderForFile:(File *)file {
    // This function is performed in the background and allocates memory.
    // To ensure that it does not leak memory on devices running iOS 4, its contents must be contained within an autorelease pool block.
    @autoreleasepool {
        TagReader *tagReader = [[TagReader alloc]initWithFileAtPath:[file filePath]];
        return tagReader;
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[(TextFieldCheckmarkDetailCell *)[tableView cellForRowAtIndexPath:indexPath]textField]becomeFirstResponder];
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
