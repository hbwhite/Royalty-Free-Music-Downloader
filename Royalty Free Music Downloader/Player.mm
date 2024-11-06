//
//  Player.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/26/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "Player.h"
#import "File.h"
#import "File+Extensions.h"
#import "Album.h"
#import "Artist.h"
#import "Genre.h"
#import "PlayerState.h"
#import "SettingsViewController.h"
#import "PlayerViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "NSArray+Shuffle.h"

static Player *sharedPlayer = nil;

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";
static NSString *kRepeatModeKey         = @"Repeat Mode";
static NSString *kShuffleKey            = @"Shuffle";

static NSString *kSavePlaybackTimeKey   = @"Save Playback Time";

void audioRouteDidChange(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData);

@interface Player ()

@property (nonatomic, strong) NSFetchedResultsController *songsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *playerStateFetchedResultsController;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic) NSTimeInterval seekPlaybackTime;
@property (readwrite) BOOL didRestorePlaybackTime;
@property (readwrite) BOOL seeking;

- (void)restorePreviousState;
- (PlayerState *)playerState;
- (NSArray *)currentPlaylist;
- (NSArray *)playlist;
- (NSArray *)shufflePlaylist;
- (void)_musicPlayerPlaybackDidFinish;
- (BOOL)updateNowPlayingFile:(BOOL)isInitialSetup;
- (void)updateNowPlayingInfo;
- (void)audioSessionInterruptionDidOccur:(NSNotification *)notification;
- (void)audioSessionRouteDidChange:(NSNotification *)notification;
- (void)startMusicPlayer;
- (void)pauseMusicPlayer;
- (void)stopMusicPlayer;
- (void)stopPlaybackTimer;
- (void)updateCurrentPlaybackTime;
- (void)playNextTrack:(BOOL)wasPlaying;
- (BOOL)playRandomTrack;
- (void)decrementSleepDelay;
- (File *)fileForURLWithAbsoluteString:(NSString *)url;
- (NSFetchedResultsController *)songsFetchedResultsController;
- (NSFetchedResultsController *)playerStateFetchedResultsController;

@end

@implementation Player

// Public
@synthesize delegate;
@synthesize musicPlayer;
@synthesize nowPlayingFile;
@synthesize sleepTimer;
@synthesize sleepDelay;
@synthesize timerState;
@synthesize skippingToPreviousTrack;
@synthesize playing;

// Private
@synthesize songsFetchedResultsController;
@synthesize playerStateFetchedResultsController;
@synthesize playbackTimer;
@synthesize seekPlaybackTime;
@synthesize didRestorePlaybackTime;
@synthesize seeking;

+ (Player *)sharedPlayer {
    @synchronized(sharedPlayer) {
        if (!sharedPlayer) {
            sharedPlayer = [[Player alloc]init];
            
            // Code in the -restorePreviousState function posts notifications using NSNotificationCenter, which refer back to +sharedPlayer.
            // Calling -restorePreviousState here eliminates the need to call it in -init, which would cause an infinite loop when the notifications refer back to +sharedPlayer, which in turn calls -init.
            [sharedPlayer restorePreviousState];
        }
        return sharedPlayer;
    }
}

