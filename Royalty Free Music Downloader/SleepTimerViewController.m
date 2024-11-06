//
//  SleepTimerViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SleepTimerViewController.h"
#import "Player.h"
#import "SkinManager.h"
#import "NSDateFormatter+Duration.h"
#import "UIImage+SafeStretchableImage.h"

static NSString *kSleepTimerDurationKey = @"Sleep Timer Duration";

@interface SleepTimerViewController ()

@property (nonatomic, strong) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, strong) IBOutlet UILabel *timeRemainingLabel;
@property (nonatomic, strong) IBOutlet UIImageView *buttonBackgroundImageView;
@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

- (IBAction)startButtonPressed;
- (IBAction)pauseButtonPressed;
- (IBAction)stopButtonPressed;
- (void)doneButtonPressed;
- (void)updateTimerState;
- (void)updateTimeRemainingLabel;

@end

@implementation SleepTimerViewController

// Public
@synthesize timePicker;
@synthesize timeRemainingLabel;
@synthesize buttonBackgroundImageView;
@synthesize startButton;
@synthesize pauseButton;
@synthesize stopButton;
@synthesize delegate;

// Private
@synthesize doneButton;

#pragma mark - View lifecycle

- (IBAction)startButtonPressed {
    // This forces the duration to be a whole number in terms of minutes.
    NSInteger countDownDuration = (((NSInteger)(timePicker.countDownDuration / 60.0)) * 60);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:countDownDuration forKey:kSleepTimerDurationKey];
    [defaults synchronize];
    
    Player *player = [Player sharedPlayer];
    player.sleepDelay = countDownDuration;
    [player initializeSleepTimer];
}

- (IBAction)pauseButtonPressed {
    Player *player = [Player sharedPlayer];
    
    if (player.timerState == kTimerStateRunning) {
        [player pauseSleepTimer];
    }
    else {
        [player initializeSleepTimer];
    }
}

- (IBAction)stopButtonPressed {
    [[Player sharedPlayer]stopSleepTimer];
}

