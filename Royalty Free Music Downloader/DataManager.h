//
//  DataManager.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/30/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class Directory;
@class Archive;
@class File;
@class Album;
@class Artist;
@class Genre;
@class GenreAlbum;
@class GenreArtist;
@class Playlist;
@class PlaylistItem;
@class Download;
@class BookmarkItem;
@class Bookmark;
@class BookmarkFolder;

enum {
    kLibraryUpdateTypeComplete = 0,
    kLibraryUpdateTypeFiles,
    kLibraryUpdateTypeiPodMusicLibrary
};
typedef NSUInteger kLibraryUpdateType;

@interface DataManager : NSObject <NSFetchedResultsControllerDelegate> {
@public
    NSManagedObjectContext *managedObjectContext;
    BOOL backgroundOperationIsActive;
@private
    NSManagedObjectContext *backgroundManagedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSMutableArray *backgroundContextPendingMergeNotifications;
    NSInteger currentItemIndex;
    NSInteger currentSingleItemIndex;
    BOOL libraryDidChangeAlertShown;
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (readwrite) BOOL backgroundOperationIsActive;

+ (DataManager *)sharedDataManager;
- (NSInteger)fileCount;
- (void)runInitialLibraryUpdate;
- (void)updateLibraryWithUpdateType:(kLibraryUpdateType)updateType;
- (void)removeiPodMusicLibrarySongs;
- (File *)importItemAtPathIfApplicable:(NSString *)path;
- (BOOL)createDirectoryWithName:(NSString *)name parentDirectory:(Directory *)parentDirectory;
- (BOOL)renameDirectory:(Directory *)directory newName:(NSString *)newName;
- (BOOL)renameArchive:(Archive *)archive newName:(NSString *)newName;
- (void)createBookmarkWithName:(NSString *)name url:(NSString *)url parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder;
- (void)createBookmarkFolderWithName:(NSString *)name parentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder;
- (void)createFileObjectWithAlbumArtistName:(NSString *)albumArtistName
                                  albumName:(NSString *)albumName
                                 artistName:(NSString *)artistName
                                    bitRate:(NSNumber *)bitRate
                                   duration:(NSNumber *)duration
                                      genre:(NSString *)genre
                       iPodMusicLibraryFile:(BOOL)iPodMusicLibraryFile
                                     lyrics:(NSString *)lyrics
                               persistentID:(NSNumber *)persistentID
                                  playCount:(NSNumber *)playCount
                                     rating:(NSNumber *)rating
                                      title:(NSString *)title
                                      track:(NSNumber *)track
                                        url:(NSString *)url
                                       year:(NSNumber *)year;
- (void)updateThumbnailForFile:(File *)file artworkData:(NSData *)artworkData;
- (void)updateRefsForFile:(File *)file;
- (void)deleteDirectory:(Directory *)directory;
- (void)deleteArchive:(Archive *)archive;
- (void)deleteFile:(File *)file;
- (void)deleteFiles:(NSSet *)files;
- (void)deleteAlbum:(Album *)album;
- (void)deleteArtist:(Artist *)artist;
- (void)deleteGenre:(Genre *)genre;
- (void)deleteGenreAlbum:(GenreAlbum *)genreAlbum;
- (void)deleteGenreArtist:(GenreArtist *)genreArtist;
- (void)clearPlaylist:(Playlist *)playlist;
- (void)deletePlaylist:(Playlist *)playlist;
- (void)deletePlaylistItem:(PlaylistItem *)playlistItem;
- (void)deleteDownload:(Download *)download;
- (void)deleteBookmarkItem:(BookmarkItem *)bookmarkItem;
- (void)saveContext;
- (NSArray *)directoriesWithParentDirectory:(Directory *)parentDirectory currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (NSArray *)filesWithParentDirectory:(Directory *)parentDirectory currentManagedObjectContext:(NSManagedObjectContext *)currentManagedObjectContext;
- (NSArray *)bookmarkItemsWithParentBookmarkFolder:(BookmarkFolder *)parentBookmarkFolder;

@end
