//
//  AlbumTrackListView.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 1/6/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "AlbumTrackListView.h"
#import "AlbumTrackListCell.h"
#import "DataManager.h"
#import "File.h"
#import "Album+Extensions.h"
#import "Artist.h"
#import "Player.h"
#import "SettingsViewController.h"
#import "SkinManager.h"
#import "File+Extensions.h"
#import "NSDateFormatter+Duration.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface AlbumTrackListView ()

@property (readwrite) BOOL settingCurrentFile;

- (void)groupByAlbumArtistPreferenceDidChange;
- (void)nowPlayingFileDidChange;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation AlbumTrackListView

// Public
@synthesize delegate;
@synthesize theTableView;
@synthesize fetchedResultsController;

// Private
@synthesize settingCurrentFile;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        theTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        theTableView.dataSource = self;
        theTableView.delegate = self;
        theTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        theTableView.separatorColor = [UIColor colorWithRed:0.986 green:0.933 blue:0.994 alpha:0.10];
        theTableView.showsVerticalScrollIndicator = NO;
        
        UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:theTableView.frame];
        backgroundImageView.image = [UIImage imageNamed:@"Track_List_Table_View_Background"];
        theTableView.backgroundView = backgroundImageView;
        
        [self addSubview:theTableView];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(groupByAlbumArtistPreferenceDidChange) name:kGroupByAlbumArtistPreferenceDidChangeNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(nowPlayingFileDidChange) name:kPlayerNowPlayingFileDidChangeNotification object:nil];
    }
    return self;
}

- (void)groupByAlbumArtistPreferenceDidChange {
    fetchedResultsController = nil;
    
    // Fetch new objects.
    [self fetchedResultsController];
    
    [theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)nowPlayingFileDidChange {
    if (!settingCurrentFile) {
        [theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

- (void)updateTracks {
    // This function is only called by the AlbumFlipSideView class when the now playing file changes. Since the now playing file can change from within this class, it is necessary to check if the user is setting the current file from the track list view or not for the table view cell animation to work properly.
    if (!settingCurrentFile) {
        fetchedResultsController = nil;
        
        // Fetch new objects.
        [self fetchedResultsController];
        
        [theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[self fetchedResultsController]fetchedObjects]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    AlbumTrackListCell *cell = (AlbumTrackListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AlbumTrackListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    settingCurrentFile = YES;
    
    Player *player = [Player sharedPlayer];
    [player setPlaylistItems:[[self fetchedResultsController]fetchedObjects]];
    [player setCurrentFileWithIndex:indexPath.row];
    
    settingCurrentFile = NO;
    
    [[(AlbumTrackListCell *)[tableView cellForRowAtIndexPath:indexPath]nowPlayingImageView]setHidden:NO];
    
    NSMutableArray *visibleRowsArray = [NSMutableArray arrayWithArray:[tableView indexPathsForRowsInRect:CGRectMake(0, tableView.contentOffset.y, tableView.frame.size.width, tableView.frame.size.height)]];
    [visibleRowsArray removeObject:indexPath];
    [tableView reloadRowsAtIndexPaths:visibleRowsArray withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
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
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"albumRefForAlbumArtistGroup == %@", [delegate albumTrackListViewAlbum]]];
        }
        else {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"albumRefForArtistGroup == %@", [delegate albumTrackListViewAlbum]]];
        }
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return fetchedResultsController;
}

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [theTableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    AlbumTrackListCell *theCell = (AlbumTrackListCell *)cell;
    
    File *file = [[self fetchedResultsController]objectAtIndexPath:indexPath];
    
    if (((indexPath.row % 2) == 0) || ([SkinManager iOS7Skin])) {
        theCell.backgroundColor = [UIColor clearColor];
        theCell.contentView.backgroundColor = [UIColor clearColor];
    }
    else {
        theCell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        theCell.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    }
    
    theCell.trackNumberLabel.text = [NSString stringWithFormat:@"%i.", [file standardizedTrack]];
    theCell.titleLabel.text = file.title;
	theCell.durationLabel.text = [NSDateFormatter formattedDuration:[file.duration integerValue]];
    theCell.nowPlayingImageView.hidden = ![[[Player sharedPlayer]nowPlayingFile]isEqual:file];
}

- (void)dealloc {
    fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
