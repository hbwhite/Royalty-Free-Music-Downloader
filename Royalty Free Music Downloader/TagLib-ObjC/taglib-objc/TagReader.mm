//
//  TagReader.m
//  TagLib-ObjC
//
//  Created by Me on 01/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagReader.h"

#include <fileref.h>
#include <mpegfile.h>
#include <id3v2tag.h>
#include <id3v2frame.h>
#include <id3v2header.h>
#include <attachedpictureframe.h>

#include <mp4file.h>
#include <rifffile.h>
#include <wavfile.h>
#include <aifffile.h>
#include <unsynchronizedlyricsframe.h>

using namespace TagLib;

static NSString *NSStr(TagLib::String _string)
{
    if (_string.isNull() == false) {
        return @( _string.toCString(true) );
    } else {
        return nil;
    }
}
static TagLib::String TLStr(NSString *_string)
{
    return TagLib::String([_string UTF8String], TagLib::String::UTF8);
}

@interface TagReader ()
{
    FileRef *_file;
}

@property (readwrite, nonatomic) NSString *path;

@end

@implementation TagReader

- (id)initWithFileAtPath:(NSString *)path
{
    if (self = [super init]) {
        [self loadFileAtPath:path];
    }
    return self;
}
- (id)init
{
    return [self initWithFileAtPath:nil];
}
- (void)dealloc
{
    if (_file != NULL) {
        delete _file;
    }
}

- (void)loadFileAtPath:(NSString *)path
{
    if ([self.path isEqualToString:path] == NO) {
        self.path = path;
        
        if (_file != NULL) {
            delete _file;
        }
        
        if (self.path != nil && self.path.length != 0) {
            _file = new FileRef([self.path UTF8String]);
        } else {
            _file = NULL;
        }
    }
}

- (BOOL)save
{
    if (!_file->isNull()) {
        NSString *uppercasePathExtension = [[self.path pathExtension]uppercaseString];
        if (([uppercasePathExtension isEqualToString:@"WAV"]) || ([uppercasePathExtension isEqualToString:@"AIF"]) || ([uppercasePathExtension isEqualToString:@"AIFC"]) || ([uppercasePathExtension isEqualToString:@"AIFF"])) {
            // WAV, AIF, AIFC, AIFF
            // These files need to be saved twice for the tags to save properly.
            
            return (((BOOL)_file->save()) && ((BOOL)_file->save()));
        }
        else {
            return (BOOL)_file->save();
        }
    }
    return NO;
}
- (BOOL)doubleSave
{
    return [self save] && [self save];
}

- (NSString *)title
{
    if (_file->isNull()) return nil; else return NSStr(_file->tag()->title());
}
- (void)setTitle:(NSString *)title
{
    if (!_file->isNull()) _file->tag()->setTitle(TLStr(title));
}
- (NSString *)artist
{
    if (_file->isNull()) return nil; else return NSStr(_file->tag()->artist());
}
- (void)setArtist:(NSString *)artist
{
    if (!_file->isNull()) _file->tag()->setArtist(TLStr(artist));
}
- (NSString *)albumArtist {
    if (_file->isNull()) return nil; else return NSStr(_file->tag()->albumArtist());
}
- (void)setAlbumArtist:(NSString *)albumArtist {
    if (!_file->isNull()) _file->tag()->setAlbumArtist(TLStr(albumArtist));
}
- (NSString *)album
{
    if (_file->isNull()) return nil; else return NSStr(_file->tag()->album());
}
- (void)setAlbum:(NSString *)album
{
    if (!_file->isNull()) _file->tag()->setAlbum(TLStr(album));
}
- (NSNumber *)year
{
    if (_file->isNull()) return nil; else return @( _file->tag()->year() );
}
- (void)setYear:(NSNumber *)year
{
    if (!_file->isNull()) _file->tag()->setYear([year unsignedIntValue]);
}
- (NSString *)comment
{
    if (_file->isNull()) return nil; else return NSStr(_file->tag()->comment());
}
- (void)setComment:(NSString *)comment
{
    if (!_file->isNull()) _file->tag()->setComment(TLStr(comment));
}
- (NSNumber *)track
{
    if (_file->isNull()) return nil; else return @( _file->tag()->track() );
}
- (void)setTrack:(NSNumber *)track
{
    if (!_file->isNull()) _file->tag()->setTrack([track unsignedIntValue]);
}
- (NSString *)genre
{
    if (_file->isNull()) return nil; else return NSStr(_file->tag()->genre());
}
- (void)setGenre:(NSString *)genre
{
    if (!_file->isNull()) _file->tag()->setGenre(TLStr(genre));
}
- (NSData *)albumArt
{
    if (!_file->isNull()) {
        Picture *picture = _file->tag()->picture();
        if (picture) {
            ByteVector data = picture->data();
            return [NSData dataWithBytes:data.data() length:data.size()];
        }
        
        /*
        MPEG::File *file = dynamic_cast<MPEG::File *>(_file->file());
        if (file != NULL) {
            ID3v2::Tag *tag = file->ID3v2Tag();
            if (tag) {
                ID3v2::FrameList frameList = tag->frameListMap()["APIC"];
                ID3v2::AttachedPictureFrame *picture = NULL;
                
                if (!frameList.isEmpty() && NULL != (picture = dynamic_cast<ID3v2::AttachedPictureFrame *>(frameList.front()))) {
                    TagLib::ByteVector bv = picture->picture();
                    return [NSData dataWithBytes:bv.data() length:bv.size()];
                }
            }
        }
        */
    }
    return nil;
}

