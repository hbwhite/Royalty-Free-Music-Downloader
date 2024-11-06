//
//  PlayerViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/26/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "PlayerViewController.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "PlayerState.h"
#import "AlbumFlipSideView.h"
#import "File.h"
#import "File+Extensions.h"
#import "Artist.h"
#import "Album.h"
#import "CoverflowViewController.h"
#import "OptionsActionSheetHandler.h"
#import "SleepTimerNavigationController.h"
#import "SkinManager.h"
#import "iOS6VolumeView.h"
#import "NSDateFormatter+Duration.h"
#import "UIViewController+NibSelect.h"
#import "UIViewController+SafeModal.h"
#import "UIImage+SafeStretchableImage.h"
#import "NSDateFormatter+Duration.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

static NSString *kPlayerViewShownKey    = @"Player View Shown";
static NSString *kRepeatModeKey         = @"Repeat Mode";
static NSString *kShuffleKey            = @"Shuffle";

// Deprecated as of version 1.1
// Lyrics can now be shown or hidden using the player controls through the "Lyrics Shown" key below.
// Continued use of this key could have caused problems if the overlay was previously hidden but lyrics were enabled.
// static NSString *kShowLyricsKey      = @"Show Lyrics";

static NSString *kSwipeGestureKey       = @"Swipe Gesture";
static NSString *kPlayerOverlayShownKey = @"Player Overlay Shown";
static NSString *kLyricsShownKey        = @"Lyrics Shown";

static NSString *kSlideAnimationKey     = @"Slide";

static NSString *kShareTextStr          = @"Share what you're listening to.";

@interface PlayerViewController ()

@property (nonatomic, strong) IBOutlet UILabel *artistLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *albumLabel;
@property (nonatomic, strong) IBOutlet UIView *albumFlipSideContainerView;
@property (nonatomic, strong) IBOutlet UIView *trackListButtonContainerView;
@property (nonatomic, strong) IBOutlet UIButton *trackListButton;
@property (nonatomic, strong) IBOutlet UIImageView *trackListBackgroundImageView;
@property (nonatomic, strong) IBOutlet UIView *albumArtworkThumbnailButtonContainerView;
@property (nonatomic, strong) IBOutlet UIButton *albumArtworkThumbnailButton;
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UILabel *trackNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *elapsedTimeLabel;
@property (nonatomic, strong) IBOutlet OBSlider *progressSlider;
@property (nonatomic, strong) IBOutlet UILabel *remainingTimeLabel;
@property (nonatomic, strong) IBOutlet UIButton *repeatButton;
@property (nonatomic, strong) IBOutlet UIButton *lyricsButton;
@property (nonatomic, strong) IBOutlet UIButton *sleepTimerButton;
@property (nonatomic, strong) IBOutlet UILabel *sleepTimerLabel;
@property (nonatomic, strong) IBOutlet UIButton *shuffleButton;
@property (nonatomic, strong) IBOutlet UILabel *scrobbleHelpLabel;
@property (nonatomic, strong) IBOutlet UIView *scrobbleOverlayView;
@property (nonatomic, strong) IBOutlet UIImageView *scrobbleOverlayImageView;
@property (nonatomic, strong) IBOutlet UIImageView *scrobbleHighlightShadowImageView;
@property (nonatomic, strong) IBOutlet UITextView *lyricsTextView;
@property (nonatomic, strong) IBOutlet UIImageView *playerControlsBackgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView *highlight1;
@property (nonatomic, strong) IBOutlet UIImageView *highlight2;
@property (nonatomic, strong) IBOutlet UIImageView *highlight3;
@property (nonatomic, strong) IBOutlet UIImageView *highlight4;
@property (nonatomic, strong) IBOutlet UIImageView *highlight5;
@property (nonatomic, strong) IBOutlet UIImageView *highlight6;
@property (nonatomic, strong) IBOutlet UIImageView *divider1;
@property (nonatomic, strong) IBOutlet UIImageView *divider2;
@property (nonatomic, strong) IBOutlet UIImageView *albumArtworkImageView;
@property (nonatomic, strong) IBOutlet UIImageView *albumArtworkReflectionImageView;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton *previousTrackButton;
@property (nonatomic, strong) IBOutlet UIButton *playPauseButton;
@property (nonatomic, strong) IBOutlet UIButton *nextTrackButton;
@property (nonatomic, strong) IBOutlet UIButton *actionButton;
@property (nonatomic, strong) AlbumFlipSideView *albumFlipSideView;
@property (readwrite) BOOL scrubbing;
@property (readwrite) BOOL canFlipAlbum;
@property (readwrite) BOOL animatingTrackChange;

- (IBAction)flipAlbum;
- (void)didFlipAlbum;
- (void)sliderDidBeginScrubbing;
- (void)stopScrubbing;
- (void)sliderValueChanged;
- (void)sliderDidEndScrubbing;
- (IBAction)repeatButtonPressed;
- (IBAction)lyricsButtonPressed;
- (IBAction)sleepTimerButtonPressed;
- (IBAction)shuffleButtonPressed;
- (IBAction)shareButtonPressed;
- (IBAction)actionButtonPressed;
- (IBAction)playPauseButtonPressed;
- (void)backButtonPressed;
- (void)skipToPreviousTrack;
- (void)skipToNextTrack;
- (void)transition:(BOOL)fromRight;
- (void)updateElapsedTime;
- (void)_updateElapsedTime;
- (void)albumDidChange;
- (void)setScrobbleActive:(BOOL)scrobbleActive;
- (void)updatePlaybackState;
- (void)_updatePlaybackState;
/*
- (void)adDidShow;
- (void)adDidHide;
*/
- (void)updateRepeatMode;
- (void)updateShuffleButton;
- (void)updateSleepTimerElements;
- (void)updateSleepTimerLabel;
- (void)interruptionBegan;
- (void)updatePlayerElements;
- (void)updateTrackNumberLabel;
- (void)updateTrackElements;
- (void)_updateTrackElements:(NSNumber *)didFinishEditingTags;
- (void)albumArtworkImageViewTapped;
- (void)albumArtworkImageViewSwipedLeft;
- (void)albumArtworkImageViewSwipedRight;
// - (void)updateFrames;

