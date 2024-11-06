//
//  SearchController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 12/23/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SearchController.h"
#import "SingleAlbumViewController.h"
#import "AlbumsViewController.h"
#import "PlaylistsDetailViewController.h"
#import "DataManager.h"
#import "Artist.h"
#import "Album.h"
#import "Album+Extensions.h"
#import "File.h"
#import "File+Extensions.h"
#import "Playlist.h"
#import "PlaylistItem.h"
#import "ArtworkCell.h"
#import "SettingsViewController.h"
#import "ArtistsViewController.h"
#import "PlayerViewController.h"
#import "ThumbnailLoader.h"
#import "Player.h"
#import "OptionsActionSheetHandler.h"
#import "SkinManager.h"
#import "StandardCell.h"
#import "UIViewController+NibSelect.h"
#import "Modes.h"
#import "SongSelectorDelegate.h"
#import "VisibilityViewController.h"
#import "NSArray+Equivalence.h"
#import "UIViewController+SafeModal.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface SearchController ()

@property (nonatomic, strong) NSFetchedResultsController *artistsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *albumsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *songsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *playlistsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *artistsEditingFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *albumsEditingFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *songsEditingFetchedResultsController;
@property (nonatomic, strong) Artist *selectedArtist;
@property (nonatomic, strong) Album *selectedAlbum;
@property (nonatomic, strong) Playlist *selectedPlaylist;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)visibilityViewControllerModeDidChange;
- (void)nowPlayingFileDidChange;
- (kMode)mode;
- (void)updateSections;
- (NSArray *)arrayForSection:(NSInteger)section;
- (NSArray *)songsForArtist:(Artist *)artist;
- (NSArray *)songsForAlbum:(Album *)album;
- (NSFetchedResultsController *)artistsFetchedResultsController;
- (NSFetchedResultsController *)albumsFetchedResultsController;
- (NSFetchedResultsController *)songsFetchedResultsController;
- (NSFetchedResultsController *)playlistsFetchedResultsController;
- (NSArray *)sortedSongsForAlbum:(Album *)album;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation SearchController

// Public
@synthesize delegate;
@synthesize songSelectorDelegate;

// Private
@synthesize artistsFetchedResultsController;
@synthesize albumsFetchedResultsController;
@synthesize songsFetchedResultsController;
@synthesize playlistsFetchedResultsController;
@synthesize artistsEditingFetchedResultsController;
@synthesize albumsEditingFetchedResultsController;
@synthesize songsEditingFetchedResultsController;
@synthesize selectedArtist;
@synthesize selectedAlbum;
@synthesize selectedPlaylist;

- (id)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(groupByAlbumArtistPreferenceDidChange) name:kGroupByAlbumArtistPreferenceDidChangeNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(visibilityViewControllerModeDidChange) name:kVisibilityViewControllerModeDidChangeNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(nowPlayingFileDidChange) name:kPlayerNowPlayingFileDidChangeNotification object:nil];
    }
    return self;
}

// This implementation should not exist because this situation should never actually happen (ideally).
// However, I've included it just in case, as well as for the sake of compatibility if this becomes possible in a future version of the app.

