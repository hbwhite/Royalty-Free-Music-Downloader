//
//  PlayerViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/26/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import "Player.h"
#import "OBSlider.h"

enum {
    kRepeatModeNone = 0,
    kRepeatModeAll  = 1,
    kRepeatModeOne  = 2
};
typedef NSUInteger kRepeatMode;

@class AlbumFlipSideView;
@class OBSlider;

@interface PlayerViewController : UIViewController <PlayerDelegate, OBSliderDelegate> {
@private
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *albumLabel;
    IBOutlet UIView *albumFlipSideContainerView;
    IBOutlet UIView *trackListButtonContainerView;
    IBOutlet UIButton *trackListButton;
    IBOutlet UIImageView *trackListBackgroundImageView;
    IBOutlet UIView *albumArtworkThumbnailButtonContainerView;
    IBOutlet UIButton *albumArtworkThumbnailButton;
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UILabel *trackNumberLabel;
    IBOutlet UILabel *elapsedTimeLabel;
    IBOutlet OBSlider *progressSlider;
    IBOutlet UILabel *remainingTimeLabel;
    IBOutlet UIButton *repeatButton;
    IBOutlet UIButton *lyricsButton;
    IBOutlet UIButton *sleepTimerButton;
    IBOutlet UILabel *sleepTimerLabel;
    IBOutlet UIButton *shuffleButton;
    IBOutlet UILabel *scrobbleHelpLabel;
    IBOutlet UIView *scrobbleOverlayView;
    IBOutlet UIImageView *scrobbleOverlayImageView;
    IBOutlet UIImageView *scrobbleHighlightShadowImageView;
    IBOutlet UITextView *lyricsTextView;
    IBOutlet UIImageView *playerControlsBackgroundImageView;
    IBOutlet UIImageView *highlight1;
    IBOutlet UIImageView *highlight2;
    IBOutlet UIImageView *highlight3;
    IBOutlet UIImageView *highlight4;
    IBOutlet UIImageView *highlight5;
    IBOutlet UIImageView *highlight6;
    IBOutlet UIImageView *divider1;
    IBOutlet UIImageView *divider2;
    IBOutlet UIImageView *albumArtworkImageView;
    IBOutlet UIImageView *albumArtworkReflectionImageView;
    IBOutlet UIButton *shareButton;
    IBOutlet UIButton *previousTrackButton;
    IBOutlet UIButton *playPauseButton;
    IBOutlet UIButton *nextTrackButton;
    IBOutlet UIButton *actionButton;
    AlbumFlipSideView *albumFlipSideView;
    BOOL scrubbing;
    BOOL flippingAlbum;
    BOOL animatingTrackChange;
}

- (void)didFinishEditingTags;

@end