@end

@implementation PlayerViewController

// Private
@synthesize artistLabel;
@synthesize titleLabel;
@synthesize albumLabel;
@synthesize albumFlipSideContainerView;
@synthesize trackListButtonContainerView;
@synthesize trackListButton;
@synthesize trackListBackgroundImageView;
@synthesize albumArtworkThumbnailButtonContainerView;
@synthesize albumArtworkThumbnailButton;
@synthesize navigationBar;
@synthesize trackNumberLabel;
@synthesize elapsedTimeLabel;
@synthesize progressSlider;
@synthesize remainingTimeLabel;
@synthesize repeatButton;
@synthesize lyricsButton;
@synthesize sleepTimerButton;
@synthesize sleepTimerLabel;
@synthesize shuffleButton;
@synthesize scrobbleHelpLabel;
@synthesize scrobbleOverlayView;
@synthesize scrobbleOverlayImageView;
@synthesize scrobbleHighlightShadowImageView;
@synthesize lyricsTextView;
@synthesize playerControlsBackgroundImageView;
@synthesize highlight1;
@synthesize highlight2;
@synthesize highlight3;
@synthesize highlight4;
@synthesize highlight5;
@synthesize highlight6;
@synthesize divider1;
@synthesize divider2;
@synthesize albumArtworkImageView;
@synthesize albumArtworkReflectionImageView;
@synthesize shareButton;
@synthesize previousTrackButton;
@synthesize playPauseButton;
@synthesize nextTrackButton;
@synthesize actionButton;
@synthesize albumFlipSideView;
@synthesize scrubbing;
@synthesize canFlipAlbum;
@synthesize animatingTrackChange;

- (IBAction)flipAlbum {
    if (!flippingAlbum) {
        flippingAlbum = YES;
        
        BOOL shouldFlipToAlbumCover = [albumFlipSideContainerView.subviews containsObject:albumFlipSideView];
        
        if (!shouldFlipToAlbumCover) {
            CGRect frame = albumFlipSideContainerView.frame;
            frame.origin.y = 0;
            albumFlipSideView = [[AlbumFlipSideView alloc]initWithFrame:frame];
        }
        
        [UIView beginAnimations:@"Flip Album" context:nil];
        [UIView setAnimationDuration:0.75];
        [UIView setAnimationTransition:shouldFlipToAlbumCover ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight forView:albumFlipSideContainerView cache:YES];
        
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didFlipAlbum)];
        
        if (shouldFlipToAlbumCover) {
            [albumFlipSideView removeFromSuperview];
            
            // For some strange reason, the album flip side view isn't automatically deallocated properly, so it must be removed from its superview and set to nil.
            albumFlipSideView = nil;
        }
        else {
            [albumFlipSideContainerView addSubview:albumFlipSideView];
        }
        
        [UIView commitAnimations];
        
        [UIView beginAnimations:@"Flip Track List Button" context:nil];
        [UIView setAnimationDuration:0.75];
        [UIView setAnimationTransition:shouldFlipToAlbumCover ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight forView:trackListButton cache:YES];
        
        trackListButton.hidden = !shouldFlipToAlbumCover;
        
        [UIView commitAnimations];
        
        [UIView beginAnimations:@"Flip Album Artwork Thumbnail Button" context:nil];
        [UIView setAnimationDuration:0.75];
        [UIView setAnimationTransition:shouldFlipToAlbumCover ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight forView:albumArtworkThumbnailButtonContainerView cache:YES];
        
        albumArtworkThumbnailButtonContainerView.hidden = shouldFlipToAlbumCover;
        
        [UIView commitAnimations];
        
        [UIView beginAnimations:@"Fade Track List Background Image View" context:nil];
        [UIView setAnimationDuration:0.25];
        
        if (shouldFlipToAlbumCover) {
            [UIView setAnimationDelay:0.75];
            trackListBackgroundImageView.alpha = 0;
        }
        else {
            trackListBackgroundImageView.alpha = 1;
        }
        
        [UIView commitAnimations];
    }
}

- (void)didFlipAlbum {
    flippingAlbum = NO;
}

- (void)sliderDidBeginScrubbing {
    scrubbing = YES;
    [self setScrobbleActive:YES];
}

- (void)sliderValueChanged {
    CGFloat speed = progressSlider.scrubbingSpeed;
    if (speed == 1) {
        trackNumberLabel.text = @"Hi-Speed Scrubbing";
    }
    else if (speed == 0.5) {
        trackNumberLabel.text = @"Half-Speed Scrubbing";
    }
    else if (speed == 0.25) {
        trackNumberLabel.text = @"Quarter-Speed Scrubbing";
    }
    else {
        trackNumberLabel.text = @"Fine Scrubbing";
    }
    
    Player *player = [Player sharedPlayer];
    
    // Default to the music player's calculated duration.
    NSTimeInterval duration = [player duration];
    if ((isnan(duration)) || (duration <= 0)) {
        duration = [player.nowPlayingFile.duration doubleValue];
    }
    
    NSTimeInterval currentPlaybackTime = (duration * progressSlider.value);
    
    elapsedTimeLabel.text = [NSDateFormatter formattedDuration:(NSUInteger)currentPlaybackTime];
    remainingTimeLabel.text = [@"-" stringByAppendingString:[NSDateFormatter formattedDuration:((NSUInteger)duration - (NSUInteger)currentPlaybackTime)]];
}

