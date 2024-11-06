//
//  OptionsActionSheetHandler.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/24/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "OptionsActionSheetHandler.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "TagEditorNavigationController.h"
#import "MultipleTagEditorNavigationController.h"
#import "DataManager.h"
#import "File.h"
#import "File+Extensions.h"
#import "UIViewController+SafeModal.h"

static OptionsActionSheetHandler *sharedHandler = nil;

@interface OptionsActionSheetHandler ()

@property (nonatomic, strong) NSArray *pendingFiles;
@property (nonatomic) NSInteger pendingFileIndex;
@property (nonatomic, strong) File *pendingFile;
@property (nonatomic, strong) NSString *pendingSearchString;
@property (readwrite) BOOL canDeletePendingFiles;
@property (nonatomic) CGRect pendingRect;
@property (nonatomic, strong) UIView *pendingView;
@property (nonatomic, strong) UIBarButtonItem *pendingBarButtonItem;
@property (readwrite) BOOL shouldShowFromBarButtonItem;
@property (nonatomic, strong) UIActionSheet *optionsActionSheet;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

- (void)showFilesActionSheet;
- (void)showMultipleFilesActionSheet;

@end

@implementation OptionsActionSheetHandler

// Public
@synthesize delegate;

// Private
@synthesize pendingFiles;
@synthesize pendingFileIndex;
@synthesize pendingFile;
@synthesize pendingSearchString;
@synthesize canDeletePendingFiles;
@synthesize pendingRect;
@synthesize pendingView;
@synthesize pendingBarButtonItem;
@synthesize shouldShowFromBarButtonItem;
@synthesize optionsActionSheet;
@synthesize documentInteractionController;

+ (OptionsActionSheetHandler *)sharedHandler {
    @synchronized(sharedHandler) {
        if (!sharedHandler) {
            sharedHandler = [[OptionsActionSheetHandler alloc]init];
        }
        return sharedHandler;
    }
}

- (void)presentOptionsActionSheetForFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView canDelete:(BOOL)canDelete {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = CGRectMake((cell.contentView.frame.origin.x + cell.contentView.frame.size.width), cell.frame.origin.y, 44, 44);
    [self presentOptionsActionSheetForFiles:filesArray fileIndex:currentFileIndex fromRect:rect inView:tableView canDelete:canDelete];
}

- (void)presentOptionsActionSheetForFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex fromRect:(CGRect)rect inView:(UIView *)view canDelete:(BOOL)canDelete {
    pendingFiles = filesArray;
    pendingFileIndex = currentFileIndex;
    pendingFile = [pendingFiles objectAtIndex:pendingFileIndex];
    pendingRect = rect;
    pendingView = view;
    canDeletePendingFiles = canDelete;
    shouldShowFromBarButtonItem = NO;
    
    if (pendingFile.artistName) {
        pendingSearchString = [NSString stringWithFormat:@"%@ %@", pendingFile.artistName, pendingFile.title];;
    }
    else {
        pendingSearchString = pendingFile.title;
    }
    
    [self showFilesActionSheet];
}

- (void)presentOptionsActionSheetForFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex fromBarButtonItem:(UIBarButtonItem *)barButtonItem canDelete:(BOOL)canDelete {
    pendingFiles = filesArray;
    pendingFileIndex = currentFileIndex;
    pendingFile = [pendingFiles objectAtIndex:pendingFileIndex];
    pendingBarButtonItem = barButtonItem;
    canDeletePendingFiles = canDelete;
    shouldShowFromBarButtonItem = YES;
    
    if (pendingFile.artistName) {
        pendingSearchString = [NSString stringWithFormat:@"%@ %@", pendingFile.artistName, pendingFile.title];;
    }
    else {
        pendingSearchString = pendingFile.title;
    }
    
    [self showFilesActionSheet];
}

- (void)showFilesActionSheet {
    if (optionsActionSheet) {
        [optionsActionSheet dismissWithClickedButtonIndex:optionsActionSheet.cancelButtonIndex animated:YES];
        
        // The above line doesn't call the delegate methods, so the optionsActionSheet must be set to nil here.
        optionsActionSheet = nil;
    }
    else {
        optionsActionSheet = [[UIActionSheet alloc]
                              initWithTitle:pendingFile.title
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                              destructiveButtonTitle:canDeletePendingFiles ? @"Delete" : nil
                              otherButtonTitles:@"Edit Tags", @"Reset Plays", @"Search", @"Email", @"Open In...", nil];
        optionsActionSheet.tag = 0;
        
        // The only case in which this action sheet is shown with a delete button is when it is shown in the player view, which has a black color scheme.
        // To match the color scheme of the player view, the action sheet style is set to black translucent here.
        if (canDeletePendingFiles) {
            optionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        }
        
        if (shouldShowFromBarButtonItem) {
            [optionsActionSheet showFromBarButtonItem:pendingBarButtonItem animated:YES];
        }
        else {
            [optionsActionSheet showFromRect:pendingRect inView:pendingView animated:YES];
        }
    }
}