- (void)setAlbumArt:(NSData *)albumArt
{
    if (!_file->isNull()) {
        NSString *uppercasePathExtension = [[self.path pathExtension]uppercaseString];
        
        if (([uppercasePathExtension isEqualToString:@"M4A"]) ||
            ([uppercasePathExtension isEqualToString:@"M4R"]) ||
            ([uppercasePathExtension isEqualToString:@"M4B"]) ||
            ([uppercasePathExtension isEqualToString:@"M4P"]) ||
            ([uppercasePathExtension isEqualToString:@"MP4"]) ||
            ([uppercasePathExtension isEqualToString:@"3G2"]) ||
            ([uppercasePathExtension isEqualToString:@"AAC"])) {
            
            // M4A, M4R, M4B, M4P, MP4, 3G2, AAC
            
            MP4::File *file = dynamic_cast<MP4::File *>(_file->file());
            if (file != NULL) {
                MP4::Tag *tag = file->tag();
                if (tag) {
                    if (albumArt != nil && [albumArt length] > 0) {
                        MP4::CoverArtList covers;
                        
                        ByteVector bv = ByteVector((const char *)[albumArt bytes], [albumArt length]);
                        covers.append(MP4::CoverArt(MP4::CoverArt::JPEG, bv));
                        
                        tag->itemListMap()["covr"] = MP4::Item(covers);
                    }
                    else {
                        tag->itemListMap()["covr"] = NULL;
                    }
                }
            }
        }
        else if ([uppercasePathExtension isEqualToString:@"WAV"]) {
            // WAV
            
            RIFF::WAV::File *file = dynamic_cast<RIFF::WAV::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->tag();
                if (tag) {
                    tag->removeFrames("APIC");
                    if (albumArt != nil && [albumArt length] > 0) {
                        ID3v2::AttachedPictureFrame *picture = new ID3v2::AttachedPictureFrame();
                        
                        ByteVector bv = ByteVector((const char *)[albumArt bytes], [albumArt length]);
                        picture->setPicture(bv);
                        picture->setMimeType(String("image/jpg"));
                        picture->setType(ID3v2::AttachedPictureFrame::FrontCover);
                        
                        tag->addFrame(picture);
                    }
                }
            }
        }
        else if (([uppercasePathExtension isEqualToString:@"AIF"]) || ([uppercasePathExtension isEqualToString:@"AIFC"]) || ([uppercasePathExtension isEqualToString:@"AIFF"])) {
            // AIF, AIFC, AIFF
            
            RIFF::AIFF::File *file = dynamic_cast<RIFF::AIFF::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->tag();
                if (tag) {
                    tag->removeFrames("APIC");
                    if (albumArt != nil && [albumArt length] > 0) {
                        ID3v2::AttachedPictureFrame *picture = new ID3v2::AttachedPictureFrame();
                        
                        ByteVector bv = ByteVector((const char *)[albumArt bytes], [albumArt length]);
                        picture->setPicture(bv);
                        picture->setMimeType(String("image/jpg"));
                        picture->setType(ID3v2::AttachedPictureFrame::FrontCover);
                        
                        tag->addFrame(picture);
                    }
                }
            }
        }
        else {
            // MP3
            
            MPEG::File *file = dynamic_cast<MPEG::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->ID3v2Tag();
                if (tag) {
                    tag->removeFrames("APIC");
                    if (albumArt != nil && [albumArt length] > 0) {
                        ID3v2::AttachedPictureFrame *picture = new ID3v2::AttachedPictureFrame();
                        
                        ByteVector bv = ByteVector((const char *)[albumArt bytes], [albumArt length]);
                        picture->setPicture(bv);
                        picture->setMimeType(String("image/jpg"));
                        picture->setType(ID3v2::AttachedPictureFrame::FrontCover);
                        
                        tag->addFrame(picture);
                    }
                }
            }
        }
    }
}
- (NSString *)lyrics
{
    if (!_file->isNull()) {
        NSString *uppercasePathExtension = [[self.path pathExtension]uppercaseString];
        
        if (([uppercasePathExtension isEqualToString:@"M4A"]) ||
            ([uppercasePathExtension isEqualToString:@"M4R"]) ||
            ([uppercasePathExtension isEqualToString:@"M4B"]) ||
            ([uppercasePathExtension isEqualToString:@"M4P"]) ||
            ([uppercasePathExtension isEqualToString:@"MP4"]) ||
            ([uppercasePathExtension isEqualToString:@"3G2"]) ||
            ([uppercasePathExtension isEqualToString:@"AAC"])) {
            
            // M4A, M4R, M4B, M4P, MP4, 3G2, AAC
            
            MP4::File *file = dynamic_cast<MP4::File *>(_file->file());
            if (file != NULL) {
                MP4::Tag *tag = file->tag();
                if (tag) {
                    MP4::Item lyricsItem = tag->itemListMap()["\251lyr"];
                    if (lyricsItem.isValid()) {
                        StringList stringList = lyricsItem.toStringList();
                        if (!stringList.isEmpty()) {
                            String lyrics = stringList.front();
                            if (!lyrics.isEmpty()) {
                                return NSStr(lyrics);
                            }
                        }
                    }
                }
            }
        }
        else if ([uppercasePathExtension isEqualToString:@"WAV"]) {
            // WAV
            
            RIFF::WAV::File *file = dynamic_cast<RIFF::WAV::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->tag();
                if (tag) {
                    ID3v2::FrameList frameList = tag->frameListMap()["USLT"];
                    ID3v2::UnsynchronizedLyricsFrame *lyrics = NULL;
                    
                    if (!frameList.isEmpty() && NULL != (lyrics = dynamic_cast<ID3v2::UnsynchronizedLyricsFrame *>(frameList.front()))) {
                        String str = lyrics->text();
                        return NSStr(str);
                    }
                }
            }
        }
        else if (([uppercasePathExtension isEqualToString:@"AIF"]) || ([uppercasePathExtension isEqualToString:@"AIFC"]) || ([uppercasePathExtension isEqualToString:@"AIFF"])) {
            // AIF, AIFC, AIFF
            
            RIFF::AIFF::File *file = dynamic_cast<RIFF::AIFF::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->tag();
                if (tag) {
                    ID3v2::FrameList frameList = tag->frameListMap()["USLT"];
                    ID3v2::UnsynchronizedLyricsFrame *lyrics = NULL;
                    
                    if (!frameList.isEmpty() && NULL != (lyrics = dynamic_cast<ID3v2::UnsynchronizedLyricsFrame *>(frameList.front()))) {
                        String str = lyrics->text();
                        return NSStr(str);
                    }
                }
            }
        }
        else {
            // MP3
            
            MPEG::File *file = dynamic_cast<MPEG::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->ID3v2Tag();
                if (tag) {
                    ID3v2::FrameList frameList = tag->frameListMap()["USLT"];
                    ID3v2::UnsynchronizedLyricsFrame *lyrics = NULL;
                    
                    if (!frameList.isEmpty() && NULL != (lyrics = dynamic_cast<ID3v2::UnsynchronizedLyricsFrame *>(frameList.front()))) {
                        String str = lyrics->text();
                        return NSStr(str);
                    }
                }
            }
        }
    }
    return nil;
}
- (void)setLyrics:(NSString *)lyrics
{
    if (!_file->isNull()) {
        NSString *uppercasePathExtension = [[self.path pathExtension]uppercaseString];
        
        if (([uppercasePathExtension isEqualToString:@"M4A"]) ||
            ([uppercasePathExtension isEqualToString:@"M4R"]) ||
            ([uppercasePathExtension isEqualToString:@"M4B"]) ||
            ([uppercasePathExtension isEqualToString:@"M4P"]) ||
            ([uppercasePathExtension isEqualToString:@"MP4"]) ||
            ([uppercasePathExtension isEqualToString:@"3G2"]) ||
            ([uppercasePathExtension isEqualToString:@"AAC"])) {
            
            // M4A, M4R, M4B, M4P, MP4, 3G2, AAC
            
            MP4::File *file = dynamic_cast<MP4::File *>(_file->file());
            if (file != NULL) {
                MP4::Tag *tag = file->tag();
                if (tag) {
                    if (lyrics != nil && [lyrics length] > 0) {
                        StringList stringList = StringList(TLStr(lyrics));
                        MP4::Item lyricsItem = MP4::Item(stringList);
                        tag->itemListMap()["\251lyr"] = lyricsItem;
                    }
                    else {
                        tag->itemListMap()["\251lyr"] = NULL;
                    }
                }
            }
        }
        else if ([uppercasePathExtension isEqualToString:@"WAV"]) {
            // WAV
            
            RIFF::WAV::File *file = dynamic_cast<RIFF::WAV::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->tag();
                if (tag) {
                    tag->removeFrames("USLT");
                    if (lyrics != nil && [lyrics length] > 0) {
                        ID3v2::UnsynchronizedLyricsFrame *lyricsFrame = new ID3v2::UnsynchronizedLyricsFrame();
                        lyricsFrame->setText(TLStr(lyrics));
                        tag->addFrame(lyricsFrame);
                    }
                }
            }
        }
        else if (([uppercasePathExtension isEqualToString:@"AIF"]) || ([uppercasePathExtension isEqualToString:@"AIFC"]) || ([uppercasePathExtension isEqualToString:@"AIFF"])) {
            // AIF, AIFC, AIFF
            
            RIFF::AIFF::File *file = dynamic_cast<RIFF::AIFF::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->tag();
                if (tag) {
                    tag->removeFrames("USLT");
                    if (lyrics != nil && [lyrics length] > 0) {
                        ID3v2::UnsynchronizedLyricsFrame *lyricsFrame = new ID3v2::UnsynchronizedLyricsFrame();
                        lyricsFrame->setText(TLStr(lyrics));
                        tag->addFrame(lyricsFrame);
                    }
                }
            }
        }
        else {
            // MP3
            
            MPEG::File *file = dynamic_cast<MPEG::File *>(_file->file());
            if (file != NULL) {
                ID3v2::Tag *tag = file->ID3v2Tag();
                if (tag) {
                    tag->removeFrames("USLT");
                    if (lyrics != nil && [lyrics length] > 0) {
                        ID3v2::UnsynchronizedLyricsFrame *lyricsFrame = new ID3v2::UnsynchronizedLyricsFrame();
                        lyricsFrame->setText(TLStr(lyrics));
                        tag->addFrame(lyricsFrame);
                    }
                }
            }
        }
    }
}

#pragma mark Read-only properties

- (int)bitrate {
    if (_file->isNull()) return 0; else return _file->audioProperties()->bitrate();
}

- (int)channels {
    if (_file->isNull()) return 0; else return _file->audioProperties()->channels();
}

- (int)duration {
    if (_file->isNull()) return 0; else return _file->audioProperties()->length();
}

- (int)sampleRate {
    if (_file->isNull()) return 0; else return _file->audioProperties()->sampleRate();
}

- (BOOL)validTags {
    return ((!_file->isNull()) && (!_file->tag()->isEmpty()));
}

@end