- (void)sliderDidEndScrubbing {
    [self stopScrubbing];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)stopScrubbing {
    scrubbing = NO;
    [self setScrobbleActive:NO];
    [self updateTrackNumberLabel];
    
    Player *player = [Player sharedPlayer];
    
    // Default to the music player's calculated duration.
    NSTimeInterval duration = [player duration];
    if ((isnan(duration)) || (duration <= 0)) {
        duration = [player.nowPlayingFile.duration doubleValue];
    }
    
    [player setCurrentPlaybackTime:(progressSlider.value * duration)];
    
    [self _updateElapsedTime];
}

- (IBAction)repeatButtonPressed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger repeatMode = [defaults integerForKey:kRepeatModeKey];
    if (repeatMode < kRepeatModeOne) {
        repeatMode += 1;
    }
    else {
        repeatMode = kRepeatModeNone;
    }
    
    [defaults setInteger:repeatMode forKey:kRepeatModeKey];
    [defaults synchronize];
    
    [self updateRepeatMode];
}

- (IBAction)lyricsButtonPressed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL lyricsShown = ![defaults boolForKey:kLyricsShownKey];
    
    [defaults setBool:lyricsShown forKey:kLyricsShownKey];
    [defaults synchronize];
    
    lyricsTextView.hidden = !lyricsShown;
    if (lyricsTextView.hidden) {
        [lyricsButton setImage:[UIImage skinImageNamed:@"Lyrics"] forState:UIControlStateNormal];
    }
    else {
        [lyricsButton setImage:[UIImage skinImageNamed:@"Lyrics-Enabled"] forState:UIControlStateNormal];
    }
}

- (IBAction)sleepTimerButtonPressed {
    SleepTimerNavigationController *sleepTimerNavigationController = [[SleepTimerNavigationController alloc]init];
    
    TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
    
    // The delegate must be set to the RootViewController because this view may not exist if the player reaches the end of the playlist while the sleepTimerNavigationController is presented, causing the app to crash when the user presses the done button.
    sleepTimerNavigationController.sleepTimerNavigationControllerDelegate = tabBarController;
    
    [tabBarController safelyPresentModalViewController:sleepTimerNavigationController animated:YES completion:nil];
}

- (IBAction)shuffleButtonPressed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL shuffling = [defaults boolForKey:kShuffleKey];
    
    [defaults setBool:!shuffling forKey:kShuffleKey];
    [defaults synchronize];
    
    Player *player = [Player sharedPlayer];
    if (shuffling) {
        [player disableShuffle];
    }
    else {
        [player enableShuffle];
    }
    
    [self updateTrackNumberLabel];
    [self updateShuffleButton];
}

- (IBAction)shareButtonPressed {
    TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
    tabBarController.currentTrack = [[Player sharedPlayer]nowPlayingFile];
    
    if ((NSClassFromString(@"SLComposeViewController")) || (NSClassFromString(@"TWTweetComposeViewController"))) {
        if (NSClassFromString(@"SLComposeViewController")) {
            UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                        initWithTitle:kShareTextStr
                                                        delegate:tabBarController
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                        destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Facebook", @"Twitter", nil];
            sharingOptionsActionSheet.tag = 0;
            sharingOptionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [sharingOptionsActionSheet showFromRect:shareButton.frame inView:self.view animated:YES];
        }
        else {
            UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                        initWithTitle:kShareTextStr
                                                        delegate:tabBarController
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                        destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Twitter", nil];
            sharingOptionsActionSheet.tag = 1;
            sharingOptionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [sharingOptionsActionSheet showFromRect:shareButton.frame inView:self.view animated:YES];
        }
    }
    /*
    else if ([FBDialogs canPresentOSIntegratedShareDialogWithSession:nil]) {
        UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                    initWithTitle:kShareTextStr
                                                    delegate:tabBarController
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                    destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Facebook", nil];
        sharingOptionsActionSheet.tag = 2;
        sharingOptionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [sharingOptionsActionSheet showFromRect:shareButton.frame inView:self.view animated:YES];
    }
    */
}

- (IBAction)actionButtonPressed {
    File *file = [[Player sharedPlayer]nowPlayingFile];
    
    OptionsActionSheetHandler *handler = [OptionsActionSheetHandler sharedHandler];
    handler.delegate = nil;
    [handler presentOptionsActionSheetForFiles:[NSArray arrayWithObject:file] fileIndex:0 fromRect:actionButton.frame inView:self.view canDelete:YES];
}

- (IBAction)playPauseButtonPressed {
    [[Player sharedPlayer]togglePlaybackState];
}

- (void)backButtonPressed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kPlayerViewShownKey]) {
        [defaults setBool:NO forKey:kPlayerViewShownKey];
        [defaults synchronize];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)skipToPreviousTrack {
    [[Player sharedPlayer]skipToPreviousTrack];
}

- (void)skipToNextTrack {
    [[Player sharedPlayer]skipToNextTrack];
}

