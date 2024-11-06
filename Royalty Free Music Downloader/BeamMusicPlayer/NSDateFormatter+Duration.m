//
//  NSDateFormatter+Duration.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "NSDateFormatter+Duration.h"

@implementation NSDateFormatter (Duration)

+ (NSString *)formattedDuration:(long)duration {
    NSString *prefix = @"";
    if (duration < 0) {
        prefix = @"-";
    }

    duration = abs(duration);
    
    NSMutableArray *components = [NSMutableArray new];
    
    // 1 Hour
    if (duration >= 3600) {
        [components addObject:[NSString stringWithFormat:@"%ld", (duration / 3600)]];
        duration %= 3600;
        
        [components addObject:[NSString stringWithFormat:@"%02ld", (duration / 60)]];
        duration %= 60;
    }
    else {
        // 1 Minute
        if (duration >= 60) {
            [components addObject:[NSString stringWithFormat:@"%ld", (duration / 60)]];
            duration %= 60;
        }
    }
    
    // The minute indicator must always be present.
    if ([components count] <= 0) {
        [components addObject:@"0"];
    }
    
    [components addObject:[NSString stringWithFormat:@"%02ld", duration]];

    return [prefix stringByAppendingString:[components componentsJoinedByString:@":"]];
        
}

@end
