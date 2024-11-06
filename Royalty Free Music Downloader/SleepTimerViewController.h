//
//  EqualizerViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SleepTimerViewControllerDelegate.h"

@interface SleepTimerViewController : UIViewController <NSFetchedResultsControllerDelegate> {
@public
    id <SleepTimerViewControllerDelegate> __unsafe_unretained delegate;
@private
    IBOutlet UIDatePicker *timePicker;
    IBOutlet UILabel *timeRemainingLabel;
    IBOutlet UIImageView *buttonBackgroundImageView;
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *pauseButton;
    IBOutlet UIButton *stopButton;
    UIBarButtonItem *doneButton;
}

@property (nonatomic, unsafe_unretained) id <SleepTimerViewControllerDelegate> delegate;

@end