- (void)restorePreviousState {
    musicPlayer = [[AVPlayer alloc]init];
    
    NSArray *currentPlaylist = [self currentPlaylist];
    NSInteger index = [self playlistIndex];
    if ([currentPlaylist count] > index) {
        if ([self updateNowPlayingFile:YES]) {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kSavePlaybackTimeKey]) {
                // The current playback time cannot be set until the duration has been calculated.
                NSTimeInterval playbackTime = [[[self playerState]playbackTime]doubleValue];
                if (playbackTime > 0) {
                    [musicPlayer seekToTime:CMTimeMakeWithSeconds(playbackTime, 1)];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerCurrentPlaybackTimeDidChangeNotification object:nil];
                    
                    // In case the app is unable to save the playback time when it is terminated, the player will start at the beginning of the last song.
                    [[self playerState]setPlaybackTime:[NSNumber numberWithDouble:0]];
                    [[DataManager sharedDataManager]saveContext];
                }
            }
        }
        else {
            // If the app is unable to load the now playing file, the saved duration will become invalid, so it will be cleared here.
            [[self playerState]setPlaybackTime:[NSNumber numberWithInteger:0]];
            [[DataManager sharedDataManager]saveContext];
        }
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(musicPlayerPlaybackDidFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // The delegate property of AVAudioSession is deprecated in iOS 6, which uses AVAudioSessionInterruptionNotification instead.
    // This conditional is required because AVAudioSessionInterruptionNotification is only available in iOS 6 or later.
    if ([[[UIDevice currentDevice]systemVersion]compare:@"6.0"] != NSOrderedAscending) {
        [notificationCenter addObserver:self selector:@selector(audioSessionInterruptionDidOccur:) name:AVAudioSessionInterruptionNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(audioSessionRouteDidChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    }
    
    // This is called when the headphones are unplugged, which interrupts the audio session without posting an AVAudioSessionInterruptionNotification.
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteDidChange, (__bridge void *)self);
}

- (PlayerState *)playerState {
    NSManagedObjectContext *currentManagedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
    PlayerState *playerState = nil;
    
    NSArray *fetchedObjects = [[self playerStateFetchedResultsController]fetchedObjects];
    if ([fetchedObjects count] > 0) {
        playerState = [fetchedObjects objectAtIndex:0];
    }
    else {
        playerState = [[PlayerState alloc]initWithEntity:[NSEntityDescription entityForName:@"PlayerState" inManagedObjectContext:currentManagedObjectContext] insertIntoManagedObjectContext:currentManagedObjectContext];
        [[DataManager sharedDataManager]saveContext];
    }
    
    return playerState;
}

- (NSArray *)currentPlaylist {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kShuffleKey]) {
        return [self shufflePlaylist];
    }
    else {
        return [self playlist];
    }
}

- (NSArray *)playlist {
    NSData *playlist = [[self playerState]playlist];
    if (playlist) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:playlist];
    }
    return nil;
}

- (NSArray *)shufflePlaylist {
    NSData *shufflePlaylist = [[self playerState]shufflePlaylist];
    if (shufflePlaylist) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:shufflePlaylist];
    }
    return nil;
}

- (void)updateURLForFileWithNewURL:(NSURL *)newURL previousURL:(NSURL *)previousURL {
    NSString *newURLString = [newURL absoluteString];
    NSString *previousURLString = [previousURL absoluteString];
    
    NSMutableArray *playlist = [NSMutableArray arrayWithArray:[self playlist]];
    NSMutableArray *shufflePlaylist = [NSMutableArray arrayWithArray:[self shufflePlaylist]];
    
    BOOL didChangePlaylists = NO;
    
    if ([playlist containsObject:previousURLString]) {
        // This accounts for duplicate items in the playlist, which can occur when playing a playlist with duplicate tracks.
        while ([playlist containsObject:previousURLString]) {
            [playlist replaceObjectAtIndex:[playlist indexOfObject:previousURLString] withObject:newURLString];
        }
        
        [[self playerState]setPlaylist:[NSKeyedArchiver archivedDataWithRootObject:playlist]];
        
        didChangePlaylists = YES;
    }
    if ([shufflePlaylist containsObject:previousURLString]) {
        // This accounts for duplicate items in the playlist, which can occur when playing a playlist with duplicate tracks.
        while ([shufflePlaylist containsObject:previousURLString]) {
            [shufflePlaylist replaceObjectAtIndex:[shufflePlaylist indexOfObject:previousURLString] withObject:newURLString];
        }
        
        [[self playerState]setShufflePlaylist:[NSKeyedArchiver archivedDataWithRootObject:shufflePlaylist]];
        
        didChangePlaylists = YES;
    }
    
    if (didChangePlaylists) {
        [[DataManager sharedDataManager]saveContext];
    }
}

- (void)setPlaylistItems:(NSArray *)playlistItems {
    NSMutableArray *urlsArray = [NSMutableArray arrayWithObjects:nil];
    for (int i = 0; i < [playlistItems count]; i++) {
        NSString *url = [[(File *)[playlistItems objectAtIndex:i]fileURL]absoluteString];
        if (url) {
            [urlsArray addObject:url];
        }
        else {
            // This acts as a placeholder to prevent the playlist structure from being altered if one or more file URLs are nil (which would, in turn, alter the indexes).
            [urlsArray addObject:@""];
        }
    }
    
    PlayerState *playerState = [self playerState];
    playerState.playlist = [NSKeyedArchiver archivedDataWithRootObject:urlsArray];
    [[DataManager sharedDataManager]saveContext];
}

