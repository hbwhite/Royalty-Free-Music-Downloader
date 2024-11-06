//
//  OptionsActionSheetHandler.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/24/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import "OptionsActionSheetHandlerDelegate.h"

@class File;

@interface OptionsActionSheetHandler : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate> {
@public
    id <OptionsActionSheetHandlerDelegate> __unsafe_unretained delegate;
@private
    NSArray *pendingFiles;
    NSInteger pendingFileIndex;
    File *pendingFile;
    NSString *pendingSearchString;
    BOOL canDeletePendingFiles;
    CGRect pendingRect;
    UIView *pendingView;
    UIBarButtonItem *pendingBarButtonItem;
    BOOL shouldShowFromBarButtonItem;
    UIActionSheet *optionsActionSheet;
    UIDocumentInteractionController *documentInteractionController;
}

@property (nonatomic, unsafe_unretained) id <OptionsActionSheetHandlerDelegate> delegate;

+ (OptionsActionSheetHandler *)sharedHandler;
- (void)presentOptionsActionSheetForFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView canDelete:(BOOL)canDelete;
- (void)presentOptionsActionSheetForFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex fromRect:(CGRect)rect inView:(UIView *)view canDelete:(BOOL)canDelete;
- (void)presentOptionsActionSheetForFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex fromBarButtonItem:(UIBarButtonItem *)barButtonItem canDelete:(BOOL)canDelete;
- (void)presentOptionsActionSheetForMultipleFiles:(NSArray *)filesArray fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView searchString:(NSString *)searchString canDelete:(BOOL)canDelete;
- (void)presentOptionsActionSheetForMultipleFiles:(NSArray *)filesArray fromRect:(CGRect)rect inView:(UIView *)view searchString:(NSString *)searchString canDelete:(BOOL)canDelete;
- (void)presentOptionsActionSheetForMultipleFiles:(NSArray *)filesArray fromBarButtonItem:(UIBarButtonItem *)barButtonItem searchString:(NSString *)searchString canDelete:(BOOL)canDelete;
- (void)dismissOptionsActionSheetIfApplicable;

@end
