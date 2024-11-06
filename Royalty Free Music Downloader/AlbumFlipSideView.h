//
//  AlbumFlipSideView.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/6/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingViewDelegate.h"
#import "AlbumTrackListViewDelegate.h"

@class RatingView;
@class AlbumTrackListView;

@interface AlbumFlipSideView : UIView <RatingViewDelegate, AlbumTrackListViewDelegate> {
@private
    RatingView *ratingView;
    AlbumTrackListView *albumTrackListView;
}

@end
