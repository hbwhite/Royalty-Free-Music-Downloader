//
//  FilesViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/22/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "VisibilityViewController.h"
#import "FilesViewControllerDelegate.h"
#import "TagEditorNavigationControllerDelegate.h"

enum {
    kSortIndexName = 0,
    kSortIndexDate,
    kSortIndexSize,
    kSortIndexTime
};
typedef NSUInteger kSortIndex;

enum {
    kEditButtonIdentifierNone = 0,
    kEditButtonIdentifierName,
    kEditButtonIdentifierDate,
    kEditButtonIdentifierSize,
    kEditButtonIdentifierTime
};
typedef NSUInteger kEditButtonIdentifier;

@class TTTUnitOfInformationFormatter;
@class Directory;
@class Archive;

@interface FilesViewController : VisibilityViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, FilesViewControllerDelegate, TagEditorNavigationControllerDelegate> {
@public
    id <FilesViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSFetchedResultsController *foldersFetchedResultsController;
    NSFetchedResultsController *archivesFetchedResultsController;
    NSFetchedResultsController *songsFetchedResultsController;
    UIDocumentInteractionController *documentInteractionController;
    TTTUnitOfInformationFormatter *formatter;
    NSDateFormatter *dateFormatter;
    UILabel *itemCountLabel;
    Directory *selectedDirectory;
    Archive *pendingArchive;
    CGRect pendingRect;
    
    kEditButtonIdentifier lastButtonIdentifier;
    BOOL sortAscending;
}

@property (nonatomic, unsafe_unretained) id <FilesViewControllerDelegate> delegate;

@end
