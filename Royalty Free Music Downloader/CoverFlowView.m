//
//  CoverFlowView.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/20/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "CoverFlowView.h"

@interface CoverFlowView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *reflectionImageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation CoverFlowView

// Private
@synthesize imageView;
@synthesize reflectionImageView;
@synthesize gradientLayer;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(38, 0, 224, 224)];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        
        CGRect reflectRect = CGRectMake(38, 224, 224, 224);
        
        reflectionImageView =  [[UIImageView alloc] initWithFrame:reflectRect];
        reflectionImageView.backgroundColor = [UIColor blackColor];
        reflectionImageView.contentMode = UIViewContentModeScaleAspectFit;
        reflectionImageView.transform = CGAffineTransformScale(reflectionImageView.transform, 1, -1);
        [self addSubview:reflectionImageView];
        
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0 alpha:1].CGColor, nil];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 0.3);
        gradientLayer.frame = reflectRect;
        [self.layer addSublayer:gradientLayer];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
	self.imageView.image = image;
    
    if (self.gradientLayer) {
        self.reflectionImageView.image = image;
    }
}

- (UIImage *)image {
	return self.imageView.image;
}

@end
