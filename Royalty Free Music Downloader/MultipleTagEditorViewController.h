//
//  MultipleTagEditorViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MultipleTagEditorViewControllerDelegate.h"

@class File;

@interface MultipleTagEditorViewController : UITableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate> {
@public
    id <MultipleTagEditorViewControllerDelegate> __unsafe_unretained delegate;
@private
    NSArray *files;
    
    UIPopoverController *popoverController;
    UIImageView *albumArtworkImageView;
    NSInteger currentTextFieldTag;
    
    UIImage *commonArtwork;
    NSString *commonArtist;
    NSString *commonAlbumArtist;
    NSString *commonAlbum;
    NSString *commonGenre;
    NSNumber *commonYear;
    
    UIImage *artwork;
    BOOL didChangeArtwork;
    NSString *artist;
    BOOL shouldChangeArtist;
    NSString *albumArtist;
    BOOL shouldChangeAlbumArtist;
    NSString *album;
    BOOL shouldChangeAlbum;
    NSString *genre;
    BOOL shouldChangeGenre;
    NSNumber *year;
    BOOL shouldChangeYear;
}

@property (nonatomic, unsafe_unretained) id <MultipleTagEditorViewControllerDelegate> delegate;

- (id)initWithFiles:(NSArray *)filesArray;

@end