- (NSInteger)playlistIndex {
    return [[[self playerState]index]integerValue];
}

- (NSInteger)playlistCount {
    return [[self currentPlaylist]count];
}

- (NSTimeInterval)currentPlaybackTime {
    // This accounts for the propagation delay when the music player is seeking.
    if (seeking) {
        return seekPlaybackTime;
    }
    else {
        return CMTimeGetSeconds(musicPlayer.currentTime);
    }
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    CMTime seekTime = CMTimeMakeWithSeconds(currentPlaybackTime, 1);
    
    // AVPlayer will throw an exception if it is asked to seek with a completion handler before its status is AVPlayerStatusReadyToPlay.
    if (([musicPlayer respondsToSelector:@selector(seekToTime:completionHandler:)]) && (musicPlayer.status == AVPlayerStatusReadyToPlay) && (musicPlayer.currentItem.status == AVPlayerStatusReadyToPlay)) {
        // This accounts for the propagation delay when the music player is seeking.
        
        seekPlaybackTime = currentPlaybackTime;
        seeking = YES;
        
        [musicPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
            seeking = NO;
        }];
    }
    else {
        [musicPlayer seekToTime:seekTime];
    }
}

- (NSTimeInterval)duration {
    return CMTimeGetSeconds(musicPlayer.currentItem.duration);
}

- (void)musicPlayerPlaybackDidFinish {
    [self performSelectorOnMainThread:@selector(_musicPlayerPlaybackDidFinish) withObject:nil waitUntilDone:NO];
}

- (void)_musicPlayerPlaybackDidFinish {
    // This seeks to the beginning of the current song.
    // Without seeking to the beginning, calling -play will not replay the current track when Repeat One is selected.
    [musicPlayer seekToTime:kCMTimeZero];
    
    nowPlayingFile.playCount = [NSNumber numberWithInteger:([nowPlayingFile.playCount integerValue] + 1)];
    [[DataManager sharedDataManager]saveContext];
    
    if ([[NSUserDefaults standardUserDefaults]integerForKey:kRepeatModeKey] == kRepeatModeOne) {
        [self play];
    }
    else {
        [self playNextTrack:YES];
    }
}

- (BOOL)updateNowPlayingFile:(BOOL)isInitialSetup {
    // This code must always run because, even if the file is the same, the playlist and played track items are regenerated, invalidating the previous instances of those classes which wouldn't otherwise be updated, causing problems.
    
    File *newNowPlayingFile = [self fileForURLWithAbsoluteString:[[self currentPlaylist]objectAtIndex:[self playlistIndex]]];
    
    if (!newNowPlayingFile) {
        return NO;
    }
    
    BOOL nowPlayingFileDidChange = ![newNowPlayingFile isEqual:nowPlayingFile];
    
    BOOL albumDidChange = NO;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        albumDidChange = ![newNowPlayingFile.albumRefForAlbumArtistGroup isEqual:nowPlayingFile.albumRefForAlbumArtistGroup];
    }
    else {
        albumDidChange = ![newNowPlayingFile.albumRefForArtistGroup isEqual:nowPlayingFile.albumRefForArtistGroup];
    }
    
    nowPlayingFile = newNowPlayingFile;
    
    if (nowPlayingFileDidChange) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[nowPlayingFile fileURL]];
        [musicPlayer replaceCurrentItemWithPlayerItem:item];
        
        // This line is required for now playing info to be displayed on the lock screen.
        [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        // The delegate property of AVAudioSession is deprecated in iOS 6, which uses AVAudioSessionInterruptionNotification instead.
        if ([[[UIDevice currentDevice]systemVersion]compare:@"6.0"] == NSOrderedAscending) {
            audioSession.delegate = self;
        }
        
        nowPlayingFile.lastPlayedDate = [NSDate date];
        [[DataManager sharedDataManager]saveContext];
        
        // The now playing info must be set here in case the player is paused, as it will not update until the MPMediaPlaybackIsPreparedToPlayDidChangeNotification is posted.
        [self updateNowPlayingInfo];
        
        if (!isInitialSetup) {
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            
            [notificationCenter postNotificationName:kPlayerNowPlayingFileDidChangeNotification object:nil];
            
            if (albumDidChange) {
                [notificationCenter postNotificationName:kPlayerAlbumDidChangeNotification object:nil];
            }
        }
    }
    
    return YES;
}