- (void)transition:(BOOL)fromRight {
    animatingTrackChange = YES;
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = fromRight ? kCATransitionFromRight : kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [transition setDelegate:self];
    [albumArtworkImageView.layer addAnimation:transition forKey:kSlideAnimationKey];
    [albumArtworkReflectionImageView.layer addAnimation:transition forKey:kSlideAnimationKey];
    [albumFlipSideView.layer addAnimation:transition forKey:kSlideAnimationKey];
    // I SUSPECT that this may be the cause of the elusive "Only run on the main thread!" error, where the animations handled by the above CATransition cause the UITextView to render in the background.
    // [lyricsTextView.layer addAnimation:transition forKey:kSlideAnimationKey];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    animatingTrackChange = NO;
}

// This prevents the UI from freezing when the user attempts to skip many different tracks at once.
- (BOOL)playerShouldChangeTrackManually {
    return !animatingTrackChange;
}

- (void)updateElapsedTime {
    [self performSelectorOnMainThread:@selector(_updateElapsedTime) withObject:nil waitUntilDone:NO];
}

- (void)_updateElapsedTime {
    Player *player = [Player sharedPlayer];
    File *nowPlayingFile = player.nowPlayingFile;
    if (nowPlayingFile) {
        if (!scrubbing) {
            NSTimeInterval currentPlaybackTime = [player currentPlaybackTime];
            
            // Default to the music player's calculated duration.
            NSTimeInterval duration = [player duration];
            if ((isnan(duration)) || (duration <= 0)) {
                duration = [player.nowPlayingFile.duration doubleValue];
            }
            
            if ((NSInteger)duration > 0) {
                progressSlider.value = (currentPlaybackTime / duration);
                elapsedTimeLabel.text = [NSDateFormatter formattedDuration:(NSUInteger)currentPlaybackTime];
                remainingTimeLabel.text = [@"-" stringByAppendingString:[NSDateFormatter formattedDuration:((NSUInteger)duration - (NSUInteger)currentPlaybackTime)]];
            }
            else {
                progressSlider.value = 0;
                elapsedTimeLabel.text = NSLocalizedString(@"UNKNOWN_DURATION", @"");
                remainingTimeLabel.text = NSLocalizedString(@"UNKNOWN_DURATION", @"");
            }
        }
    }
    else {
        progressSlider.value = 0;
        elapsedTimeLabel.text = NSLocalizedString(@"UNKNOWN_DURATION", @"");
        remainingTimeLabel.text = NSLocalizedString(@"UNKNOWN_DURATION", @"");
    }
}

- (void)albumDidChange {
    // By the time this switches to the main thread, the skippingToPreviousTrack variable could have changed, so it must be assigned immediately here.
    BOOL transitionFromRight = ![[Player sharedPlayer]skippingToPreviousTrack];
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [self transition:transitionFromRight];
    });
}

- (void)setScrobbleActive:(BOOL)scrobbleActive {
    CGFloat alpha = 0;
    if (scrobbleActive) {
        alpha = 1;
    }
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat universalButtonAlpha = (1 - alpha);
        
        repeatButton.alpha = universalButtonAlpha;
        lyricsButton.alpha = universalButtonAlpha;
        sleepTimerButton.alpha = universalButtonAlpha;
        sleepTimerLabel.alpha = universalButtonAlpha;
        shuffleButton.alpha = universalButtonAlpha;
        
        scrobbleHelpLabel.alpha = alpha;
        scrobbleHighlightShadowImageView.alpha = alpha;
    }];
}

- (void)updatePlaybackState {
    [self performSelectorOnMainThread:@selector(_updatePlaybackState) withObject:nil waitUntilDone:NO];
}

