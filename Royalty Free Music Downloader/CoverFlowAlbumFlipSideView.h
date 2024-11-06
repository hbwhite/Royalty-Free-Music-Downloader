//
//  CoverFlowAlbumFlipSideView.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/6/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumTrackListView.h"
#import "CoverFlowAlbumFlipSideViewDelegate.h"

@class Album;

@interface CoverFlowAlbumFlipSideView : UIView <AlbumTrackListViewDelegate> {
    id <CoverFlowAlbumFlipSideViewDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic, unsafe_unretained) id <CoverFlowAlbumFlipSideViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id <CoverFlowAlbumFlipSideViewDelegate> __unsafe_unretained)delegate;

@end