- (void)doneButtonPressed {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(sleepTimerViewControllerDidFinish)]) {
            [delegate sleepTimerViewControllerDidFinish];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(updateTimerState) name:kPlayerSleepTimerStateDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateTimeRemainingLabel) name:kPlayerSleepTimerDelayDidChangeNotification object:nil];
    
    if ([SkinManager iOS7]) {
        self.view.backgroundColor = [UIColor whiteColor];
        timeRemainingLabel.textColor = [UIColor blackColor];
        buttonBackgroundImageView.hidden = YES;
    }
    else {
        // This fixes a strange problem that can occur on older devices (such as the iPhone 3GS) where the text color of UILabels is initially black instead of white.
        timeRemainingLabel.textColor = [UIColor whiteColor];
    }
    
    if ([SkinManager iOS7Skin]) {
        [startButton setTitleColor:[SkinManager iOS7SkinBlueColor] forState:UIControlStateNormal];
        [pauseButton setTitleColor:[SkinManager iOS7SkinBlueColor] forState:UIControlStateNormal];
        [stopButton setTitleColor:[SkinManager iOS7SkinBlueColor] forState:UIControlStateNormal];
        
        [startButton setTitleColor:[SkinManager iOS7SkinHighlightedBlueColor] forState:UIControlStateHighlighted];
        [pauseButton setTitleColor:[SkinManager iOS7SkinHighlightedBlueColor] forState:UIControlStateHighlighted];
        [stopButton setTitleColor:[SkinManager iOS7SkinHighlightedBlueColor] forState:UIControlStateHighlighted];
        
        [startButton setTitleShadowColor:nil forState:UIControlStateNormal];
        [pauseButton setTitleShadowColor:nil forState:UIControlStateNormal];
        [stopButton setTitleShadowColor:nil forState:UIControlStateNormal];
        
        startButton.titleLabel.font = [UIFont systemFontOfSize:24];
        pauseButton.titleLabel.font = [UIFont systemFontOfSize:24];
        stopButton.titleLabel.font = [UIFont systemFontOfSize:24];
        
        startButton.titleLabel.layer.shadowOpacity = 0;
        pauseButton.titleLabel.layer.shadowOpacity = 0;
        stopButton.titleLabel.layer.shadowOpacity = 0;
    }
    else {
        [startButton setBackgroundImage:[[UIImage imageNamed:@"Start_Button"]safeStretchableImageWithLeftCapWidth:10 topCapHeight:23] forState:UIControlStateNormal];
        [startButton setBackgroundImage:[[UIImage imageNamed:@"Start_Button-Selected"]safeStretchableImageWithLeftCapWidth:10 topCapHeight:23] forState:UIControlStateHighlighted];
        
        [pauseButton setBackgroundImage:[[UIImage imageNamed:@"Pause_Button"]safeStretchableImageWithLeftCapWidth:10 topCapHeight:23] forState:UIControlStateNormal];
        [pauseButton setBackgroundImage:[[UIImage imageNamed:@"Pause_Button-Selected"]safeStretchableImageWithLeftCapWidth:10 topCapHeight:23] forState:UIControlStateHighlighted];
        
        [stopButton setBackgroundImage:[[UIImage imageNamed:@"Stop_Button"]safeStretchableImageWithLeftCapWidth:10 topCapHeight:23] forState:UIControlStateNormal];
        [stopButton setBackgroundImage:[[UIImage imageNamed:@"Stop_Button-Selected"]safeStretchableImageWithLeftCapWidth:10 topCapHeight:23] forState:UIControlStateHighlighted];
        
        startButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
        startButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        startButton.titleLabel.layer.shadowOpacity = 1;
        startButton.titleLabel.layer.shadowOffset = CGSizeMake(0,0);
        startButton.titleLabel.layer.shadowRadius = 1;
        
        pauseButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
        pauseButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        pauseButton.titleLabel.layer.shadowOpacity = 1;
        pauseButton.titleLabel.layer.shadowOffset = CGSizeMake(0,0);
        pauseButton.titleLabel.layer.shadowRadius = 1;
        
        stopButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
        stopButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        stopButton.titleLabel.layer.shadowOpacity = 1;
        stopButton.titleLabel.layer.shadowOffset = CGSizeMake(0,0);
        stopButton.titleLabel.layer.shadowRadius = 1;
    }
    
    [self updateTimerState];
    [self updateTimeRemainingLabel];
    
    doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // This forces the duration to be a whole number in terms of minutes.
    NSInteger sleepTimerDuration = (((NSInteger)([[NSUserDefaults standardUserDefaults]integerForKey:kSleepTimerDurationKey] / 60.0)) * 60);
    if (sleepTimerDuration > 0) {
        timePicker.countDownDuration = sleepTimerDuration;
    }
    
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
}

- (void)updateTimerState {
    kTimerState timerState = [[Player sharedPlayer]timerState];
    if (timerState == kTimerStateStopped) {
        buttonBackgroundImageView.image = [[UIImage imageNamed:@"Start_Button_Background"]safeStretchableImageWithLeftCapWidth:160 topCapHeight:28];
        startButton.hidden = NO;
        pauseButton.hidden = YES;
        stopButton.hidden = YES;
        timeRemainingLabel.hidden = YES;
        timePicker.hidden = NO;
    }
    else {
        buttonBackgroundImageView.image = [[UIImage imageNamed:@"Pause_Stop_Button_Background"]safeStretchableImageWithLeftCapWidth:160 topCapHeight:28];
        
        if (timerState == kTimerStateRunning) {
            [pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        }
        else {
            [pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
        }
        
        startButton.hidden = YES;
        pauseButton.hidden = NO;
        stopButton.hidden = NO;
        timeRemainingLabel.hidden = NO;
        timePicker.hidden = YES;
    }
}

- (void)updateTimeRemainingLabel {
    timeRemainingLabel.text = [NSDateFormatter formattedDuration:[[Player sharedPlayer]sleepDelay]];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