- (void)updateNowPlayingInfo {
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        MPNowPlayingInfoCenter *nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
        
        if (nowPlayingFile) {
            NSMutableDictionary *nowPlayingInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
            
            if (nowPlayingFile.artistRefForAlbumArtistGroup.name) {
                [nowPlayingInfoDictionary setObject:nowPlayingFile.artistRefForAlbumArtistGroup.name forKey:MPMediaItemPropertyAlbumArtist];
            }
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                if (nowPlayingFile.albumRefForAlbumArtistGroup.name) {
                    [nowPlayingInfoDictionary setObject:nowPlayingFile.albumRefForAlbumArtistGroup.name forKey:MPMediaItemPropertyAlbumTitle];
                }
            }
            else {
                if (nowPlayingFile.albumRefForArtistGroup.name) {
                    [nowPlayingInfoDictionary setObject:nowPlayingFile.albumRefForArtistGroup.name forKey:MPMediaItemPropertyAlbumTitle];
                }
            }
            
            if (nowPlayingFile.track) {
                [nowPlayingInfoDictionary setObject:nowPlayingFile.track forKey:MPMediaItemPropertyAlbumTrackNumber];
            }
            if (nowPlayingFile.artistRefForArtistGroup.name) {
                [nowPlayingInfoDictionary setObject:nowPlayingFile.artistRefForArtistGroup.name forKey:MPMediaItemPropertyArtist];
            }
            
            // The rawArtwork method is used here because it should only set the artwork if it exists (otherwise it could set the artwork placeholder).
            UIImage *artworkImage = [nowPlayingFile rawArtwork];
            if (artworkImage) {
                MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc]initWithImage:artworkImage];
                if (artwork) {
                    [nowPlayingInfoDictionary setObject:artwork forKey:MPMediaItemPropertyArtwork];
                }
            }
            
            if (nowPlayingFile.url) {
                [nowPlayingInfoDictionary setObject:[nowPlayingFile fileURL] forKey:MPMediaItemPropertyAssetURL];
            }
            
            if (nowPlayingFile.genreRef.name) {
                [nowPlayingInfoDictionary setObject:nowPlayingFile.genreRef.name forKey:MPMediaItemPropertyGenre];
            }
            if (nowPlayingFile.duration) {
                [nowPlayingInfoDictionary setObject:nowPlayingFile.duration forKey:MPMediaItemPropertyPlaybackDuration];
            }
            if (nowPlayingFile.playCount) {
                [nowPlayingInfoDictionary setObject:nowPlayingFile.playCount forKey:MPMediaItemPropertyPlayCount];
            }
            if (nowPlayingFile.rating) {
                [nowPlayingInfoDictionary setObject:nowPlayingFile.rating forKey:MPMediaItemPropertyRating];
            }
            if (nowPlayingFile.title) {
                [nowPlayingInfoDictionary setObject:nowPlayingFile.title forKey:MPMediaItemPropertyTitle];
            }
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [nowPlayingInfoDictionary setObject:[NSNumber numberWithInteger:[nowPlayingFile.albumRefForAlbumArtistGroup.filesForAlbumArtistGroup count]] forKey:MPMediaItemPropertyAlbumTrackCount];
            }
            else {
                [nowPlayingInfoDictionary setObject:[NSNumber numberWithInteger:[nowPlayingFile.albumRefForArtistGroup.filesForArtistGroup count]] forKey:MPMediaItemPropertyAlbumTrackCount];
            }
            
            [nowPlayingInfoDictionary setObject:[NSNumber numberWithInteger:[self playlistIndex]] forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
            [nowPlayingInfoDictionary setObject:[NSNumber numberWithInteger:[self playlistCount]] forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
            
            // When reusing the above data through the use of an NSMutableDictionary, the app seems to crash on an unusually large number of devices.
            // To prevent this from happening, a new NSMutableDictionary is used every time the now playing info is set and populated using the above data.
            // This is less efficient, but it is far more stable.
            [nowPlayingInfoDictionary setObject:[NSNumber numberWithInteger:CMTimeGetSeconds(musicPlayer.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            
            [nowPlayingInfoCenter setNowPlayingInfo:nowPlayingInfoDictionary];
        }
        else {
            [nowPlayingInfoCenter setNowPlayingInfo:nil];
        }
    }
}

- (void)beginInterruption {
    // This keeps the functions for different firmwares separate.
    if ([[[UIDevice currentDevice]systemVersion]compare:@"6.0"] == NSOrderedAscending) {
        if (musicPlayer.rate != 0) {
            [self pauseMusicPlayer];
        }
        
        playing = NO;
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
        [notificationCenter postNotificationName:kPlayerInterruptionBeganNotification object:nil];
    }
}

- (void)audioSessionInterruptionDidOccur:(NSNotification *)notification {
    NSNumber *interruptionType = [[notification userInfo]objectForKey:AVAudioSessionInterruptionTypeKey];
    
    if ([interruptionType intValue] == AVAudioSessionInterruptionTypeBegan) {
        if (musicPlayer.rate != 0) {
            [self pauseMusicPlayer];
        }
        
        playing = NO;
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
        [notificationCenter postNotificationName:kPlayerInterruptionBeganNotification object:nil];
    }
}

void audioRouteDidChange(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData) {
    // This keeps the functions for different firmwares separate.
    if ([[[UIDevice currentDevice]systemVersion]compare:@"6.0"] == NSOrderedAscending) {
        Player *self = (__bridge Player *)inClientData;
        
        CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inData;
        CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
        SInt32 routeChangeReason;
        CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
        
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            if (self.musicPlayer.rate != 0) {
                [self.musicPlayer pause];
            }
            
            self.playing = NO;
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
            [notificationCenter postNotificationName:kPlayerInterruptionBeganNotification object:nil];
        }
    }
}

- (void)audioSessionRouteDidChange:(NSNotification *)notification {
    NSNumber *changeType = [[notification userInfo]objectForKey:AVAudioSessionRouteChangeReasonKey];
    
    if ([changeType intValue] == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        if (musicPlayer.rate != 0) {
            [musicPlayer pause];
        }
        
        self.playing = NO;
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
        [notificationCenter postNotificationName:kPlayerInterruptionBeganNotification object:nil];
    }
}

- (void)shuffle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:kShuffleKey]) {
        [defaults setBool:YES forKey:kShuffleKey];
        [defaults synchronize];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerDidShuffleNotification object:nil];
    
    NSInteger playlistCount = [[self playlist]count];
    if (playlistCount > 0) {
        [self setCurrentFileWithIndex:(arc4random() % playlistCount)];
    }
    else {
        [self playRandomTrack];
    }
}

