//
//  TagEditorViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "TagEditorViewController.h"
#import "TextFieldDetailCell.h"
#import "TextViewCell.h"
#import "TagReader.h"
#import "DataManager.h"
#import "Player.h"
#import "TTTUnitOfInformationFormatter.h"
#import "FilePaths.h"
#import "File.h"
#import "File+Extensions.h"
#import "SkinManager.h"
#import "StandardGroupedCell.h"
#import "NSDateFormatter+Duration.h"
#import "UIViewController+SafeModal.h"
#import "UIImage+SafeStretchableImage.h"
#import "UITableView+SafeReload.h"

static NSString *kIncludeArtistInFileNameKey    = @"Include Artist In File Name";
static NSString *kGroupByAlbumArtistKey         = @"Group By Album Artist";

static NSString *kCopyFormatStr                 = @" (%i)";
static NSString *kIntegerFormatSpecifierStr     = @"%i";
static NSString *kNullStr                       = @"";

@interface TagEditorViewController ()

@property (nonatomic, strong) NSArray *files;
@property (nonatomic) NSInteger fileIndex;
@property (nonatomic, strong) File *currentFile;

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIImageView *albumArtworkImageView;
@property (nonatomic, strong) TTTUnitOfInformationFormatter *formatter;
@property (nonatomic) NSInteger currentTextFieldTag;
@property (nonatomic) NSInteger keyboardHeight;
@property (readwrite) BOOL keyboardIsVisible;

@property (nonatomic, strong) UIImage *artwork;
@property (readwrite) BOOL didChangeArtwork;
@property (nonatomic, strong) NSString *titleTag;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *albumArtist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSNumber *track;
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic) NSInteger playCount;
@property (nonatomic, strong) NSString *lyrics;

- (void)cancelButtonPressed;
- (void)doneButtonPressed;
- (void)previousButtonPressed;
- (void)nextButtonPressed;
- (void)updateElements;
- (void)scrollToCurrentTextFieldIfApplicable;
- (void)albumArtworkTapped;
- (void)presentImagePickerController;
- (void)updateArtwork:(UIImage *)newArtwork;
- (void)textFieldEditingChanged:(UITextField *)textField;
- (BOOL)stringIsValid:(NSString *)string;
- (void)saveTags;
- (TagReader *)currentTagReader;
- (void)updateFileName;

@end

@implementation TagEditorViewController

// Public
@synthesize delegate;

// Private
@synthesize files;
@synthesize fileIndex;
@synthesize currentFile;

@synthesize popoverController;
@synthesize albumArtworkImageView;
@synthesize formatter;
@synthesize currentTextFieldTag;
@synthesize keyboardHeight;
@synthesize keyboardIsVisible;

@synthesize artwork;
@synthesize didChangeArtwork;
@synthesize titleTag;
@synthesize artist;
@synthesize albumArtist;
@synthesize album;
@synthesize genre;
@synthesize track;
@synthesize year;
@synthesize fileName;
@synthesize playCount;
@synthesize lyrics;

#pragma mark - View lifecycle

- (id)initWithFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Initialization code
        
        files = [[NSArray alloc]initWithArray:filesArray];
        fileIndex = currentFileIndex;
        currentFile = [files objectAtIndex:fileIndex];
        
        formatter = [[TTTUnitOfInformationFormatter alloc]init];
        [formatter setDisplaysInTermsOfBytes:YES];
        [formatter setUsesIECBinaryPrefixesForCalculation:NO];
        [formatter setUsesIECBinaryPrefixesForDisplay:NO];
    }
    return self;
}

- (void)cancelButtonPressed {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(tagEditorViewControllerDidCancel)]) {
            [delegate tagEditorViewControllerDidCancel];
        }
    }
}

- (void)doneButtonPressed {
    [self saveTags];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(tagEditorViewControllerDidFinishEditingTags)]) {
            [delegate tagEditorViewControllerDidFinishEditingTags];
        }
    }
}

- (void)previousButtonPressed {
    if (fileIndex > 0) {
        [self saveTags];
        
        fileIndex -= 1;
        
        currentFile = [files objectAtIndex:fileIndex];
        [self updateElements];
    }
}

- (void)nextButtonPressed {
    if (fileIndex < ([files count] - 1)) {
        [self saveTags];
        
        fileIndex += 1;
        
        currentFile = [files objectAtIndex:fileIndex];
        [self updateElements];
    }
}

