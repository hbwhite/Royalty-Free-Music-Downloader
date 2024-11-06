//
//  RatingViewDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

@protocol RatingViewDelegate <NSObject>

@optional
- (void)ratingViewDidChangeRating:(NSInteger)newRating;

@end