- (void)enableShuffle {
    PlayerState *playerState = [self playerState];
    NSArray *playlist = [self playlist];
    playerState.shufflePlaylist = [NSKeyedArchiver archivedDataWithRootObject:[playlist shuffledArrayWithFirstObject:[playlist objectAtIndex:[self playlistIndex]]]];
    playerState.index = [NSNumber numberWithInteger:0];
    [[DataManager sharedDataManager]saveContext];
}

- (void)disableShuffle {
    PlayerState *playerState = [self playerState];
    playerState.shufflePlaylist = nil;
    
    // This feature has been disabled due to the slight inconsistency mentioned below and because of its increased processing requirements.
    // If you are re-implementing this, modify it to account for the different URLs between iPod music library files and regular files.
    /*
    NSIndexSet *indexes = [[self playlist]indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqual:nowPlayingFile.url];
    }];
    if ([indexes count] > 0) {
        if ([indexes count] > 1) {
            // When shuffle is disabled and there are duplicates of the now playing file, it would normally always set the index to that of the first occurrence of that file in the playlist.
            // This implementation selects one of the duplicates at random if applicable, emulating the functionality of a fully-functional shuffle implementation (even though it isn't actually tracking the now playing file across both arrays; it shouldn't matter since all of the duplicates are the same file, but this is done to prevent the app from consistently selecting the first one).
            // The only inconsistency is the fact that toggling shuffling more than once will cause the playlist indexes to be different.
            NSInteger index = (arc4random() % [indexes count]);
            __block NSInteger currentIndex = 0;
            [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                if (currentIndex == index) {
                    playerState.index = [NSNumber numberWithInteger:idx];
                    
                    // This stops enumeration early, improving performance as it is no longer needed at this point.
                    *stop = YES;
                }
                else {
                    currentIndex += 1;
                }
            }];
        }
        else {
            playerState.index = [NSNumber numberWithInteger:[indexes firstIndex]];
        }
    }
    */
    
    if (nowPlayingFile) {
        playerState.index = [NSNumber numberWithInteger:[[self playlist]indexOfObject:[[nowPlayingFile fileURL]absoluteString]]];
    }
    else {
        playerState.index = [NSNumber numberWithInteger:0];
    }
    
    [[DataManager sharedDataManager]saveContext];
}

