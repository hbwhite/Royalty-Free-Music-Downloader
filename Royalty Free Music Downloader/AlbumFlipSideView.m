//
//  AlbumFlipSideView.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/6/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "AlbumFlipSideView.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "RatingView.h"
#import "AlbumTrackListView.h"
#import "Player.h"
#import "DataManager.h"
#import "File.h"
#import "Album.h"
#import "UIImage+SafeStretchableImage.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface AlbumFlipSideView ()

@property (nonatomic, strong) RatingView *ratingView;
@property (nonatomic, strong) AlbumTrackListView *albumTrackListView;

- (void)nowPlayingFileDidChange;
- (void)adDidShow;
- (void)adDidHide;

@end

@implementation AlbumFlipSideView

@synthesize ratingView;
@synthesize albumTrackListView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(nowPlayingFileDidChange) name:kPlayerNowPlayingFileDidChangeNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(adDidShow) name:kAdDidShowNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(adDidHide) name:kAdDidHideNotification object:nil];
        
        ratingView = [[RatingView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        ratingView.delegate = self;
        ratingView.rating = [[[[Player sharedPlayer]nowPlayingFile]rating]integerValue];
        ratingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:ratingView];
        
        albumTrackListView = [[AlbumTrackListView alloc]initWithFrame:CGRectMake(0, 44, frame.size.width, (frame.size.height - 44))];
        albumTrackListView.delegate = self;
        albumTrackListView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self addSubview:albumTrackListView];
        
        UIImageView *playerControlsFadeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (frame.size.height - 95), frame.size.width, 95)];
        playerControlsFadeImageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
        playerControlsFadeImageView.image = [[UIImage imageNamed:@"Player_Controls_Fade"]safeStretchableImageWithLeftCapWidth:1 topCapHeight:48];
        [self addSubview:playerControlsFadeImageView];
        
        if ([[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]bannerViewShown]) {
            [self adDidShow];
        }
        else {
            [self adDidHide];
        }
    }
    return self;
}

- (void)ratingViewDidChangeRating:(NSInteger)newRating {
    [[[Player sharedPlayer]nowPlayingFile]setRating:[NSNumber numberWithInteger:newRating]];
    [[DataManager sharedDataManager]saveContext];
}

- (Album *)albumTrackListViewAlbum {
    File *nowPlayingFile = [[Player sharedPlayer]nowPlayingFile];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        return nowPlayingFile.albumRefForAlbumArtistGroup;
    }
    else {
        return nowPlayingFile.albumRefForArtistGroup;
    }
}

- (void)nowPlayingFileDidChange {
    ratingView.rating = [[[[Player sharedPlayer]nowPlayingFile]rating]integerValue];
    [albumTrackListView updateTracks];
}

- (void)adDidShow {
    NSInteger albumTrackListTableFooterViewHeight = 96;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationPortrait) {
            albumTrackListTableFooterViewHeight = 146;
        }
        else {
            albumTrackListTableFooterViewHeight = 128;
        }
    }
    else {
        albumTrackListTableFooterViewHeight = 186;
    }
    
    UIView *albumTrackListTableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, albumTrackListTableFooterViewHeight)];
    albumTrackListTableFooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    albumTrackListTableFooterView.backgroundColor = [UIColor clearColor];
    albumTrackListView.theTableView.tableFooterView = albumTrackListTableFooterView;
}

- (void)adDidHide {
    UIView *albumTrackListTableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 96)];
    albumTrackListTableFooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    albumTrackListTableFooterView.backgroundColor = [UIColor clearColor];
    albumTrackListView.theTableView.tableFooterView = albumTrackListTableFooterView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