- (void)_updatePlaybackState {
    if ([[Player sharedPlayer]playing]) {
        [playPauseButton setImage:[UIImage skinImageNamed:@"Pause"] forState:UIControlStateNormal];
    }
    else {
        [playPauseButton setImage:[UIImage skinImageNamed:@"Play"] forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // This is necessary for the view to be laid out correctly on iOS 7.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(updateTrackElements) name:kPlayerNowPlayingFileDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updatePlaybackState) name:kPlayerPlaybackStateDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateElapsedTime) name:kPlayerCurrentPlaybackTimeDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(albumDidChange) name:kPlayerAlbumDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateShuffleButton) name:kPlayerDidShuffleNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(interruptionBegan) name:kPlayerInterruptionBeganNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateSleepTimerElements) name:kPlayerSleepTimerStateDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateSleepTimerLabel) name:kPlayerSleepTimerDelayDidChangeNotification object:nil];
    
    // For some reason, notifications are sometimes sent to the PlayerViewController even though the observer has been removed in NSNotificationCenter, causing the deallocated lyricsTextView to be accessed and, in turn, crashing the app. Because this seems to be a system problem, I have disabled this code here.
    /*
    [notificationCenter addObserver:self selector:@selector(adDidShow) name:kAdDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(adDidHide) name:kAdDidHideNotification object:nil];
    */
    
    [[Player sharedPlayer]setDelegate:self];
    
    BOOL iOS6Skin = [SkinManager iOS6Skin];
    
    if (iOS6Skin) {
        highlight1.hidden = NO;
        highlight2.hidden = NO;
        highlight3.hidden = NO;
        highlight4.hidden = NO;
        highlight5.hidden = NO;
        highlight6.hidden = NO;
        divider1.hidden = NO;
        divider2.hidden = NO;
        
        CGRect universalFrame = CGRectMake(0, 0, 34, 30);
        trackListButtonContainerView.frame = universalFrame;
        trackListBackgroundImageView.frame = universalFrame;
        trackListButton.frame = universalFrame;
        albumArtworkThumbnailButtonContainerView.frame = universalFrame;
        
        albumArtworkThumbnailButton.imageView.contentMode = UIViewContentModeScaleToFill;
        albumArtworkThumbnailButton.frame = CGRectMake(0, 1, 34, 28);
        
        UIColor *timeLabelTextColor = [UIColor colorWithWhite:(173.0 / 255.0) alpha:1];
        elapsedTimeLabel.textColor = timeLabelTextColor;
        remainingTimeLabel.textColor = timeLabelTextColor;
        
        UIColor *textLabelTextColor = [UIColor colorWithWhite:(193.0 / 255.0) alpha:1];
        trackNumberLabel.textColor = textLabelTextColor;
        scrobbleHelpLabel.textColor = textLabelTextColor;
        
        [navigationBar setBackgroundImage:[UIImage skinImageNamed:@"Player_Navigation_Bar_Background"] forBarMetrics:UIBarMetricsDefault];
    }
    else {
        // This fixes a strange problem that can occur on older devices (such as the iPhone 3GS) where the text color of UILabels is initially black instead of white.
        elapsedTimeLabel.textColor = [UIColor whiteColor];
        remainingTimeLabel.textColor = [UIColor whiteColor];
        trackNumberLabel.textColor = [UIColor whiteColor];
        scrobbleHelpLabel.textColor = [UIColor whiteColor];
    }
    
    scrobbleOverlayImageView.image = [UIImage skinImageNamed:@"shadow"];
    playerControlsBackgroundImageView.image = [UIImage skinImageNamed:@"Player_Controls_Background"];
    
    [trackListButton setImage:[UIImage skinImageNamed:@"Track_List"] forState:UIControlStateNormal];
    
    if ([SkinManager iOS7Skin]) {
        // The iOS 7 skin doesn't have a track list background image.
        trackListBackgroundImageView.image = nil;
    }
    else {
        trackListBackgroundImageView.image = [UIImage skinImageNamed:@"Track_List_Background"];
    }
    
    [sleepTimerButton setImage:[UIImage skinImageNamed:@"Sleep_Timer"] forState:UIControlStateNormal];
    [shareButton setImage:[UIImage skinImageNamed:@"Share-Player"] forState:UIControlStateNormal];
    [previousTrackButton setImage:[UIImage skinImageNamed:@"Previous"] forState:UIControlStateNormal];
    [nextTrackButton setImage:[UIImage skinImageNamed:@"Next"] forState:UIControlStateNormal];
    [actionButton setImage:[UIImage skinImageNamed:@"Action-Player"] forState:UIControlStateNormal];
    
    if ([SkinManager iOS7Skin]) {
        albumArtworkReflectionImageView.hidden = YES;
        playerControlsBackgroundImageView.alpha = 0.75;
    }
    else {
        [progressSlider setMinimumTrackImage:[[UIImage skinImageNamed:@"Track-Minimum"]safeStretchableImageWithLeftCapWidth:5 topCapHeight:4] forState:UIControlStateNormal];
        [progressSlider setMaximumTrackImage:[[UIImage skinImageNamed:@"Track-Maximum"]safeStretchableImageWithLeftCapWidth:5 topCapHeight:4] forState:UIControlStateNormal];
    }
    
    [progressSlider setThumbImage:[UIImage skinImageNamed:@"Scrubber_Knob"] forState:UIControlStateNormal];
    [progressSlider setThumbImage:[UIImage skinImageNamed:@"Scrubber_Knob"] forState:UIControlStateHighlighted];
    
    progressSlider.delegate = self;
    [progressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *albumArtworkDoubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(flipAlbum)];
    albumArtworkDoubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [albumArtworkImageView addGestureRecognizer:albumArtworkDoubleTapGestureRecognizer];
    
    UITapGestureRecognizer *lyricsTextViewDoubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(flipAlbum)];
    lyricsTextViewDoubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [lyricsTextView addGestureRecognizer:lyricsTextViewDoubleTapGestureRecognizer];
    
    UITapGestureRecognizer *albumArtworkTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(albumArtworkImageViewTapped)];
    [albumArtworkTapGestureRecognizer requireGestureRecognizerToFail:albumArtworkDoubleTapGestureRecognizer];
    [albumArtworkImageView addGestureRecognizer:albumArtworkTapGestureRecognizer];
    
    /*
    UITapGestureRecognizer *lyricsTextViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(albumArtworkImageViewTapped)];
    [lyricsTextViewTapGestureRecognizer requireGestureRecognizerToFail:lyricsTextViewDoubleTapGestureRecognizer];
    [lyricsTextView addGestureRecognizer:lyricsTextViewTapGestureRecognizer];
    */
    
    UISwipeGestureRecognizer *albumArtworkLeftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(albumArtworkImageViewSwipedLeft)];
    albumArtworkLeftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [albumArtworkImageView addGestureRecognizer:albumArtworkLeftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *lyricsTextViewLeftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(albumArtworkImageViewSwipedLeft)];
    lyricsTextViewLeftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [lyricsTextView addGestureRecognizer:lyricsTextViewLeftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *albumArtworkRightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(albumArtworkImageViewSwipedRight)];
    albumArtworkRightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [albumArtworkImageView addGestureRecognizer:albumArtworkRightSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *lyricsTextViewRightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(albumArtworkImageViewSwipedRight)];
    lyricsTextViewRightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [lyricsTextView addGestureRecognizer:lyricsTextViewRightSwipeGestureRecognizer];
    
    UITapGestureRecognizer *previousTrackButtonTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(skipToPreviousTrack)];
    [previousTrackButton addGestureRecognizer:previousTrackButtonTapGestureRecognizer];
    
    UITapGestureRecognizer *nextTrackButtonTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(skipToNextTrack)];
    [nextTrackButton addGestureRecognizer:nextTrackButtonTapGestureRecognizer];
    
    artistLabel.textAlignment = UITextAlignmentCenter;
    artistLabel.shadowColor = [UIColor blackColor];
    artistLabel.shadowOffset = CGSizeMake(0, -1);
    artistLabel.font = [UIFont boldSystemFontOfSize:12];
    
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:12];
    
    albumLabel.textAlignment = UITextAlignmentCenter;
    albumLabel.shadowColor = [UIColor blackColor];
    albumLabel.shadowOffset = CGSizeMake(0, -1);
    albumLabel.font = [UIFont boldSystemFontOfSize:12];
    
    if (iOS6Skin) {
        UIColor *detailLabelTextColor = [UIColor colorWithWhite:(159.0 / 255.0) alpha:1];
        artistLabel.textColor = detailLabelTextColor;
        titleLabel.textColor = [UIColor whiteColor];
        albumLabel.textColor = detailLabelTextColor;
        
        sleepTimerLabel.textColor = [UIColor orangeColor];
    }
    else {
        artistLabel.textColor = [UIColor lightTextColor];
        titleLabel.textColor = [UIColor whiteColor];
        albumLabel.textColor = [UIColor lightTextColor];
        
        if ([SkinManager iOS7Skin]) {
            sleepTimerLabel.textColor = [SkinManager iOS7SkinBlueColor];
        }
        else {
            sleepTimerLabel.textColor = [UIColor whiteColor];
        }
    }
    
    UIButton *backContentButton = nil;
    if (iOS6Skin) {
        backContentButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 30)];
        [backContentButton setImage:[UIImage imageNamed:@"Back-6"] forState:UIControlStateNormal];
    }
    else {
        backContentButton = [[UIButton alloc]init];
        
        if ([SkinManager iOS7Skin]) {
            // The iOS 7 back button image is 12 pixels wide, but setting the back content button width to 12 pixels would make it difficult to press.
            // Setting the back content button width to 30 resolves the aforementioned problem and centers the text in the navigation bar.
            backContentButton.frame = CGRectMake(0, 0, 30, 20);
            [backContentButton setImage:[UIImage imageNamed:@"Back-7"] forState:UIControlStateNormal];
        }
        else {
            backContentButton.frame = CGRectMake(0, 0, 42, 30);
            
            [backContentButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
            
            // The iOS 6 skin doesn't have a selected back button image.
            [backContentButton setImage:[UIImage imageNamed:@"Back-Selected"] forState:UIControlStateHighlighted];
        }
    }
    
    [backContentButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithCustomView:backContentButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    albumArtworkThumbnailButton.imageView.backgroundColor = [UIColor blackColor];
    if (!iOS6Skin) {
        albumArtworkThumbnailButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    albumArtworkReflectionImageView.transform = CGAffineTransformScale(albumArtworkReflectionImageView.transform, 1, -1);
    
    CAGradientLayer *reflectionFadeLayer = [CAGradientLayer layer];
    reflectionFadeLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0 alpha:1].CGColor, nil];
    reflectionFadeLayer.startPoint = CGPointMake(0, 1);
    reflectionFadeLayer.endPoint = CGPointMake(0, 0.6);
    reflectionFadeLayer.frame = CGRectMake(0, 0, albumArtworkReflectionImageView.frame.size.width, albumArtworkReflectionImageView.frame.size.height);
    [albumArtworkReflectionImageView.layer addSublayer:reflectionFadeLayer];
    
    // MPVolumeView can only be customized on devices running iOS 6 or later.
    if ((iOS6Skin) && ([[[UIDevice currentDevice]systemVersion]compare:@"6.0"] != NSOrderedAscending)) {
        iOS6VolumeView *volumeView = [[iOS6VolumeView alloc]initWithFrame:CGRectMake(((self.view.frame.size.width - 228) / 2.0), (self.view.frame.size.height - 34), 228, 23)];
        volumeView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
        
        [volumeView setMinimumVolumeSliderImage:[[UIImage imageNamed:@"Volume_Track-Minimum-6"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:5] forState:UIControlStateNormal];
        [volumeView setMaximumVolumeSliderImage:[[UIImage imageNamed:@"Volume_Track-Maximum-6"]safeStretchableImageWithLeftCapWidth:8 topCapHeight:5] forState:UIControlStateNormal];
        [volumeView setVolumeThumbImage:[UIImage imageNamed:@"Volume_Knob-6"] forState:UIControlStateNormal];
        [volumeView setRouteButtonImage:[UIImage imageNamed:@"AirPlay_Disabled-6"] forState:UIControlStateNormal];
        [volumeView setRouteButtonImage:[UIImage imageNamed:@"AirPlay_Enabled-6"] forState:UIControlStateSelected];
        
        [self.view addSubview:volumeView];
    }
    else {
        MPVolumeView *volumeView = [[MPVolumeView alloc]initWithFrame:CGRectMake(((self.view.frame.size.width - 274) / 2.0), (self.view.frame.size.height - 36), 274, 23)];
        volumeView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
        
        if (![SkinManager iOS7Skin]) {
            if ([volumeView respondsToSelector:@selector(setMinimumVolumeSliderImage:forState:)]) {
                [volumeView setMinimumVolumeSliderImage:[[UIImage imageNamed:@"Track-Minimum"]safeStretchableImageWithLeftCapWidth:5 topCapHeight:4] forState:UIControlStateNormal];
            }
            if ([volumeView respondsToSelector:@selector(setMaximumVolumeSliderImage:forState:)]) {
                [volumeView setMaximumVolumeSliderImage:[[UIImage imageNamed:@"Track-Maximum"]safeStretchableImageWithLeftCapWidth:5 topCapHeight:4] forState:UIControlStateNormal];
            }
            if ([volumeView respondsToSelector:@selector(setVolumeThumbImage:forState:)]) {
                [volumeView setVolumeThumbImage:[UIImage imageNamed:@"Volume_Knob"] forState:UIControlStateNormal];
            }
        }
        
        [self.view addSubview:volumeView];
    }
    
    [self updatePlayerElements];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // The scrobble overlay view is always present on devices with retina displays, and should always be present on iPads because they do not share screen space with other objects.
    if ([[UIScreen mainScreen]bounds].size.height == 480) {
        scrobbleOverlayView.hidden = ![defaults boolForKey:kPlayerOverlayShownKey];
    }
    
    lyricsTextView.hidden = ![defaults boolForKey:kLyricsShownKey];
    if (lyricsTextView.hidden) {
        [lyricsButton setImage:[UIImage skinImageNamed:@"Lyrics"] forState:UIControlStateNormal];
    }
    else {
        [lyricsButton setImage:[UIImage skinImageNamed:@"Lyrics-Enabled"] forState:UIControlStateNormal];
    }
    
    [self updateSleepTimerElements];
}

// For some reason, notifications are sometimes sent to the PlayerViewController even though the observer has been removed in NSNotificationCenter, causing the deallocated lyricsTextView to be accessed and, in turn, crashing the app. Because this seems to be a system problem, I have disabled this code here.
/*
- (void)adDidShow {
    lyricsTextView.frame = CGRectMake(0, scrobbleOverlayView.frame.size.height, self.view.frame.size.width, (self.view.frame.size.height - (scrobbleOverlayView.frame.size.height + 96 + [[[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewContainer]frame].size.height)));
}

- (void)adDidHide {
    lyricsTextView.frame = CGRectMake(0, scrobbleOverlayView.frame.size.height, self.view.frame.size.width, (self.view.frame.size.height - (scrobbleOverlayView.frame.size.height + 96)));
}
*/

- (void)updateRepeatMode {
    switch ([[NSUserDefaults standardUserDefaults]integerForKey:kRepeatModeKey]) {
        case kRepeatModeNone:
            [repeatButton setImage:[UIImage skinImageNamed:@"Repeat_Disabled"] forState:UIControlStateNormal];
            break;
        case kRepeatModeAll:
            [repeatButton setImage:[UIImage skinImageNamed:@"Repeat_All"] forState:UIControlStateNormal];
            break;
        case kRepeatModeOne:
            [repeatButton setImage:[UIImage skinImageNamed:@"Repeat_One"] forState:UIControlStateNormal];
            break;
    }
}

- (void)updateShuffleButton {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kShuffleKey]) {
        [shuffleButton setImage:[UIImage skinImageNamed:@"Shuffle_Enabled"] forState:UIControlStateNormal];
    }
    else {
        [shuffleButton setImage:[UIImage skinImageNamed:@"Shuffle_Disabled"] forState:UIControlStateNormal];
    }
}

