//
//  TagReader.h
//  TagLib-ObjC
//
//  Created by Me on 01/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagReader : NSObject

- (id)initWithFileAtPath:(NSString *)path;  //Designated initializer
- (void)loadFileAtPath:(NSString *)path;

- (BOOL)save;
- (BOOL)doubleSave; //Some filetypes require being saved twice (unknown reasons), if saving with - save doesn't work, try -doubleSave. 

@property (readonly, nonatomic) NSString *path;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *albumArtist;
@property (nonatomic) NSString *album;
@property (nonatomic) NSNumber *year;
@property (nonatomic) NSString *comment;
@property (nonatomic) NSNumber *track;
@property (nonatomic) NSString *genre;
@property (nonatomic) NSData *albumArt;
@property (nonatomic) NSString *lyrics;

// Read-only properties
@property (nonatomic) int bitrate;
@property (nonatomic) int channels;
@property (nonatomic) int duration;
@property (nonatomic) int sampleRate;
@property (readonly) BOOL validTags;

@end
