//
//  OBSlider.h
//
//  Created by Ole Begemann on 02.01.11.
//  Copyright 2011 Ole Begemann. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OBSliderDelegate;

@interface OBSlider : UISlider {
    id <OBSliderDelegate> __unsafe_unretained delegate;
    UIImageView *glowImageView;
}

@property (nonatomic, unsafe_unretained) id <OBSliderDelegate> delegate;
@property (assign, nonatomic, readonly) float scrubbingSpeed;
@property (strong, nonatomic) NSArray *scrubbingSpeeds;
@property (strong, nonatomic) NSArray *scrubbingSpeedChangePositions;

- (void)stopScrubbing;

@end

@protocol OBSliderDelegate <NSObject>

@optional
- (void)sliderDidBeginScrubbing;
- (void)sliderDidEndScrubbing;

@end