- (void)updateSleepTimerElements {
    if ([[Player sharedPlayer]timerState] == kTimerStateStopped) {
        [sleepTimerButton setImage:[UIImage skinImageNamed:@"Sleep_Timer"] forState:UIControlStateNormal];
        sleepTimerLabel.hidden = YES;
    }
    else {
        [sleepTimerButton setImage:[UIImage skinImageNamed:@"Sleep_Timer-Enabled"] forState:UIControlStateNormal];
        [self updateSleepTimerLabel];
        sleepTimerLabel.hidden = NO;
    }
}

- (void)updateSleepTimerLabel {
    sleepTimerLabel.text = [NSDateFormatter formattedDuration:[[Player sharedPlayer]sleepDelay]];
}

- (void)interruptionBegan {
    if (scrubbing) {
        [progressSlider stopScrubbing];
        [self stopScrubbing];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:kPlayerViewShownKey]) {
        [defaults setBool:YES forKey:kPlayerViewShownKey];
        [defaults synchronize];
    }
    
    if ([SkinManager iOS7]) {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    else {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    }
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    self.navigationItem.titleView = navigationBar.topItem.titleView;
    self.navigationItem.rightBarButtonItem = navigationBar.topItem.rightBarButtonItem;
    
    if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage skinImageNamed:@"Player_Navigation_Bar_Background"] forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    }
    
    TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
    tabBarController.bottomBar = kBottomBarPlayerControls;
    [tabBarController updateBannerViewFrames:YES];
    
    // [self updateFrames];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    /*
    // For some reason, elements don't always display properly if they are updated when -viewWillAppear: is called, so they have to be updated here instead.
    [self updateFrames];
    */
    
    // Sometimes the light navigation bar color can persist, so it is set again here.
    if (([SkinManager iOS6Skin]) || ([SkinManager iOS7Skin])) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage skinImageNamed:@"Player_Navigation_Bar_Background"] forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ((![self.tabBarController safeModalViewController]) || (![[self.tabBarController safeModalViewController]isKindOfClass:[CoverflowViewController class]])) {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
    
    if (![self safeModalViewController]) {
        if ([SkinManager iOS6Skin]) {
            [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"Navigation_Bar_Background-6"]safeStretchableImageWithLeftCapWidth:0 topCapHeight:22] forBarMetrics:UIBarMetricsDefault];
        }
        else if ([SkinManager iOS7Skin]) {
            // This is unreliable and can cause the navigation bar to remain black.
            // [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Transparency"] forBarMetrics:UIBarMetricsDefault];
        }
        else {
            [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        }
    }
    
    // For some strange reason, the album flip side view isn't automatically deallocated properly, so it must be removed from its superview and set to nil if applicable.
    if ([albumFlipSideContainerView.subviews containsObject:albumFlipSideView]) {
        [self flipAlbum];
    }
    
    TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
    tabBarController.bottomBar = kBottomBarTabBar;
    [tabBarController updateBannerViewFrames:YES];
    [super viewWillDisappear:animated];
}