- (void)setCurrentFileWithIndex:(NSInteger)index {
    PlayerState *playerState = [self playerState];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kShuffleKey]) {
        // The shuffle playlist is automatically regenerated when shuffling is enabled, so it is only necessary to create it here if shuffling is already enabled.
        NSArray *playlist = [self playlist];
        playerState.shufflePlaylist = [NSKeyedArchiver archivedDataWithRootObject:[playlist shuffledArrayWithFirstObject:[playlist objectAtIndex:index]]];
        
        playerState.index = [NSNumber numberWithInteger:0];
    }
    else {
        playerState.index = [NSNumber numberWithInteger:index];
    }
    [[DataManager sharedDataManager]saveContext];
    
    [self updateNowPlayingFile:NO];
    
    playing = YES;
    [self startMusicPlayer];
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
}

- (void)togglePlaybackState {
    if (nowPlayingFile) {
        playing = !playing;
        
        if (playing) {
            [self startMusicPlayer];
        }
        else {
            [self pauseMusicPlayer];
        }
    }
    else {
        // If there is nothing playing, it should be able to pause.
        playing = [self playRandomTrack];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
}

- (void)play {
    playing = YES;
    
    if (nowPlayingFile) {
        [self startMusicPlayer];
    }
    else {
        [self playRandomTrack];
    }
}

- (void)startMusicPlayer {
    [musicPlayer play];
    
    if ((!playbackTimer) || (![playbackTimer isValid])) {
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateCurrentPlaybackTime) userInfo:nil repeats:YES];
        [self updateCurrentPlaybackTime];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
}

- (void)pauseMusicPlayer {
    [musicPlayer pause];
    [self stopPlaybackTimer];
}

- (void)stopMusicPlayer {
    [musicPlayer pause];
    [self stopPlaybackTimer];
}

- (void)stopPlaybackTimer {
    if ((playbackTimer) && ([playbackTimer isValid])) {
        [playbackTimer invalidate];
    }
}

- (void)updateCurrentPlaybackTime {
    // This updates the current playback time on the lock screen for devices running iOS 7.
    [self updateNowPlayingInfo];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerCurrentPlaybackTimeDidChangeNotification object:nil];
}

