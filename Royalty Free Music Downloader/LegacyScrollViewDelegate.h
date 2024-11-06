//
//  LegacyScrollViewDelegate.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 7/3/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LegacyScrollViewDelegate : NSObject <UIScrollViewDelegate> {
    id <UIScrollViewDelegate> __unsafe_unretained originalDelegate;
    id <UIScrollViewDelegate> __unsafe_unretained replacedDelegate;
}

@property (nonatomic, unsafe_unretained) id <UIScrollViewDelegate> originalDelegate;
@property (nonatomic, unsafe_unretained) id <UIScrollViewDelegate> replacedDelegate;

@end
