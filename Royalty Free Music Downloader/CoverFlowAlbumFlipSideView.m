//
//  CoverFlowAlbumFlipSideView.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/6/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "CoverFlowAlbumFlipSideView.h"
#import "Album.h"
#import "Album+Extensions.h"
#import "Artist.h"
#import "UIImage+SafeStretchableImage.h"

@interface CoverFlowAlbumFlipSideView ()

- (void)albumArtworkButtonPressed;

@end

@implementation CoverFlowAlbumFlipSideView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id <CoverFlowAlbumFlipSideViewDelegate> __unsafe_unretained)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.delegate = delegate;
        
        Album *album = [delegate coverFlowAlbumFlipSideViewAlbum];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *albumInfoBarBackgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(1, 1, 298, 44)];
        albumInfoBarBackgroundImageView.image = [[UIImage imageNamed:@"Cover_Flow_Album_Info_Bar"]safeStretchableImageWithLeftCapWidth:1 topCapHeight:22];
        [self addSubview:albumInfoBarBackgroundImageView];
        
        UILabel *artistLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 3, 249, 18)];
        artistLabel.backgroundColor = [UIColor clearColor];
        artistLabel.font = [UIFont boldSystemFontOfSize:15];
        artistLabel.textColor = [UIColor whiteColor];
        artistLabel.text = album.artist.name;
        [self addSubview:artistLabel];
        
        UILabel *albumLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 21, 249, 24)];
        albumLabel.backgroundColor = [UIColor clearColor];
        albumLabel.font = [UIFont boldSystemFontOfSize:24];
        albumLabel.textColor = [UIColor whiteColor];
        albumLabel.text = album.name;
        [self addSubview:albumLabel];
        
        UIButton *albumArtworkButton = [[UIButton alloc]initWithFrame:CGRectMake(255, 1, 44, 44)];
        albumArtworkButton.imageView.backgroundColor = [UIColor blackColor];
        albumArtworkButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        albumArtworkButton.adjustsImageWhenHighlighted = NO;
        [albumArtworkButton setImage:[album coverFlowArtwork] forState:UIControlStateNormal];
        [albumArtworkButton addTarget:self action:@selector(albumArtworkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:albumArtworkButton];
        
        AlbumTrackListView *albumTrackListView = [[AlbumTrackListView alloc]initWithFrame:CGRectMake(1, 45, 298, 254)];
        albumTrackListView.delegate = self;
        
        // This prevents excess cell separators from being created.
        UIView *defaultFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        defaultFooterView.backgroundColor = [UIColor clearColor];
        albumTrackListView.theTableView.tableFooterView = defaultFooterView;
        
        [self addSubview:albumTrackListView];
    }
    return self;
}

- (Album *)albumTrackListViewAlbum {
    return [self.delegate coverFlowAlbumFlipSideViewAlbum];
}

- (void)albumArtworkButtonPressed {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(coverFlowAlbumFlipSideViewAlbumArtworkButtonPressed)]) {
            [self.delegate coverFlowAlbumFlipSideViewAlbumArtworkButtonPressed];
        }
    }
}

@end