- (void)pause {
    playing = NO;
    [self pauseMusicPlayer];
    
    if ((playbackTimer) && ([playbackTimer isValid])) {
        [playbackTimer invalidate];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
}

- (void)skipToPreviousTrack {
    // The following NSInteger cast handles nonexistent or unplayable files, in which case the app should always skip to the previous track.
    if ((NSInteger)CMTimeGetSeconds(musicPlayer.currentTime) < 3) {
        if (nowPlayingFile) {
            skippingToPreviousTrack = YES;
            
            NSInteger index = [self playlistIndex];
            if (index > 0) {
                PlayerState *playerState = [self playerState];
                playerState.index = [NSNumber numberWithInteger:(index - 1)];
                [[DataManager sharedDataManager]saveContext];
                
                [self updateNowPlayingFile:NO];
                
                if (playing) {
                    [self startMusicPlayer];
                }
            }
            else {
                if ([[NSUserDefaults standardUserDefaults]integerForKey:kRepeatModeKey] == kRepeatModeAll) {
                    PlayerState *playerState = [self playerState];
                    playerState.index = [NSNumber numberWithInteger:([self playlistCount] - 1)];
                    [[DataManager sharedDataManager]saveContext];
                    
                    [self updateNowPlayingFile:NO];
                    
                    if (playing) {
                        [self startMusicPlayer];
                    }
                }
                else {
                    [self stop];
                    
                    // If the song "finishes" before the PlayerViewController is completely pushed onto the stack, -popViewController:animated: will be called, deallocating the PlayerViewController while it is still being pushed onto the stack. Thus, it can never be dismissed and could cause the app to crash when the user attempts to interact with the controls.
                    /*
                    RootViewController *rootViewController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController];
                    if ([rootViewController.topViewController isKindOfClass:[PlayerViewController class]]) {
                        [rootViewController popViewControllerAnimated:YES];
                    }
                    */
                }
            }
            
            skippingToPreviousTrack = NO;
        }
        // If the song "finishes" before the PlayerViewController is completely pushed onto the stack, -popViewController:animated: will be called, deallocating the PlayerViewController while it is still being pushed onto the stack. Thus, it can never be dismissed and could cause the app to crash when the user attempts to interact with the controls.
        /*
        else {
            RootViewController *rootViewController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController];
            if ([rootViewController.topViewController isKindOfClass:[PlayerViewController class]]) {
                [rootViewController popViewControllerAnimated:YES];
            }
        }
        */
    }
    else {
        [musicPlayer seekToTime:kCMTimeZero];
        [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerCurrentPlaybackTimeDidChangeNotification object:nil];
    }
}

- (void)skipToNextTrack {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(playerShouldChangeTrackManually)]) {
            if (![delegate playerShouldChangeTrackManually]) {
                return;
            }
        }
    }
    
    if (nowPlayingFile) {
        [self playNextTrack:[self playing]];
    }
    else {
        [self playRandomTrack];
    }
}

- (void)playNextTrack:(BOOL)wasPlaying {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(playerShouldChangeTrackManually)]) {
            if (![delegate playerShouldChangeTrackManually]) {
                return;
            }
        }
    }
    
    NSInteger index = [self playlistIndex];
    if (index < ([self playlistCount] - 1)) {
        PlayerState *playerState = [self playerState];
        playerState.index = [NSNumber numberWithInteger:(index + 1)];
        [[DataManager sharedDataManager]saveContext];
        
        [self updateNowPlayingFile:NO];
        
        if (playing) {
            [self startMusicPlayer];
        }
    }
    else {
        if ([[NSUserDefaults standardUserDefaults]integerForKey:kRepeatModeKey] == kRepeatModeAll) {
            PlayerState *playerState = [self playerState];
            playerState.index = [NSNumber numberWithInteger:0];
            [[DataManager sharedDataManager]saveContext];
            
            [self updateNowPlayingFile:NO];
            
            if (playing) {
                [self startMusicPlayer];
            }
        }
        else {
            [self stop];
            
            // If the song "finishes" before the PlayerViewController is completely pushed onto the stack, -popViewController:animated: will be called, deallocating the PlayerViewController while it is still being pushed onto the stack. Thus, it can never be dismissed and could cause the app to crash when the user attempts to interact with the controls.
            /*
            RootViewController *rootViewController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController];
            if ([rootViewController.topViewController isKindOfClass:[PlayerViewController class]]) {
                [rootViewController popViewControllerAnimated:YES];
            }
            */
        }
    }
}

- (BOOL)playRandomTrack {
    // Instead of refreshing the songs fetched results controller when the "Group By Album Artist" preference changes, it is refreshed as needed here (as this function is called relatively infrequently).
    if (songsFetchedResultsController) {
        songsFetchedResultsController = nil;
    }
    
    NSArray *songsArray = [[self songsFetchedResultsController]fetchedObjects];
    if ([songsArray count] > 0) {
        [self setPlaylistItems:songsArray];
        [self setCurrentFileWithIndex:(arc4random() % [songsArray count])];
        return YES;
    }
    return NO;
}

