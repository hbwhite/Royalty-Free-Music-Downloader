//
//  TagEditorViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TagEditorViewControllerDelegate.h"

@class File;
@class TTTUnitOfInformationFormatter;

@interface TagEditorViewController : UITableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate> {
@public
    id <TagEditorViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSArray *files;
    NSInteger fileIndex;
    File *currentFile;
    
    UIPopoverController *popoverController;
    UIImageView *albumArtworkImageView;
    TTTUnitOfInformationFormatter *formatter;
    NSInteger currentTextFieldTag;
    
    UIImage *artwork;
    BOOL didChangeArtwork;
    NSString *titleTag;
    NSString *artist;
    NSString *albumArtist;
    NSString *album;
    NSString *genre;
    NSNumber *track;
    NSNumber *year;
    NSString *fileName;
    NSInteger playCount;
    NSString *lyrics;
}

@property (nonatomic, unsafe_unretained) id <TagEditorViewControllerDelegate> delegate;

- (id)initWithFiles:(NSArray *)filesArray fileIndex:(NSInteger)currentFileIndex;

@end
