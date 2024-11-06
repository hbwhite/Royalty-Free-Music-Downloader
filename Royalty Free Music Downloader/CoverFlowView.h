//
//  CoverFlowView.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/20/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoverFlowView : UIView {
@private
    UIImageView *imageView;
    UIImageView *reflectionImageView;
    CAGradientLayer *gradientLayer;
}

- (UIImage *)image;
- (void)setImage:(UIImage *)image;

@end