- (void)stop {
    playing = NO;
    
    [self stopMusicPlayer];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerPlaybackStateDidChangeNotification object:nil];
    
    nowPlayingFile = nil;
    
    // This will clear the now playing info, as it is called after the nowPlayingFile variable has been set to nil.
    [self updateNowPlayingInfo];
    
    PlayerState *playerState = [self playerState];
    playerState.playlist = nil;
    playerState.shufflePlaylist = nil;
    playerState.index = nil;
    [[DataManager sharedDataManager]saveContext];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerNowPlayingFileDidChangeNotification object:nil];
}

- (void)initializeSleepTimer {
    sleepTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(decrementSleepDelay) userInfo:nil repeats:YES];
    timerState = kTimerStateRunning;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kPlayerSleepTimerDelayDidChangeNotification object:nil];
    [notificationCenter postNotificationName:kPlayerSleepTimerStateDidChangeNotification object:nil];
}

- (void)pauseSleepTimer {
    [sleepTimer invalidate];
    timerState = kTimerStatePaused;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerSleepTimerStateDidChangeNotification object:nil];
}

- (void)stopSleepTimer {
    [sleepTimer invalidate];
    sleepDelay = 0;
    timerState = kTimerStateStopped;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kPlayerSleepTimerStateDidChangeNotification object:nil];
    [notificationCenter postNotificationName:kPlayerSleepTimerDelayDidChangeNotification object:nil];
}

- (void)decrementSleepDelay {
    sleepDelay -= 1;
    
    // -stopSleepTimer automatically posts a kPlayerSleepTimerDelayDidChangeNotification, so it only needs to be posted here if -stopSleepTimer isn't going to be called.
    if (sleepDelay > 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kPlayerSleepTimerDelayDidChangeNotification object:nil];
    }
    else {
        [self pause];
        [self stopSleepTimer];
    }
}

- (File *)fileForURLWithAbsoluteString:(NSString *)url {
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:creationDateSortDescriptor, nil]];
    
    // This does not account for the parent directory of the file, so the fetched objects must be filtered below after they are fetched.
    // This incomplete predicate is used anyway because it reduces the amount of processing required to filter the array of fetched objects after they are fetched.
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"((iPodMusicLibraryFile == %@) AND (url == %@)) OR ((iPodMusicLibraryFile == %@) AND (fileName == %@))", [NSNumber numberWithBool:YES], url, [NSNumber numberWithBool:NO], [[NSURL URLWithString:url]lastPathComponent]]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // The above predicate does not account for the parent directory of the file, so the fetched objects must be filtered here after they are fetched.
    NSArray *fetchedObjects = [aFetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        File *file = evaluatedObject;
        return [[[file fileURL]absoluteString]isEqualToString:url];
    }]];
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}

- (NSFetchedResultsController *)songsFetchedResultsController {
    if (!songsFetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSSortDescriptor *albumByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSSortDescriptor *albumByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSSortDescriptor *artistByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSSortDescriptor *artistByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSSortDescriptor *trackSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"track" ascending:YES];
        NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO];
        
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:titleSortDescriptor, albumByAlbumArtistSortDescriptor, albumByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, trackSortDescriptor, creationDateSortDescriptor, nil]];
        }
        else {
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:titleSortDescriptor, albumByArtistSortDescriptor, albumByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, trackSortDescriptor, creationDateSortDescriptor, nil]];
        }
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        songsFetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        if (![songsFetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return songsFetchedResultsController;
}

- (NSFetchedResultsController *)playerStateFetchedResultsController {
    if (!playerStateFetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerState" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        [fetchRequest setFetchLimit:1];
        
        NSSortDescriptor *indexSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"index" ascending:YES];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:indexSortDescriptor, nil]];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        playerStateFetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        if (![playerStateFetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return playerStateFetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // This delegate method must be implemented (in addition to the delegate being set) for the fetched results controllers to track changes to the managed object context.
}

- (void)dealloc {
    if ((playbackTimer) && ([playbackTimer isValid])) {
        [playbackTimer invalidate];
    }
    
    songsFetchedResultsController.delegate = nil;
    playerStateFetchedResultsController.delegate = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