- (void)updateElements {
    artwork = [currentFile rawArtwork];
    didChangeArtwork = NO;
    titleTag = currentFile.title;
    artist = currentFile.artistName;
    albumArtist = currentFile.albumArtistName;
    album = currentFile.albumName;
    genre = currentFile.genre;
    track = currentFile.track;
    year = currentFile.year;
    fileName = [[currentFile filePath]lastPathComponent];
    playCount = [currentFile.playCount integerValue];
    lyrics = currentFile.lyrics;
    
    self.title = [NSString stringWithFormat:@"%i of %i", (fileIndex + 1), [files count]];
    
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
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    previousButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        previousButton.frame = CGRectMake(99, 32, 98, 40);
    }
    else {
        previousButton.frame = CGRectMake(513, 56, 98, 40);
    }
    
    if ([SkinManager iOS6Skin]) {
        previousButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [previousButton setTitleColor:[SkinManager iOS6SkinDarkGrayColor] forState:UIControlStateNormal];
        
        // If a UIButton is initialized with [UIButton buttonWithType:UIButtonTypeRoundedRect], the highlighted title color will be white by default.
        [previousButton setTitleColor:[SkinManager iOS6SkinDarkGrayColor] forState:UIControlStateHighlighted];
        
        [previousButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [previousButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateNormal];
        [previousButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button-Selected"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateHighlighted];
    }
    
    [previousButton setTitle:@"Previous" forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:previousButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nextButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        nextButton.frame = CGRectMake(212, 32, 98, 40);
    }
    else {
        nextButton.frame = CGRectMake(626, 56, 98, 40);
    }
    
    if ([SkinManager iOS6Skin]) {
        nextButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [nextButton setTitleColor:[SkinManager iOS6SkinDarkGrayColor] forState:UIControlStateNormal];
        
        // If a UIButton is initialized with [UIButton buttonWithType:UIButtonTypeRoundedRect], the highlighted title color will be white by default.
        [nextButton setTitleColor:[SkinManager iOS6SkinDarkGrayColor] forState:UIControlStateHighlighted];
        
        [nextButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [nextButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateNormal];
        [nextButton setBackgroundImage:[[UIImage imageNamed:@"Edit_Button-Selected"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:16] forState:UIControlStateHighlighted];
    }
    
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:nextButton];
    
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

- (void)scrollToCurrentTextFieldIfApplicable {
    NSIndexPath *finalIndexPath = nil;
    if (currentTextFieldTag < 7) {
        finalIndexPath = [NSIndexPath indexPathForRow:currentTextFieldTag inSection:0];
    }
    else if (currentTextFieldTag == 7) {
        finalIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    else {
        finalIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    }
    if (![[self.tableView indexPathsForRowsInRect:CGRectMake(0, (self.tableView.contentOffset.y - self.tableView.tableHeaderView.frame.size.height), self.tableView.frame.size.width, self.tableView.frame.size.height)]containsObject:finalIndexPath]) {
        [self.tableView scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 3) {
        return @"Lyrics";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 3) && (indexPath.row == 1)) {
        return 200;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 7;
        case 1:
            return 2;
        case 2:
            return 6;
        case 3:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (((indexPath.section == 1) && (indexPath.row == 1)) || ((indexPath.section == 2) && (indexPath.row == 5)) || ((indexPath.section == 3) && (indexPath.row == 0))) {
        static NSString *CellIdentifier = @"Cell 1";
        
        StandardGroupedCell *cell = (StandardGroupedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[StandardGroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (indexPath.section == 1) {
            cell.textLabel.text = @"Copy Title to File Name";
        }
        else if (indexPath.section == 2) {
            cell.textLabel.text = @"Reset Plays";
        }
        else {
            cell.textLabel.text = @"Clear Lyrics";
        }
        
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        return cell;
    }
    else if (indexPath.section < 3) {
        static NSString *CellIdentifier = @"Cell 2";
        
        TextFieldDetailCell *cell = (TextFieldDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[TextFieldDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                    cell.detailLabel.text = @"Title";
                    cell.textField.text = titleTag;
                    cell.textField.placeholder = currentFile.title;
                    cell.textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                case 1:
                    cell.detailLabel.text = @"Artist";
                    cell.textField.text = artist;
                    cell.textField.placeholder = currentFile.artistName;
                    cell.textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                case 2:
                    cell.detailLabel.text = @"Album Artist";
                    cell.textField.text = albumArtist;
                    cell.textField.placeholder = currentFile.albumArtistName;
                    cell.textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                case 3:
                    cell.detailLabel.text = @"Album";
                    cell.textField.text = album;
                    cell.textField.placeholder = currentFile.albumName;
                    cell.textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                case 4:
                    cell.detailLabel.text = @"Genre";
                    cell.textField.text = genre;
                    cell.textField.placeholder = currentFile.genre;
                    cell.textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                case 5:
                {
                    cell.detailLabel.text = @"Track";
                    
                    if (track) {
                        cell.textField.text = [NSString stringWithFormat:kIntegerFormatSpecifierStr, [track integerValue]];
                    }
                    else {
                        cell.textField.text = nil;
                    }
                    
                    if (currentFile.track) {
                        cell.textField.placeholder = [NSString stringWithFormat:kIntegerFormatSpecifierStr, [currentFile.track integerValue]];
                    }
                    else {
                        cell.textField.placeholder = nil;
                    }
                    
                    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                }
                    break;
                case 6:
                {
                    cell.detailLabel.text = @"Year";
                    
                    if (year) {
                        cell.textField.text = [NSString stringWithFormat:kIntegerFormatSpecifierStr, [year integerValue]];
                    }
                    else {
                        cell.textField.text = nil;
                    }
                    
                    if (currentFile.year) {
                        cell.textField.placeholder = [NSString stringWithFormat:kIntegerFormatSpecifierStr, [currentFile.year integerValue]];
                    }
                    else {
                        cell.textField.placeholder = nil;
                    }
                    
                    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                }
                    break;
            }
            
            cell.textField.tag = indexPath.row;
            cell.textField.delegate = self;
            [cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.textField.textColor = [UIColor blackColor];
            cell.textField.userInteractionEnabled = YES;
        }
        else if (indexPath.section == 1) {
            cell.detailLabel.text = @"File Name";
            cell.textField.text = fileName;
            cell.textField.placeholder = [[[currentFile filePath]lastPathComponent]stringByDeletingPathExtension];
            
            cell.textField.tag = 7;
            cell.textField.delegate = self;
            [cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            cell.textField.textColor = [UIColor blackColor];
            cell.textField.userInteractionEnabled = YES;
        }
        else {
            switch (indexPath.row) {
                case 0:
                    cell.detailLabel.text = @"Time";
                    cell.textField.text = [NSDateFormatter formattedDuration:[currentFile.duration longValue]];
                    break;
                case 1:
                    cell.detailLabel.text = @"Kind";
                    cell.textField.text = currentFile.uppercaseExtension;
                    break;
                case 2:
                    cell.detailLabel.text = @"Size";
                    cell.textField.text = [formatter stringFromNumber:currentFile.bytes ofUnit:TTTByte];
                    break;
                case 3:
                    cell.detailLabel.text = @"Bit Rate";
                    cell.textField.text = [NSString stringWithFormat:@"%@kbps", [currentFile.bitRate stringValue]];
                    break;
                case 4:
                    cell.detailLabel.text = @"Plays";
                    cell.textField.text = [NSString stringWithFormat:kIntegerFormatSpecifierStr, playCount];
                    break;
            }
            
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            cell.textField.textColor = [UIColor grayColor];
            cell.textField.userInteractionEnabled = NO;
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 3";
        
        TextViewCell *cell = (TextViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[TextViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textView.text = lyrics;
        cell.textView.delegate = self;
        
        return cell;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentTextFieldTag = textField.tag;
    
    if (currentTextFieldTag == 7) {
        textField.text = [fileName stringByDeletingPathExtension];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 5) {
        return ([[textField.text stringByReplacingCharactersInRange:range withString:string]length] <= 3);
    }
    else if (textField.tag == 6) {
        return ([[textField.text stringByReplacingCharactersInRange:range withString:string]length] <= 4);
    }
    return YES;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
    switch (textField.tag) {
        case 0:
            titleTag = textField.text;
            break;
        case 1:
            artist = textField.text;
            break;
        case 2:
            albumArtist = textField.text;
            break;
        case 3:
            album = textField.text;
            break;
        case 4:
            genre = textField.text;
            break;
        case 5:
        {
            if ([textField.text length] > 0) {
                track = [NSNumber numberWithInteger:[textField.text integerValue]];
            }
            else {
                track = nil;
            }
            break;
        }
        case 6:
        {
            if ([textField.text length] > 0) {
                year = [NSNumber numberWithInteger:[textField.text integerValue]];
            }
            else {
                year = nil;
            }
            break;
        }
        case 7:
        {
            if ([textField.text length] > 0) {
                NSString *pathExtension = [[currentFile filePath]pathExtension];
                if ([pathExtension length] > 0) {
                    fileName = [textField.text stringByAppendingPathExtension:pathExtension];
                }
                else {
                    fileName = textField.text;
                }
            }
            else {
                fileName = nil;
            }
        }
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ((textField.tag == 5) || (textField.tag == 6)) {
        // This will standardize the text input.
        [self.tableView safelyReloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (textField.tag == 7) {
        if (fileName) {
            [self updateFileName];
        }
        else {
            fileName = [[currentFile filePath]lastPathComponent];
            textField.text = fileName;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    currentTextFieldTag = 8;
}

- (void)textViewDidChange:(UITextView *)textView {
    lyrics = textView.text;
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
    BOOL tagsDidChange = NO;
    NSData *artworkData = nil;
    
    TagReader *tagReader = nil;
    
    if (didChangeArtwork) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        if (artwork) {
            artworkData = UIImageJPEGRepresentation(artwork, 1);
            tagReader.albumArt = artworkData;
        }
        else {
            tagReader.albumArt = nil;
        }
    }
    
    if (currentFile.title) {
        if ([self stringIsValid:titleTag]) {
            if (![currentFile.title isEqualToString:titleTag]) {
                if (!tagReader) {
                    tagReader = [self currentTagReader];
                }
                
                currentFile.title = titleTag;
                tagReader.title = titleTag;
                tagsDidChange = YES;
            }
        }
        // Because the title must be present for sorting to work properly, the user should not be able to delete it.
        /*
        else {
            if (!tagReader) {
                tagReader = [self currentTagReader];
            }
            
            currentFile.title = nil;
            tagReader.title = kNullStr;
            tagsDidChange = YES;
        }
        */
    }
    else if ([self stringIsValid:titleTag]) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        currentFile.title = titleTag;
        tagReader.title = titleTag;
        tagsDidChange = YES;
    }
    
    if (currentFile.artistName) {
        if ([self stringIsValid:artist]) {
            if (![currentFile.artistName isEqualToString:artist]) {
                if (!tagReader) {
                    tagReader = [self currentTagReader];
                }
                
                currentFile.artistName = artist;
                tagReader.artist = artist;
                tagsDidChange = YES;
            }
        }
        else {
            if (!tagReader) {
                tagReader = [self currentTagReader];
            }
            
            currentFile.artistName = nil;
            tagReader.artist = kNullStr;
            tagsDidChange = YES;
        }
    }
    else if ([self stringIsValid:artist]) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        currentFile.artistName = artist;
        tagReader.artist = artist;
        tagsDidChange = YES;
    }
    
    if (currentFile.albumArtistName) {
        if ([self stringIsValid:albumArtist]) {
            if (![currentFile.albumArtistName isEqualToString:albumArtist]) {
                if (!tagReader) {
                    tagReader = [self currentTagReader];
                }
                
                currentFile.albumArtistName = albumArtist;
                tagReader.albumArtist = albumArtist;
                tagsDidChange = YES;
            }
        }
        else {
            if (!tagReader) {
                tagReader = [self currentTagReader];
            }
            
            currentFile.albumArtistName = nil;
            tagReader.albumArtist = kNullStr;
            tagsDidChange = YES;
        }
    }
    else if ([self stringIsValid:albumArtist]) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        currentFile.albumArtistName = albumArtist;
        tagReader.albumArtist = albumArtist;
        tagsDidChange = YES;
    }
    
    if (currentFile.albumName) {
        if ([self stringIsValid:album]) {
            if (![currentFile.albumName isEqualToString:album]) {
                if (!tagReader) {
                    tagReader = [self currentTagReader];
                }
                
                currentFile.albumName = album;
                tagReader.album = album;
                tagsDidChange = YES;
            }
        }
        else {
            if (!tagReader) {
                tagReader = [self currentTagReader];
            }
            
            currentFile.albumName = nil;
            tagReader.album = kNullStr;
            tagsDidChange = YES;
        }
    }
    else if ([self stringIsValid:album]) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        currentFile.albumName = album;
        tagReader.album = album;
        tagsDidChange = YES;
    }
    
    if (currentFile.genre) {
        if ([self stringIsValid:genre]) {
            if (![currentFile.genre isEqualToString:genre]) {
                if (!tagReader) {
                    tagReader = [self currentTagReader];
                }
                
                currentFile.genre = genre;
                tagReader.genre = genre;
                tagsDidChange = YES;
            }
        }
        else {
            if (!tagReader) {
                tagReader = [self currentTagReader];
            }
            
            currentFile.genre = nil;
            tagReader.genre = kNullStr;
            tagsDidChange = YES;
        }
    }
    else if ([self stringIsValid:genre]) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        currentFile.genre = genre;
        tagReader.genre = genre;
        tagsDidChange = YES;
    }
    
    if (currentFile.track) {
        if (track) {
            if (![currentFile.track isEqualToNumber:track]) {
                if (!tagReader) {
                    tagReader = [self currentTagReader];
                }
                
                currentFile.track = track;
                tagReader.track = track;
                tagsDidChange = YES;
            }
        }
        else {
            if (!tagReader) {
                tagReader = [self currentTagReader];
            }
            
            currentFile.track = nil;
            tagReader.track = nil;
            tagsDidChange = YES;
        }
    }
    else if (track) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        currentFile.track = track;
        tagReader.track = track;
        tagsDidChange = YES;
    }
    
    if (currentFile.year) {
        if (year) {
            if (![currentFile.year isEqualToNumber:year]) {
                if (!tagReader) {
                    tagReader = [self currentTagReader];
                }
                
                currentFile.year = year;
                tagReader.year = year;
                tagsDidChange = YES;
            }
        }
        else {
            if (!tagReader) {
                tagReader = [self currentTagReader];
            }
            
            currentFile.year = nil;
            tagReader.year = nil;
            tagsDidChange = YES;
        }
    }
    else if (year) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        currentFile.year = year;
        tagReader.year = year;
        tagsDidChange = YES;
    }
    
    [self updateFileName];
    
    NSString *previousPath = [currentFile filePath];
    NSString *newPath = [[previousPath stringByDeletingLastPathComponent]stringByAppendingPathComponent:fileName];
    if (![newPath isEqual:previousPath]) {
        [[NSFileManager defaultManager]moveItemAtPath:previousPath toPath:newPath error:nil];
        
        NSURL *previousURL = [currentFile fileURL];
        
        currentFile.fileName = fileName;
        
        [[Player sharedPlayer]updateURLForFileWithNewURL:[currentFile fileURL] previousURL:previousURL];
        
        tagsDidChange = YES;
    }
    
    if ([currentFile.playCount integerValue] != playCount) {
        currentFile.playCount = [NSNumber numberWithInteger:playCount];
        tagsDidChange = YES;
    }
    
    if (currentFile.lyrics) {
        if ([self stringIsValid:lyrics]) {
            if (![currentFile.lyrics isEqualToString:lyrics]) {
                if (!tagReader) {
                    tagReader = [self currentTagReader];
                }
                
                currentFile.lyrics = lyrics;
                tagReader.lyrics = lyrics;
                tagsDidChange = YES;
            }
        }
        else {
            if (!tagReader) {
                tagReader = [self currentTagReader];
            }
            
            currentFile.lyrics = nil;
            tagReader.lyrics = kNullStr;
            tagsDidChange = YES;
        }
    }
    else if (lyrics) {
        if (!tagReader) {
            tagReader = [self currentTagReader];
        }
        
        currentFile.lyrics = lyrics;
        tagReader.lyrics = lyrics;
        tagsDidChange = YES;
    }
    
    if ((didChangeArtwork) || (tagsDidChange)) {
        // Don't update the database if the tag reader isn't able to save the file and crashes first.
        [tagReader save];
        
        DataManager *dataManager = [DataManager sharedDataManager];
        if (didChangeArtwork) {
            [dataManager updateThumbnailForFile:currentFile artworkData:artworkData];
        }
        if (tagsDidChange) {
            [dataManager updateRefsForFile:currentFile];
        }
        [dataManager saveContext];
    }
}

- (TagReader *)currentTagReader {
    TagReader *tagReader = [[TagReader alloc]initWithFileAtPath:[currentFile filePath]];
    return tagReader;
}

- (void)updateFileName {
    if ([self stringIsValid:fileName]) {
        if ([fileName rangeOfString:@"/"].length > 0) {
            UIAlertView *invalidFileNameAlert = [[UIAlertView alloc]
                                                 initWithTitle:@"Invalid File Name"
                                                 message:@"File names cannot contain slashes."
                                                 delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                 otherButtonTitles:nil];
            [invalidFileNameAlert show];
            
            fileName = [[currentFile filePath]lastPathComponent];
        }
        else {
            NSString *previousPath = [currentFile filePath];
            NSString *previousFileName = [previousPath lastPathComponent];
            if (![previousFileName isEqualToString:fileName]) {
                NSString *newBasePath = [previousPath stringByDeletingLastPathComponent];
                NSString *newPath = [newBasePath stringByAppendingPathComponent:fileName];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:newPath]) {
                    NSString *finalFileName = [newPath lastPathComponent];
                    NSString *filePathExtension = [finalFileName pathExtension];
                    
                    if ([filePathExtension length] > 0) {
                        NSString *baseFileName = [finalFileName stringByDeletingPathExtension];
                        
                        NSInteger copyNumber = 2;
                        
                        // If the file should be automatically renamed to its original title, it will not be renamed.
                        while ((![previousPath isEqualToString:[newBasePath stringByAppendingPathComponent:[[baseFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]stringByAppendingPathExtension:filePathExtension]]]) && ([fileManager fileExistsAtPath:[newBasePath stringByAppendingPathComponent:[[baseFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]stringByAppendingPathExtension:filePathExtension]]])) {
                            copyNumber += 1;
                        }
                        newPath = [newBasePath stringByAppendingPathComponent:[[baseFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]stringByAppendingPathExtension:filePathExtension]];
                    }
                    else {
                        NSInteger copyNumber = 2;
                        
                        // If the file should be automatically renamed to its original title, it will not be renamed.
                        while ((![previousPath isEqualToString:[newBasePath stringByAppendingPathComponent:[finalFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]]]) && ([fileManager fileExistsAtPath:[newBasePath stringByAppendingPathComponent:[finalFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]]])) {
                            copyNumber += 1;
                        }
                        newPath = [newBasePath stringByAppendingPathComponent:[finalFileName stringByAppendingFormat:kCopyFormatStr, copyNumber]];
                    }
                }
                
                // If the file should be automatically renamed to its original title, it will not be renamed.
                if ([previousPath isEqualToString:newPath]) {
                    fileName = [previousPath lastPathComponent];
                }
                else {
                    fileName = [newPath lastPathComponent];
                }
            }
        }
    }
    else {
        fileName = [[currentFile filePath]lastPathComponent];
    }
    
    [self.tableView safelyReloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
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
    
    if (indexPath.section < 2) {
        if ((indexPath.section == 1) && (indexPath.row == 1)) {
            if ([titleTag length] > 0) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if (([defaults boolForKey:kIncludeArtistInFileNameKey]) && (((artist) && ([[artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)) ||
                                                                            ((albumArtist) && ([[albumArtist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)))) {
                    
                    if ([defaults boolForKey:kGroupByAlbumArtistKey]) {
                        if ((albumArtist) && ([[albumArtist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)) {
                            fileName = [[albumArtist stringByAppendingString:@" - "]stringByAppendingString:titleTag];
                        }
                        else {
                            fileName = [[artist stringByAppendingString:@" - "]stringByAppendingString:titleTag];
                        }
                    }
                    else {
                        if ((artist) && ([[artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0)) {
                            fileName = [[artist stringByAppendingString:@" - "]stringByAppendingString:titleTag];
                        }
                        else {
                            fileName = [[albumArtist stringByAppendingString:@" - "]stringByAppendingString:titleTag];
                        }
                    }
                }
                else {
                    fileName = titleTag;
                }
                
                NSString *pathExtension = [[currentFile filePath]pathExtension];
                if ([pathExtension length] > 0) {
                    fileName = [fileName stringByAppendingPathExtension:pathExtension];
                }
            }
            else {
                fileName = nil;
            }
            [self updateFileName];
        }
        else {
            [[(TextFieldDetailCell *)[tableView cellForRowAtIndexPath:indexPath]textField]becomeFirstResponder];
        }
    }
    else if ((indexPath.section == 2) && (indexPath.row == 5)) {
        playCount = 0;
        
        [tableView safelyReloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            lyrics = nil;
            [[(TextViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]]textView]setText:nil];
        }
        else {
            [[(TextViewCell *)[tableView cellForRowAtIndexPath:indexPath]textView]becomeFirstResponder];
        }
    }
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
