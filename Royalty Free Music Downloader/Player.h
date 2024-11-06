//
//  Player.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/26/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define kPlayerNowPlayingFileDidChangeNotification      @"Now Playing File Did Change"
#define kPlayerPlaybackStateDidChangeNotification       @"Playback State Did Change"
#define kPlayerCurrentPlaybackTimeDidChangeNotification @"Current Playback Time Did Change"
#define kPlayerAlbumDidChangeNotification               @"Album Did Change"
#define kPlayerDidShuffleNotification                   @"Player Did Shuffle"
#define kPlayerInterruptionBeganNotification            @"Player Interruption Began"
#define kPlayerSleepTimerStateDidChangeNotification     @"Player Sleep Timer State Did Change"
#define kPlayerSleepTimerDelayDidChangeNotification     @"Player Sleep Timer Delay Did Change"

@class File;
@class PlayerState;

@protocol PlayerDelegate;

enum {
    kTimerStateStopped = 0,
    kTimerStateRunning,
    kTimerStatePaused
};
typedef NSUInteger kTimerState;

@interface Player : NSObject <NSFetchedResultsControllerDelegate, AVAudioSessionDelegate, AVAudioPlayerDelegate> {
@public
    id <PlayerDelegate> __unsafe_unretained delegate;
    AVPlayer *musicPlayer;
    File *nowPlayingFile;
    NSTimer *sleepTimer;
    NSInteger sleepDelay;
    kTimerState timerState;
    BOOL skippingToPreviousTrack;
    BOOL playing;
@private
    NSFetchedResultsController *songsFetchedResultsController;
    NSFetchedResultsController *playerStateFetchedResultsController;
    NSTimer *playbackTimer;
    NSTimeInterval seekPlaybackTime;
    BOOL didRestorePlaybackTime;
    BOOL seeking;
}

@property (nonatomic, unsafe_unretained) id <PlayerDelegate> delegate;
@property (nonatomic, strong) AVPlayer *musicPlayer;
@property (nonatomic, strong) File *nowPlayingFile;
@property (nonatomic, strong) NSTimer *sleepTimer;
@property (nonatomic) NSInteger sleepDelay;
@property (nonatomic) kTimerState timerState;
@property (readwrite) BOOL skippingToPreviousTrack;
@property (readwrite) BOOL playing;

+ (Player *)sharedPlayer;
- (PlayerState *)playerState;
- (void)updateURLForFileWithNewURL:(NSURL *)newURL previousURL:(NSURL *)previousURL;
- (void)setPlaylistItems:(NSArray *)playlistItems;
- (NSInteger)playlistIndex;
- (NSInteger)playlistCount;
- (NSTimeInterval)currentPlaybackTime;
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime;
- (NSTimeInterval)duration;
- (void)updateNowPlayingInfo;
- (void)shuffle;
- (void)enableShuffle;
- (void)disableShuffle;
- (void)setCurrentFileWithIndex:(NSInteger)index;
- (void)togglePlaybackState;
- (void)play;
- (void)pause;
- (void)skipToPreviousTrack;
- (void)skipToNextTrack;
- (void)stop;
- (void)initializeSleepTimer;
- (void)pauseSleepTimer;
- (void)stopSleepTimer;

@end

@protocol PlayerDelegate <NSObject>

@optional
- (BOOL)playerShouldChangeTrackManually;

@end
