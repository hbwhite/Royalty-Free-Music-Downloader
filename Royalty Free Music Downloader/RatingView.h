//
//  RatingView.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingViewDelegate.h"

@interface RatingView : UIView {
@public
    id <RatingViewDelegate> __unsafe_unretained delegate;
    NSInteger rating;
@private
    UIImageView *star1ImageView;
    UIImageView *star2ImageView;
    UIImageView *star3ImageView;
    UIImageView *star4ImageView;
    UIImageView *star5ImageView;
}

@property (nonatomic, unsafe_unretained) id <RatingViewDelegate> delegate;
@property (nonatomic) NSInteger rating;

@end