- (void)groupByAlbumArtistPreferenceDidChange {
    // The search bar must have text for the fetch request to go through.
    if ([[[self delegate]searchControllerSearchBar]text]) {
        [self updateSections];
        [[[self delegate]tableView]performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

- (void)visibilityViewControllerModeDidChange {
    // The search bar must have text for the fetch request to go through.
    if ([[[self delegate]searchControllerSearchBar]text]) {
        // This is unnecessary since the fetched results controller getter functions switch between the main and editing instances automatically, eliminating the need for reloading when changing modes.
        // [self updateSections];
        [[[self delegate]tableView]performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

- (void)nowPlayingFileDidChange {
    [[[self delegate]tableView]performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (kMode)mode {
    return [songSelectorDelegate songSelectorMode];
}

- (void)updateSections {
    // This sets the fetched results controllers to nil.
    [self didFinishSearching];
    
    // The fetched results controllers automatically fetch new objects when they are initialized, so calling performFetch: is unnecessary.
    [self artistsFetchedResultsController];
    [self albumsFetchedResultsController];
    [self songsFetchedResultsController];
    [self playlistsFetchedResultsController];
}

- (void)didFinishSearching {
    artistsFetchedResultsController = nil;
    artistsEditingFetchedResultsController = nil;
    
    albumsFetchedResultsController = nil;
    albumsEditingFetchedResultsController = nil;
    
    songsFetchedResultsController = nil;
    songsEditingFetchedResultsController = nil;
    
    playlistsFetchedResultsController = nil;
}

- (NSArray *)arrayForSection:(NSInteger)section {
    switch (section) {
        case 1:
            return [[self artistsFetchedResultsController]fetchedObjects];
        case 2:
            return [[self albumsFetchedResultsController]fetchedObjects];
        case 3:
            return [[self songsFetchedResultsController]fetchedObjects];
        case 4:
            return [[self playlistsFetchedResultsController]fetchedObjects];
        default:
            return 0;
    }
}

#pragma mark -
#pragma mark - Table view data source

// Ingenious hack for optional delegate method implementation
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(tableView:viewForHeaderInSection:)) {
        return [SkinManager iOS6Skin];
    }
    else {
        return [super respondsToSelector:aSelector];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        if ([[self arrayForSection:section]count] > 0) {
            if ([SkinManager iOS6Skin]) {
                return 26;
            }
            else {
                return 22;
            }
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ((tableView.dataSource) && ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)])) {
        NSString *title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        if ([title length] > 0) {
            UIImageView *sectionHeaderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 26)];
            sectionHeaderImageView.image = [UIImage imageNamed:@"Table_View_Section_Header-6"];
            
            UILabel *sectionTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, (tableView.frame.size.width - 40), 25)];
            sectionTitleLabel.font = [UIFont boldSystemFontOfSize:15];
            sectionTitleLabel.textColor = [SkinManager iOS6SkinTableViewSectionHeaderTextColor];
            sectionTitleLabel.shadowColor = [SkinManager iOS6SkinTableViewSectionHeaderShadowColor];
            sectionTitleLabel.shadowOffset = CGSizeMake(0, 1);
            sectionTitleLabel.backgroundColor = [UIColor clearColor];
            sectionTitleLabel.text = title;
            [sectionHeaderImageView addSubview:sectionTitleLabel];
            return sectionHeaderImageView;
        }
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        NSInteger artistCount = [[[self artistsFetchedResultsController]fetchedObjects]count];
        if (artistCount == 1) {
            return [NSString stringWithFormat:NSLocalizedString(@"SEARCH_RESULT_SECTION_TITLE_ARTIST", @""), [NSNumber numberWithInteger:artistCount]];
        }
        else {
            return [NSString stringWithFormat:NSLocalizedString(@"SEARCH_RESULT_SECTION_TITLE_ARTISTS", @""), [NSNumber numberWithInteger:artistCount]];
        }
    }
    else if (section == 2) {
        NSInteger albumCount = [[[self albumsFetchedResultsController]fetchedObjects]count];
        if (albumCount == 1) {
            return [NSString stringWithFormat:NSLocalizedString(@"SEARCH_RESULT_SECTION_TITLE_ALBUM", @""), [NSNumber numberWithInteger:albumCount]];
        }
        else { 
            return [NSString stringWithFormat:NSLocalizedString(@"SEARCH_RESULT_SECTION_TITLE_ALBUMS", @""), [NSNumber numberWithInteger:albumCount]];
        }
    }
    else if (section == 3) {
        NSInteger songCount = [[[self songsFetchedResultsController]fetchedObjects]count];
        if (songCount == 1) {
            return [NSString stringWithFormat:NSLocalizedString(@"SEARCH_RESULT_SECTION_TITLE_SONG", @""), [NSNumber numberWithInteger:songCount]];
        }
        else {
            return [NSString stringWithFormat:NSLocalizedString(@"SEARCH_RESULT_SECTION_TITLE_SONGS", @""), [NSNumber numberWithInteger:songCount]];
        }
    }
    else if (section == 4) {
        NSInteger playlistCount = [[[self playlistsFetchedResultsController]fetchedObjects]count];
        if (playlistCount == 1) {
            return [NSString stringWithFormat:NSLocalizedString(@"SEARCH_RESULT_SECTION_TITLE_PLAYLIST", @""), [NSNumber numberWithInteger:playlistCount]];
        }
        else {
            return [NSString stringWithFormat:NSLocalizedString(@"SEARCH_RESULT_SECTION_TITLE_PLAYLISTS", @""), [NSNumber numberWithInteger:playlistCount]];
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        if ([delegate mode] == kVisibilityViewControllerModeMultiEdit) {
            return 1;
        }
        return 0;
    }
    
    return [[self arrayForSection:section]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // The "Search" prefix helps prevent cells in the regular table view from being re-used in the search table view, potentially causing the app to crash.
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Search Cell 1";
        
        StandardCell *cell = (StandardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[StandardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textLabel.text = @"Select All";
        
        return cell;
    }
    else {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Search Cell %i", (indexPath.section + 1)];
        
        ArtworkCell *cell = (ArtworkCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ArtworkCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.section != 0);
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        DataManager *dataManager = [DataManager sharedDataManager];
        
        id item = [[self arrayForSection:indexPath.section]objectAtIndex:indexPath.row];
        if ([item isKindOfClass:[Artist class]]) {
            Artist *artist = item;
            
            NSSet *files = nil;
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                files = [artist filesForAlbumArtistGroup];
            }
            else {
                files = [artist filesForArtistGroup];
            }
            
            if ([[files filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"iPodMusicLibraryFile == %@", [NSNumber numberWithBool:YES]]]count] > 0) {
                UIAlertView *cannotDeleteAlert = [[UIAlertView alloc]
                                                  initWithTitle:@"Cannot Delete Artist"
                                                  message:@"You cannot delete artists with songs from your iPod music library."
                                                  delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
                [cannotDeleteAlert show];
                
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else {
                [dataManager deleteArtist:artist];
            }
        }
        else if ([item isKindOfClass:[Album class]]) {
            Album *album = item;
            
            NSSet *files = nil;
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                files = [album filesForAlbumArtistGroup];
            }
            else {
                files = [album filesForArtistGroup];
            }
            
            if ([[files filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"iPodMusicLibraryFile == %@", [NSNumber numberWithBool:YES]]]count] > 0) {
                UIAlertView *cannotDeleteAlert = [[UIAlertView alloc]
                                                  initWithTitle:@"Cannot Delete Album"
                                                  message:@"You cannot delete albums with songs from your iPod music library."
                                                  delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
                [cannotDeleteAlert show];
                
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else {
                [dataManager deleteAlbum:album];
            }
        }
        else if ([item isKindOfClass:[File class]]) {
            File *file = item;
            
            if ([file.iPodMusicLibraryFile boolValue]) {
                UIAlertView *cannotDeleteAlert = [[UIAlertView alloc]
                                                  initWithTitle:@"Cannot Delete Song"
                                                  message:@"You cannot delete songs from your iPod music library."
                                                  delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
                [cannotDeleteAlert show];
                
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else {
                [dataManager deleteFile:file];
            }
        }
        else {
            Playlist *playlist = item;
            [dataManager deletePlaylist:playlist];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    UISearchBar *searchBar = [delegate searchControllerSearchBar];
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        NSMutableArray *selectedItemsArray = [NSMutableArray arrayWithObjects:nil];
        NSMutableArray *selectedFilesArray = [NSMutableArray arrayWithObjects:nil];
        
        NSArray *artistsArray = [[self artistsFetchedResultsController]fetchedObjects];
        for (int i = 0; i < [artistsArray count]; i++) {
            Artist *artist = [artistsArray objectAtIndex:i];
            [selectedItemsArray addObject:artist];
            [selectedFilesArray addObjectsFromArray:[self songsForArtist:artist]];
        }
        
        NSArray *albumsArray = [[self albumsFetchedResultsController]fetchedObjects];
        for (int i = 0; i < [albumsArray count]; i++) {
            Album *album = [albumsArray objectAtIndex:i];
            [selectedItemsArray addObject:album];
            [selectedFilesArray addObjectsFromArray:[self songsForAlbum:album]];
        }
        
        NSArray *filesArray = [[self songsFetchedResultsController]fetchedObjects];
        for (int i = 0; i < [filesArray count]; i++) {
            File *file = [filesArray objectAtIndex:i];
            [selectedItemsArray addObject:file];
            [selectedFilesArray addObject:file];
        }
        
        if ([[delegate selectedItemsArray]containsObjectsInArray:selectedItemsArray]) {
            [[delegate selectedItemsArray]removeAllObjects];
            [[delegate selectedFilesArray]removeAllObjects];
        }
        else {
            [[delegate selectedItemsArray]setArray:selectedItemsArray];
            [[delegate selectedFilesArray]setArray:selectedFilesArray];
        }
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([tableView numberOfSections] - 1))] withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        NSArray *sectionArray = [self arrayForSection:indexPath.section];
        id item = [sectionArray objectAtIndex:indexPath.row];
        
        if ([delegate mode] == kVisibilityViewControllerModeMultiEdit) {
            if ([item isKindOfClass:[Artist class]]) {
                Artist *artist = item;
                
                if (![[delegate selectedItemsArray]containsObject:artist]) {
                    [[delegate selectedItemsArray]addObject:artist];
                    [[delegate selectedFilesArray]addObjectsFromArray:[self songsForArtist:artist]];
                }
                else {
                    [[delegate selectedItemsArray]removeObject:artist];
                    [[delegate selectedFilesArray]removeObjectsInArray:[self songsForArtist:artist]];
                }
            }
            else if ([item isKindOfClass:[Album class]]) {
                Album *album = item;
                
                if (![[delegate selectedItemsArray]containsObject:album]) {
                    [[delegate selectedItemsArray]addObject:album];
                    [[delegate selectedFilesArray]addObjectsFromArray:[self songsForAlbum:album]];
                }
                else {
                    [[delegate selectedItemsArray]removeObject:album];
                    [[delegate selectedFilesArray]removeObjectsInArray:[self songsForAlbum:album]];
                }
            }
            else {
                File *file = item;
                
                if (![[delegate selectedItemsArray]containsObject:file]) {
                    [[delegate selectedItemsArray]addObject:file];
                    [[delegate selectedFilesArray]addObject:file];
                }
                else {
                    [[delegate selectedItemsArray]removeObject:file];
                    [[delegate selectedFilesArray]removeObject:file];
                }
            }
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            if ([item isKindOfClass:[Artist class]]) {
                selectedArtist = item;
                
                if ([selectedArtist.albums count] == 1) {
                    selectedAlbum = [[selectedArtist.albums allObjects]objectAtIndex:0];
                    
                    SingleAlbumViewController *singleAlbumViewController = [[SingleAlbumViewController alloc]initWithDelegate:self];
                    singleAlbumViewController.songSelectorDelegate = songSelectorDelegate;
                    singleAlbumViewController.title = selectedArtist.name;
                    [[delegate searchControllerNavigationController]pushViewController:singleAlbumViewController animated:YES];
                }
                else {
                    AlbumsViewController *albumsViewController = [[AlbumsViewController alloc]initWithDelegate:self];
                    albumsViewController.songSelectorDelegate = songSelectorDelegate;
                    albumsViewController.title = selectedArtist.name;
                    [[delegate searchControllerNavigationController]pushViewController:albumsViewController animated:YES];
                }
            }
            else if ([item isKindOfClass:[Album class]]) {
                selectedAlbum = item;
                
                SingleAlbumViewController *singleAlbumViewController = [[SingleAlbumViewController alloc]initWithDelegate:self];
                singleAlbumViewController.songSelectorDelegate = songSelectorDelegate;
                singleAlbumViewController.title = selectedAlbum.name;
                [[delegate searchControllerNavigationController]pushViewController:singleAlbumViewController animated:YES];
            }
            else if ([item isKindOfClass:[File class]]) {
                File *file = item;
                
                if ([delegate mode] == kVisibilityViewControllerModeAddToPlaylist) {
                    [songSelectorDelegate songSelectorDidSelectFile:file];
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                else {
                    Album *album = nil;
                    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                        album = file.albumRefForAlbumArtistGroup;
                    }
                    else {
                        album = file.albumRefForArtistGroup;
                    }
                    
                    NSArray *filesArray = [self sortedSongsForAlbum:album];
                    
                    Player *player = [Player sharedPlayer];
                    [player setPlaylistItems:filesArray];
                    [player setCurrentFileWithIndex:[filesArray indexOfObject:file]];
                    
                    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibBaseName:@"PlayerViewController" bundle:nil];
                    [delegate.navigationController pushViewController:playerViewController animated:YES];
                }
            }
            else {
                selectedPlaylist = item;
                
                PlaylistsDetailViewController *playlistsDetailViewController = [[PlaylistsDetailViewController alloc]initWithDelegate:self];
                playlistsDetailViewController.songSelectorDelegate = songSelectorDelegate;
                playlistsDetailViewController.title = selectedPlaylist.name;
                [[delegate searchControllerNavigationController]pushViewController:playlistsDetailViewController animated:YES];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSArray *files = nil;
    
    NSArray *sectionArray = [self arrayForSection:indexPath.section];
    id item = [sectionArray objectAtIndex:indexPath.row];
    if (([item isKindOfClass:[Artist class]]) || ([item isKindOfClass:[Album class]])) {
        NSString *searchString = nil;
        
        if ([item isKindOfClass:[Artist class]]) {
            Artist *artist = item;
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                files = [artist.filesForAlbumArtistGroup allObjects];
            }
            else {
                files = [artist.filesForArtistGroup allObjects];
            }
            
            searchString = artist.name;
        }
        else {
            Album *album = item;
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                files = [album.filesForAlbumArtistGroup allObjects];
            }
            else {
                files = [album.filesForArtistGroup allObjects];
            }
            
            searchString = album.name;
        }
        
        [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForMultipleFiles:files fromIndexPath:indexPath inTableView:tableView searchString:searchString canDelete:NO];
    }
    else {
        [[OptionsActionSheetHandler sharedHandler]presentOptionsActionSheetForFiles:[[self songsFetchedResultsController]fetchedObjects] fileIndex:indexPath.row fromIndexPath:indexPath inTableView:tableView canDelete:NO];
    }
}

- (NSArray *)songsForArtist:(Artist *)artist {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        return [artist.filesForAlbumArtistGroup allObjects];
    }
    else {
        return [artist.filesForArtistGroup allObjects];
    }
}

- (NSArray *)songsForAlbum:(Album *)album {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        return [album.filesForAlbumArtistGroup allObjects];
    }
    else {
        return [album.filesForArtistGroup allObjects];
    }
}

#pragma mark -
#pragma mark Albums view controller delegate

- (Artist *)albumsViewControllerArtist {
    return selectedArtist;
}

#pragma mark -
#pragma mark Single album view controller delegate

- (Album *)singleAlbumViewControllerAlbum {
    return selectedAlbum;
}

#pragma mark -
#pragma mark Playlists detail view controller delegate

- (Playlist *)playlistsDetailViewControllerPlaylist {
    return selectedPlaylist;
}

#pragma mark -
#pragma mark - Fetched results controllers

- (NSFetchedResultsController *)artistsFetchedResultsController {
    if (([[self delegate]mode] == kVisibilityViewControllerModeEdit) || ([[self delegate]mode] == kVisibilityViewControllerModeMultiEdit)) {
        if (!artistsEditingFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Artist" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            NSString *searchText = [[delegate searchControllerSearchBar]text];
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == %@) AND (SUBQUERY(filesForAlbumArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0) AND (name contains[cd] %@)", groupByAlbumArtist, [NSNumber numberWithBool:YES], searchText]];
            }
            else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == %@) AND (SUBQUERY(filesForArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0) AND (name contains[cd] %@)", groupByAlbumArtist, [NSNumber numberWithBool:YES], searchText]];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            aFetchedResultsController.delegate = self;
            artistsEditingFetchedResultsController = aFetchedResultsController;
            
            NSError *error = nil;
            if (![artistsEditingFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        return artistsEditingFetchedResultsController;
    }
    else {
        if (!artistsFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Artist" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            NSString *searchText = [[delegate searchControllerSearchBar]text];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == %@) AND (name contains[cd] %@)", groupByAlbumArtist, searchText]];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            aFetchedResultsController.delegate = self;
            artistsFetchedResultsController = aFetchedResultsController;
            
            NSError *error = nil;
            if (![artistsFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        return artistsFetchedResultsController;
    }
}

- (NSFetchedResultsController *)albumsFetchedResultsController {
    if (([[self delegate]mode] == kVisibilityViewControllerModeEdit) || ([[self delegate]mode] == kVisibilityViewControllerModeMultiEdit)) {
        if (!albumsEditingFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artist.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, artistSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            NSString *searchText = [[delegate searchControllerSearchBar]text];
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == %@) AND (SUBQUERY(filesForAlbumArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0) AND (name contains[cd] %@)", groupByAlbumArtist, [NSNumber numberWithBool:YES], searchText]];
            }
            else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == %@) AND (SUBQUERY(filesForArtistGroup, $x, $x.iPodMusicLibraryFile == %@).@count == 0) AND (name contains[cd] %@)", groupByAlbumArtist, [NSNumber numberWithBool:YES], searchText]];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            aFetchedResultsController.delegate = self;
            albumsEditingFetchedResultsController = aFetchedResultsController;
            
            NSError *error = nil;
            if (![albumsEditingFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        return albumsEditingFetchedResultsController;
    }
    else {
        if (!albumsFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artist.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, artistSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSNumber *groupByAlbumArtist = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]];
            NSString *searchText = [[delegate searchControllerSearchBar]text];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(groupByAlbumArtist == %@) AND (name contains[cd] %@)", groupByAlbumArtist, searchText]];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            aFetchedResultsController.delegate = self;
            albumsFetchedResultsController = aFetchedResultsController;
            
            NSError *error = nil;
            if (![albumsFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        return albumsFetchedResultsController;
    }
}

- (NSFetchedResultsController *)songsFetchedResultsController {
    if (([[self delegate]mode] == kVisibilityViewControllerModeEdit) || ([[self delegate]mode] == kVisibilityViewControllerModeMultiEdit)) {
        if (!songsEditingFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumName" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistName" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumArtistName" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:titleSortDescriptor, albumSortDescriptor, artistSortDescriptor, albumArtistSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSString *searchText = [[delegate searchControllerSearchBar]text];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(iPodMusicLibraryFile == %@) AND (title contains[cd] %@)", [NSNumber numberWithBool:NO], searchText]];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            aFetchedResultsController.delegate = self;
            songsEditingFetchedResultsController = aFetchedResultsController;
            
            NSError *error = nil;
            if (![songsEditingFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        return songsEditingFetchedResultsController;
    }
    else {
        if (!songsFetchedResultsController) {
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumName" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *artistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistName" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *albumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumArtistName" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:titleSortDescriptor, albumSortDescriptor, artistSortDescriptor, albumArtistSortDescriptor, nil];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSString *searchText = [[delegate searchControllerSearchBar]text];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText]];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            aFetchedResultsController.delegate = self;
            songsFetchedResultsController = aFetchedResultsController;
            
            NSError *error = nil;
            if (![songsFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        return songsFetchedResultsController;
    }
}

- (NSFetchedResultsController *)playlistsFetchedResultsController {
    if (!playlistsFetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", [[delegate searchControllerSearchBar]text]]];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        playlistsFetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        if (![playlistsFetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return playlistsFetchedResultsController;
}

- (NSArray *)sortedSongsForAlbum:(Album *)album {
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *trackSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"track" ascending:YES];
    NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *albumByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *albumByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"albumRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *artistByAlbumArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForAlbumArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *artistByArtistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistRefForArtistGroup.name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *creationDateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:trackSortDescriptor, titleSortDescriptor, albumByAlbumArtistSortDescriptor, albumByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, creationDateSortDescriptor, nil]];
    }
    else {
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:trackSortDescriptor, titleSortDescriptor, albumByArtistSortDescriptor, albumByAlbumArtistSortDescriptor, artistByArtistSortDescriptor, artistByAlbumArtistSortDescriptor, creationDateSortDescriptor, nil]];
    }
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"albumRefForAlbumArtistGroup == %@", album]];
    }
    else {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"albumRefForArtistGroup == %@", album]];
    }
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController.fetchedObjects;
}

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // Multiple sections can be deleted at once, potentially causing the app to crash.
    // To prevent the latter from happening, the sections are updated and the table view is reloaded without animation.
    
    // The main table view is re-used as the search table view, so don't update it if the user isn't searching.
    if (![delegate searching]) return;
    
    // In the simplest, most efficient, case, reload the table view.
    [[delegate searchControllerTableView]reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ArtworkCell *artworkCell = (ArtworkCell *)cell;
    
    // This prevents artwork operations from conflicting with each other if they are using a cell that has been re-used.
    if (artworkCell.artworkOperation) {
        [artworkCell.artworkOperation cancel];
    }
    
    ThumbnailLoader *thumbnailLoader = [ThumbnailLoader sharedThumbnailLoader];
    
    id item = [[self arrayForSection:indexPath.section]objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[Artist class]]) {
        Artist *artist = item;
        artworkCell.textLabel.text = [artist name];
        artworkCell.detailTextLabel.text = nil;
        
        artworkCell.artworkOperation = [thumbnailLoader loadThumbnailForCell:artworkCell atIndexPath:indexPath inTableView:[delegate searchControllerTableView] artworkContainer:artist];
    }
    else if ([item isKindOfClass:[Album class]]) {
        Album *album = item;
        artworkCell.textLabel.text = album.name;
        artworkCell.detailTextLabel.text = album.artist.name;
        
        artworkCell.artworkOperation = [thumbnailLoader loadThumbnailForCell:artworkCell atIndexPath:indexPath inTableView:[delegate searchControllerTableView] artworkContainer:album];
    }
    else if ([item isKindOfClass:[File class]]) {
        File *file = item;
        
        artworkCell.textLabel.text = file.title;
        
        artworkCell.artworkOperation = [thumbnailLoader loadThumbnailForCell:artworkCell atIndexPath:indexPath inTableView:[delegate searchControllerTableView] artworkContainer:file];
        
        // The song's individual artist should be shown regardless of how the songs are grouped, so the artistRefForArtistGroup variable is always used.
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
            artworkCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", file.albumRefForAlbumArtistGroup.name, file.artistRefForArtistGroup.name];
        }
        else {
            artworkCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", file.albumRefForArtistGroup.name, file.artistRefForArtistGroup.name];
        }
        
        if ([self mode] == kModeMain) {
            artworkCell.accessoryView = nil;
            artworkCell.textLabel.alpha = 1;
        }
        else {
            UIImageView *addButtonAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 29, 29)];
            addButtonAccessoryView.contentMode = UIViewContentModeCenter;
            addButtonAccessoryView.image = [UIImage iOS7SkinImageNamed:@"Add_Button"];
            addButtonAccessoryView.highlightedImage = [UIImage iOS7SkinImageNamed:@"Add_Button-Selected"];
            artworkCell.accessoryView = addButtonAccessoryView;
            
            if ([[songSelectorDelegate songSelectorSelectedFiles]containsObject:file]) {
                artworkCell.textLabel.alpha = (1.0 / 3.0);
                artworkCell.detailTextLabel.alpha = (2.0 / 3.0);
            }
            else {
                artworkCell.textLabel.alpha = 1;
                artworkCell.detailTextLabel.alpha = 1;
            }
        }
        
        artworkCell.nowPlayingImageView.hidden = ![[[Player sharedPlayer]nowPlayingFile]isEqual:file];
    }
    else {
        Playlist *playlist = item;
        artworkCell.textLabel.text = playlist.name;
        artworkCell.detailTextLabel.text = nil;
        
        artworkCell.artworkOperation = [thumbnailLoader loadThumbnailForCell:artworkCell atIndexPath:indexPath inTableView:[delegate searchControllerTableView] artworkContainer:playlist];
    }
    
    if ([self mode] == kModeMain) {
        if ([item isKindOfClass:[Playlist class]]) {
            artworkCell.editingAccessoryType = UITableViewCellAccessoryNone;
        }
        else {
            artworkCell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        
        artworkCell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([delegate mode] == kVisibilityViewControllerModeEdit) {
            artworkCell.checkmarkOverlayView.hidden = YES;
        }
        else if ([delegate mode] == kVisibilityViewControllerModeMultiEdit) {
            artworkCell.checkmarkOverlayView.hidden = ![[delegate selectedItemsArray]containsObject:item];
        }
        else {
            artworkCell.checkmarkOverlayView.hidden = YES;
        }
    }
}

- (void)dealloc {
    artistsFetchedResultsController.delegate = nil;
    artistsEditingFetchedResultsController.delegate = nil;
    albumsFetchedResultsController.delegate = nil;
    albumsEditingFetchedResultsController.delegate = nil;
    songsFetchedResultsController.delegate = nil;
    songsEditingFetchedResultsController.delegate = nil;
    playlistsFetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