- (void)presentOptionsActionSheetForMultipleFiles:(NSArray *)filesArray fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView searchString:(NSString *)searchString canDelete:(BOOL)canDelete {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = CGRectMake((cell.contentView.frame.origin.x + cell.contentView.frame.size.width), cell.frame.origin.y, 44, 44);
    [self presentOptionsActionSheetForMultipleFiles:filesArray fromRect:rect inView:tableView searchString:searchString canDelete:canDelete];
}

- (void)presentOptionsActionSheetForMultipleFiles:(NSArray *)filesArray fromRect:(CGRect)rect inView:(UIView *)view searchString:(NSString *)searchString canDelete:(BOOL)canDelete {
    pendingFiles = filesArray;
    pendingRect = rect;
    pendingView = view;
    pendingSearchString = searchString;
    canDeletePendingFiles = canDelete;
    shouldShowFromBarButtonItem = NO;
    
    [self showMultipleFilesActionSheet];
}

- (void)presentOptionsActionSheetForMultipleFiles:(NSArray *)filesArray fromBarButtonItem:(UIBarButtonItem *)barButtonItem searchString:(NSString *)searchString canDelete:(BOOL)canDelete {
    pendingFiles = filesArray;
    pendingBarButtonItem = barButtonItem;
    pendingSearchString = searchString;
    canDeletePendingFiles = canDelete;
    shouldShowFromBarButtonItem = YES;
    
    [self showMultipleFilesActionSheet];
}

- (void)dismissOptionsActionSheetIfApplicable {
    if (optionsActionSheet) {
        [optionsActionSheet dismissWithClickedButtonIndex:optionsActionSheet.cancelButtonIndex animated:YES];
        
        // The above line doesn't call the delegate methods, so the optionsActionSheet must be set to nil here.
        optionsActionSheet = nil;
    }
}

