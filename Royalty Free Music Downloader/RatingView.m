//
//  RatingView.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/1/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "RatingView.h"

@interface RatingView ()

@property (nonatomic, strong) UIImageView *star1ImageView;
@property (nonatomic, strong) UIImageView *star2ImageView;
@property (nonatomic, strong) UIImageView *star3ImageView;
@property (nonatomic, strong) UIImageView *star4ImageView;
@property (nonatomic, strong) UIImageView *star5ImageView;

- (void)updateRating;
- (void)respondToTouches:(NSSet *)touches;

@end

@implementation RatingView

// Public
@synthesize delegate;
@synthesize rating;

// Private
@synthesize star1ImageView;
@synthesize star2ImageView;
@synthesize star3ImageView;
@synthesize star4ImageView;
@synthesize star5ImageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        backgroundImageView.image = [UIImage imageNamed:@"Rating_Background"];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundImageView];
        
        UIImage *starMissingImage = [UIImage imageNamed:@"Star-Missing"];
        
        CGFloat commonWidth = ((frame.size.width - 128) / 5.0);
        
        star1ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(64, 0, (NSInteger)commonWidth, 44)];
        star1ImageView.contentMode = UIViewContentModeCenter;
        star1ImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        star1ImageView.image = starMissingImage;
        [self addSubview:star1ImageView];
        
        star2ImageView = [[UIImageView alloc]initWithFrame:CGRectMake((NSInteger)(64 + commonWidth), 0, (NSInteger)commonWidth, 44)];
        star2ImageView.contentMode = UIViewContentModeCenter;
        star2ImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        star2ImageView.image = starMissingImage;
        [self addSubview:star2ImageView];
        
        star3ImageView = [[UIImageView alloc]initWithFrame:CGRectMake((NSInteger)(64 + (commonWidth * 2)), 0, (NSInteger)commonWidth, 44)];
        star3ImageView.contentMode = UIViewContentModeCenter;
        star3ImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        star3ImageView.image = starMissingImage;
        [self addSubview:star3ImageView];
        
        star4ImageView = [[UIImageView alloc]initWithFrame:CGRectMake((NSInteger)(64 + (commonWidth * 3)), 0, (NSInteger)commonWidth, 44)];
        star4ImageView.contentMode = UIViewContentModeCenter;
        star4ImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        star4ImageView.image = starMissingImage;
        [self addSubview:star4ImageView];
        
        star5ImageView = [[UIImageView alloc]initWithFrame:CGRectMake((NSInteger)(frame.size.width - (64 + commonWidth)), 0, (NSInteger)commonWidth, 44)];
        star5ImageView.contentMode = UIViewContentModeCenter;
        star5ImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        star5ImageView.image = starMissingImage;
        [self addSubview:star5ImageView];
    }
    return self;
}

- (void)setRating:(NSInteger)newRating {
    rating = newRating;
    [self updateRating];
}

- (void)updateRating {
    UIImage *starImage = [UIImage imageNamed:@"Star"];
    UIImage *starMissingImage = [UIImage imageNamed:@"Star-Missing"];
    
    NSArray *imageViewsArray = [NSArray arrayWithObjects:star1ImageView, star2ImageView, star3ImageView, star4ImageView, star5ImageView, nil];
    for (int i = 0; i < 5; i++) {
        UIImageView *imageView = [imageViewsArray objectAtIndex:i];
        if (i < rating) {
            imageView.image = starImage;
        }
        else {
            imageView.image = starMissingImage;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self respondToTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self respondToTouches:touches];
}

- (void)respondToTouches:(NSSet *)touches {
    CGPoint location = [[touches anyObject]locationInView:self];
    
    if (CGRectContainsPoint(self.frame, location)) {
        NSInteger newRating = -1;
        
        if (location.x < star1ImageView.frame.origin.x) {
            newRating = 0;
        }
        else if (CGRectContainsPoint(star1ImageView.frame, location)) {
            newRating = 1;
        }
        else if (CGRectContainsPoint(star2ImageView.frame, location)) {
            newRating = 2;
        }
        else if (CGRectContainsPoint(star3ImageView.frame, location)) {
            newRating = 3;
        }
        else if (CGRectContainsPoint(star4ImageView.frame, location)) {
            newRating = 4;
        }
        else if (location.x >= star4ImageView.frame.origin.x) {
            newRating = 5;
        }
        
        if (newRating >= 0) {
            if (rating != newRating) {
                rating = newRating;
                
                [self updateRating];
                
                if (delegate) {
                    if ([delegate respondsToSelector:@selector(ratingViewDidChangeRating:)]) {
                        [delegate ratingViewDidChangeRating:rating];
                    }
                }
            }
        }
    }
}

@end
