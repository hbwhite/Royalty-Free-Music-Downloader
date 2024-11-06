//
//  NowPlayingButton.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSLabel;

@interface NowPlayingButton : UIBarButtonItem {
    UIButton *nowPlayingContentButton;
    MSLabel *nowPlayingLabel;
}

@property (nonatomic, strong) UIButton *nowPlayingContentButton;
@property (nonatomic, strong) MSLabel *nowPlayingLabel;

@end