- (void)showMultipleFilesActionSheet {
    if (optionsActionSheet) {
        [optionsActionSheet dismissWithClickedButtonIndex:optionsActionSheet.cancelButtonIndex animated:YES];
        
        // The above line doesn't call the delegate methods, so the optionsActionSheet must be set to nil here.
        optionsActionSheet = nil;
    }
    else {
        if (pendingSearchString) {
            if (canDeletePendingFiles) {
                optionsActionSheet = [[UIActionSheet alloc]
                                      initWithTitle:pendingSearchString
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Edit Tags", @"Reset Plays", @"Search", @"Delete", nil];
                optionsActionSheet.destructiveButtonIndex = 3;
            }
            else {
                optionsActionSheet = [[UIActionSheet alloc]
                                      initWithTitle:pendingSearchString
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Edit Tags", @"Reset Plays", @"Search", nil];
            }
        }
        else {
            if (canDeletePendingFiles) {
                optionsActionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Edit Tags", @"Reset Plays", @"Delete", nil];
                optionsActionSheet.destructiveButtonIndex = 2;
            }
            else {
                optionsActionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Edit Tags", @"Reset Plays", nil];
            }
        }
        
        optionsActionSheet.tag = 1;
        
        if (shouldShowFromBarButtonItem) {
            [optionsActionSheet showFromBarButtonItem:pendingBarButtonItem animated:YES];
        }
        else {
            [optionsActionSheet showFromRect:pendingRect inView:pendingView animated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet.tag == 0) {
            // This has to be presented on the root view controller because problems could arise if the player view controller is pushed off the navigation controller stack.
            TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
            
            NSInteger finalButtonIndex = buttonIndex;
            if (!canDeletePendingFiles) {
                finalButtonIndex += 1;
            }
            
            if (finalButtonIndex == 0) {
                [[DataManager sharedDataManager]deleteFile:pendingFile];
            }
            else if (finalButtonIndex == 1) {
                TagEditorNavigationController *tagEditorNavigationController = [[TagEditorNavigationController alloc]initWithFiles:pendingFiles fileIndex:pendingFileIndex];
                tagEditorNavigationController.tagEditorNavigationControllerDelegate = tabBarController;
                [tabBarController safelyPresentModalViewController:tagEditorNavigationController animated:YES completion:nil];
            }
            else if (finalButtonIndex == 2) {
                pendingFile.playCount = [NSNumber numberWithInteger:0];
                [[DataManager sharedDataManager]saveContext];
            }
            else if (finalButtonIndex == 3) {
                UIActionSheet *searchOptionsActionSheet = [[UIActionSheet alloc]
                                                           initWithTitle:pendingFile.title
                                                           delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                           destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Wikipedia", @"Google", @"YouTube", nil];
                searchOptionsActionSheet.tag = 1;
                
                // The only case in which this action sheet is shown with a delete button is when it is shown in the player view, which has a black color scheme.
                // To match the color scheme of the player view, the action sheet style is set to black translucent here.
                if (canDeletePendingFiles) {
                    searchOptionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                }
                
                if (shouldShowFromBarButtonItem) {
                    [searchOptionsActionSheet showFromBarButtonItem:pendingBarButtonItem animated:YES];
                }
                else {
                    [searchOptionsActionSheet showFromRect:pendingRect inView:pendingView animated:YES];
                }
            }
            else if (finalButtonIndex == 4) {
                NSString *mimeTypeString = nil;
                
                CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[[[pendingFile fileURL]path]pathExtension], NULL);
                CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
                CFRelease(UTI);
                if (mimeType) {
                    mimeTypeString = (__bridge NSString *)mimeType;
                }
                else {
                    mimeTypeString = @"application/octet-stream";
                }
                
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
                    mailComposeViewController.mailComposeDelegate = self;
                    
                    // Apple will reject apps that use full screen modal view controllers on the iPad.
                    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    
                    [mailComposeViewController addAttachmentData:[NSData dataWithContentsOfURL:[pendingFile fileURL]] mimeType:mimeTypeString fileName:[[[pendingFile fileURL]path]lastPathComponent]];
                    [tabBarController safelyPresentModalViewController:mailComposeViewController animated:YES completion:nil];
                }
                else {
                    UIAlertView *cannotSendMailAlert = [[UIAlertView alloc]
                                                        initWithTitle:@"Cannot Send Email"
                                                        message:@"You must configure your device to work with your email account in order to send email. Would you like to do this now?"
                                                        delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                        otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
                    [cannotSendMailAlert show];
                }
            }
            else {
                documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[pendingFile fileURL]];
                documentInteractionController.delegate = self;
                [documentInteractionController presentOptionsMenuFromRect:pendingRect inView:pendingView animated:YES];
            }
        }
        else if (actionSheet.tag == 1) {
            // This has to be presented on the root view controller because problems could arise if the player view controller is pushed off the navigation controller stack.
            TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
            
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [[DataManager sharedDataManager]deleteFiles:[NSSet setWithArray:pendingFiles]];
            }
            else {
                if (buttonIndex == 0) {
                    // The functions for multiple files can be used in situations where a single file is to be treated as a group thereof, such as when an artist with one song is edited as an artist.
                    // For this reason, the following conditional must be used to determine the correct tag editor to use.
                    
                    if ([pendingFiles count] > 1) {
                        MultipleTagEditorNavigationController *multipleTagEditorNavigationController = [[MultipleTagEditorNavigationController alloc]initWithFiles:pendingFiles];
                        multipleTagEditorNavigationController.multipleTagEditorNavigationControllerDelegate = tabBarController;
                        [tabBarController safelyPresentModalViewController:multipleTagEditorNavigationController animated:YES completion:nil];
                    }
                    else {
                        TagEditorNavigationController *tagEditorNavigationController = [[TagEditorNavigationController alloc]initWithFiles:pendingFiles fileIndex:0];
                        tagEditorNavigationController.tagEditorNavigationControllerDelegate = tabBarController;
                        [tabBarController safelyPresentModalViewController:tagEditorNavigationController animated:YES completion:nil];
                    }
                }
                else if (buttonIndex == 1) {
                    for (int i = 0; i < [pendingFiles count]; i++) {
                        File *file = [pendingFiles objectAtIndex:i];
                        file.playCount = [NSNumber numberWithInteger:0];
                    }
                    
                    [[DataManager sharedDataManager]saveContext];
                }
                else {
                    UIActionSheet *searchOptionsActionSheet = [[UIActionSheet alloc]
                                                               initWithTitle:pendingSearchString
                                                               delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                               destructiveButtonTitle:nil
                                                               otherButtonTitles:@"Wikipedia", @"Google", @"YouTube", nil];
                    searchOptionsActionSheet.tag = 2;
                    
                    if (shouldShowFromBarButtonItem) {
                        [searchOptionsActionSheet showFromBarButtonItem:pendingBarButtonItem animated:YES];
                    }
                    else {
                        [searchOptionsActionSheet showFromRect:pendingRect inView:pendingView animated:YES];
                    }
                }
            }
        }
        else {
            NSString *baseURLString = nil;
            
            if (buttonIndex == 0) {
                baseURLString = @"http://m.wikipedia.org/wiki/Special:Search?search=";
            }
            else if (buttonIndex == 1) {
                baseURLString = @"http://www.google.com/search?q=";
            }
            else {
                baseURLString = @"http://m.youtube.com/results?search_query=";
            }
            
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[baseURLString stringByAppendingString:[pendingSearchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
        }
        
        if (delegate) {
            if ([delegate respondsToSelector:@selector(optionsActionSheetHandlerDidFinish)]) {
                [delegate optionsActionSheetHandlerDidFinish];
            }
        }
    }
    
    // This prevents the delegate from persisting in case it is deallocated at a later point in time.
    delegate = nil;
    
    optionsActionSheet = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto:"]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]safelyDismissModalViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultFailed) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error"
                                   message:@"Your message could not be sent. This could be due to little or no Internet connectivity."
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles:nil];
		[errorAlert show];
    }
}

@end
