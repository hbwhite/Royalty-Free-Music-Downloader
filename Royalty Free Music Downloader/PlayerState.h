//
//  PlayerState.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 6/21/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PlayerState : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * playbackTime;
@property (nonatomic, retain) NSData * playlist;
@property (nonatomic, retain) NSData * shufflePlaylist;
@property (nonatomic, retain) NSNumber * equalizerPresetIndex;

@end