- (void)updatePlayerElements {
    [self _updateTrackElements:[NSNumber numberWithBool:NO]];
    [self _updateElapsedTime];
    [self updateRepeatMode];
    [self updateShuffleButton];
    [self _updatePlaybackState];
}

- (void)updateTrackNumberLabel {
    if ([[Player sharedPlayer]nowPlayingFile]) {
        Player *player = [Player sharedPlayer];
        trackNumberLabel.text = [NSString stringWithFormat:@"%i of %i", ([player playlistIndex] + 1), [player playlistCount]];
    }
    else {
        trackNumberLabel.text = nil;
    }
}

- (void)didFinishEditingTags {
    [self _updateTrackElements:[NSNumber numberWithBool:YES]];
}

- (void)updateTrackElements {
    [self performSelectorOnMainThread:@selector(_updateTrackElements:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
}

- (void)_updateTrackElements:(NSNumber *)didFinishEditingTags {
    File *nowPlayingFile = [[Player sharedPlayer]nowPlayingFile];
    
    if (![didFinishEditingTags boolValue]) {
        if (nowPlayingFile) {
            if ((NSClassFromString(@"SLComposeViewController")) || (NSClassFromString(@"TWTweetComposeViewController")) /* || ([FBDialogs canPresentOSIntegratedShareDialogWithSession:nil]) */) {
                shareButton.hidden = NO;
            }
            
            if ([nowPlayingFile.iPodMusicLibraryFile boolValue]) {
                actionButton.hidden = YES;
            }
            else {
                actionButton.hidden = NO;
            }
        }
        else {
            shareButton.hidden = YES;
            actionButton.hidden = YES;
        }
    }
    
    [albumArtworkThumbnailButton setImage:[nowPlayingFile thumbnail] forState:UIControlStateNormal];
    
    titleLabel.text = nowPlayingFile.title;
    
    // The song's individual artist should be shown regardless of how the songs are grouped, so the artistRefForArtistGroup variable is always used.
    artistLabel.text = nowPlayingFile.artistRefForArtistGroup.name;
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        albumLabel.text = nowPlayingFile.albumRefForAlbumArtistGroup.name;
    }
    else {
        albumLabel.text = nowPlayingFile.albumRefForArtistGroup.name;
    }
    
    [self updateTrackNumberLabel];
    
    if (![didFinishEditingTags boolValue]) {
        [self _updateElapsedTime];
    }
    
    if ([[nowPlayingFile.lyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0) {
        // Because the lyrics text view frame isn't adjusted for the presence or absence of banner ads, there must be a margin at the bottom in case there is a banner ad (which would otherwise obscure the lyrics).
        lyricsTextView.text = [nowPlayingFile.lyrics stringByAppendingString:@"\n\n\n"];
    }
    else {
        if (nowPlayingFile) {
            if ([nowPlayingFile.iPodMusicLibraryFile boolValue]) {
                lyricsTextView.text = @"No Lyrics\n\nYou can add lyrics to this song by using iTunes on your computer.";
            }
            else {
                lyricsTextView.text = @"No Lyrics\n\nYou can add lyrics to this song by pressing the button in the lower-right corner of the screen and selecting \"Edit Tags\" from the menu.";
            }
        }
        else {
            lyricsTextView.text = @"No Lyrics\n\nNothing is currently playing.";
        }
    }
    
    if (nowPlayingFile) {
        albumArtworkImageView.image = [nowPlayingFile artwork];
    }
    else {
        albumArtworkImageView.image = [UIImage iOS6SkinImageNamed:@"Missing_Album_Artwork"];
    }
    albumArtworkReflectionImageView.image = albumArtworkImageView.image;
}

- (void)albumArtworkImageViewTapped {
    // Animation has been disabled because it takes too long to set the alpha after the tap gesture recognizers delay the tap action to confirm that it wasn't a double tap.
    // The scrobble overlay view is always present on devices with retina displays, and should always be present on iPads because they do not share screen space with other objects.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[UIScreen mainScreen]bounds].size.height == 480) {
        scrobbleOverlayView.hidden = !scrobbleOverlayView.hidden;
        
        [defaults setBool:!scrobbleOverlayView.hidden forKey:kPlayerOverlayShownKey];
        [defaults synchronize];
    }
}

- (void)albumArtworkImageViewSwipedLeft {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kSwipeGestureKey]) {
        [self skipToNextTrack];
    }
}

- (void)albumArtworkImageViewSwipedRight {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kSwipeGestureKey]) {
        [self skipToPreviousTrack];
    }
}

// For some reason, notifications are sometimes sent to the PlayerViewController even though the observer has been removed in NSNotificationCenter, causing the deallocated lyricsTextView to be accessed and, in turn, crashing the app. Because this seems to be a system problem, I have disabled this code here.
/*
- (void)updateFrames {
    if ([[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewShown]) {
        [self adDidShow];
    }
    else {
        [self adDidHide];
    }
}
*/

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (albumFlipSideView) {
        albumFlipSideView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - navigationBar.frame.size.height));
    }
    
    // [self updateFrames];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[Player sharedPlayer]setDelegate:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
