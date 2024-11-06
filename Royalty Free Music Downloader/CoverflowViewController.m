//
//  CoverflowViewController.m
//  Created by Devin Ross on 1/3/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
*/

#import "CoverflowViewController.h"
#import "TabBarController.h"
#import "DataManager.h"
#import "Player.h"
#import "CoverFlowView.h"
#import "ArtworkLoader.h"
#import "File.h"
#import "Album.h"
#import "Album+Extensions.h"
#import "Artist.h"
#import "UIViewController+SafeModal.h"

static NSString *kGroupByAlbumArtistKey = @"Group By Album Artist";

@interface CoverflowViewController ()

@property (nonatomic, strong) IBOutlet UILabel *artistLabel;
@property (nonatomic, strong) IBOutlet UILabel *label2;
@property (nonatomic, strong) IBOutlet UILabel *label3;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;
@property (nonatomic, strong) iCarousel *coverflow;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (readwrite) BOOL collapsed;
@property (readwrite) BOOL flippingAlbum;
@property (readwrite) BOOL albumFlipped;

- (IBAction)infoButtonPressed;
- (IBAction)playButtonPressed;
- (void)playbackStateDidChange;
- (void)nowPlayingFileDidChange;
- (void)updateCoverFlowPositionAnimated:(BOOL)animated;
- (void)flipAlbum;
- (void)didFlipAlbum;
- (TabBarController *)tabBarController;

@end

@implementation CoverflowViewController

@synthesize artistLabel;
@synthesize label2;
@synthesize label3;
@synthesize playButton;
@synthesize infoButton;
@synthesize coverflow;
@synthesize fetchedResultsController;
@synthesize collapsed;
@synthesize flippingAlbum;
@synthesize albumFlipped;

- (IBAction)infoButtonPressed {
    if (!coverflow.decelerating) {
        [self flipAlbum];
    }
}

- (IBAction)playButtonPressed {
    [[Player sharedPlayer]togglePlaybackState];
}

- (void)playbackStateDidChange {
    Player *player = [Player sharedPlayer];
    if ([player playing]) {
        [playButton setImage:[UIImage imageNamed:@"Cover_Flow_Pause_Button"] forState:UIControlStateNormal];
    }
    else {
        [playButton setImage:[UIImage imageNamed:@"Cover_Flow_Play_Button"] forState:UIControlStateNormal];
    }
}

- (void)nowPlayingFileDidChange {
    if (albumFlipped) {
        // This refreshes the labels in case the now playing file has changed to another song in the same album.
        [self carouselCurrentItemIndexDidChange:coverflow];
    }
    else {
        [self updateCoverFlowPositionAnimated:YES];
    }
}

- (void)updateCoverFlowPositionAnimated:(BOOL)animated {
    File *nowPlayingFile = [[Player sharedPlayer]nowPlayingFile];
    if (nowPlayingFile) {
        Album *album = nil;
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
            album = nowPlayingFile.albumRefForAlbumArtistGroup;
        }
        else {
            album = nowPlayingFile.albumRefForArtistGroup;
        }
        
        if (album) {
            NSInteger index = [[[self fetchedResultsController]fetchedObjects]indexOfObject:album];
            if (coverflow.currentItemIndex == index) {
                // This refreshes the labels in case the now playing file has changed to another song in the same album.
                [self carouselCurrentItemIndexDidChange:coverflow];
            }
            else {
                [coverflow scrollToItemAtIndex:index animated:animated];
            }
        }
    }
}

- (void)flipAlbum {
    if (!flippingAlbum) {
        flippingAlbum = YES;
        
        UIView *cover = [coverflow currentItemView];
        if (!cover) {
            return;
        }
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.75];
        
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didFlipAlbum)];
        
        if (albumFlipped) {
            for (CoverFlowAlbumFlipSideView *coverFlowAlbumFlipSideView in cover.subviews) {
                if ([coverFlowAlbumFlipSideView isKindOfClass:[CoverFlowAlbumFlipSideView class]]) {
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cover cache:YES];
                    [coverFlowAlbumFlipSideView removeFromSuperview];
                    break;
                }
            }
        }
        else {
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:cover cache:YES];
            CoverFlowAlbumFlipSideView *coverFlowAlbumFlipSideView = [[CoverFlowAlbumFlipSideView alloc]initWithFrame:CGRectMake(0, 0, cover.frame.size.width, cover.frame.size.height) delegate:self];
            
            // This prevents the user from selecting a song until the album has been flipped.
            coverFlowAlbumFlipSideView.userInteractionEnabled = NO;
            
            [cover addSubview:coverFlowAlbumFlipSideView];
        }
        
        albumFlipped = !albumFlipped;
        [coverflow setScrollEnabled:!albumFlipped];
        
        artistLabel.hidden = albumFlipped;
        label2.hidden = albumFlipped;
        label3.hidden = albumFlipped;
        coverflow.scrollEnabled = !albumFlipped;
        
        [UIView commitAnimations];
    }
}

- (void)didFlipAlbum {
    flippingAlbum = NO;
    
    UIView *cover = [coverflow currentItemView];
    if (!cover) {
        return;
    }
    for (CoverFlowAlbumFlipSideView *coverFlowAlbumFlipSideView in cover.subviews) {
        if ([coverFlowAlbumFlipSideView isKindOfClass:[CoverFlowAlbumFlipSideView class]]) {
            // This allows the user to select a song now that the album has been flipped.
            coverFlowAlbumFlipSideView.userInteractionEnabled = YES;
            break;
        }
    }
}

- (Album *)coverFlowAlbumFlipSideViewAlbum {
    return [[[self fetchedResultsController]fetchedObjects]objectAtIndex:coverflow.currentItemIndex];
}

- (void)coverFlowAlbumFlipSideViewAlbumArtworkButtonPressed {
    [self flipAlbum];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(playbackStateDidChange) name:kPlayerPlaybackStateDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(nowPlayingFileDidChange) name:kPlayerNowPlayingFileDidChangeNotification object:nil];
	
    NSInteger topOffset = 0;
    if ([[[UIDevice currentDevice]systemVersion]compare:@"7.0"] != NSOrderedAscending) {
        topOffset = 20;
    }
    
    coverflow = [[iCarousel alloc]initWithFrame:CGRectMake(0, topOffset, self.view.frame.size.width, (self.view.frame.size.height - topOffset))];
    coverflow.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    coverflow.type = iCarouselTypeCoverFlow;
    coverflow.dataSource = self;
	coverflow.delegate = self;
	
	[self.view insertSubview:coverflow atIndex:0];
    
    [self updateCoverFlowPositionAnimated:NO];
    
    // Make sure the play/pause button's image is consistent with the current playback state.
    [self playbackStateDidChange];
    
    // This fixes a strange problem that can occur on older devices (such as the iPhone 3GS) where the text color of UILabels is initially black instead of white.
    artistLabel.textColor = [UIColor whiteColor];
    label2.textColor = [UIColor whiteColor];
    label3.textColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    artistLabel.hidden = NO;
    label2.hidden = NO;
    label3.hidden = NO;
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (albumFlipped) {
        [self flipAlbum];
    }
    
    artistLabel.hidden = YES;
    label2.hidden = YES;
    label3.hidden = YES;
    
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [[[self fetchedResultsController]fetchedObjects]count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[CoverFlowView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    }
    
    Album *album = [[[self fetchedResultsController]fetchedObjects]objectAtIndex:index];
    [[ArtworkLoader sharedArtworkLoader]loadArtworkForCover:(CoverFlowView *)view atIndex:index inCoverFlowView:carousel artworkContainer:album];
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap:
            return NO;
        case iCarouselOptionSpacing:
            return value * 1.05f;
        default:
            return value;
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    // If there are no albums and the user exits the cover flow view, this function will be called with an index of -1, which will crash the app if it tries to find the album at that index.
    if (index >= 0) {
        Album *album = [[[self fetchedResultsController]fetchedObjects]objectAtIndex:carousel.currentItemIndex];
        
        NSSet *files = nil;
        if ([[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]) {
            files = album.filesForAlbumArtistGroup;
        }
        else {
            files = album.filesForArtistGroup;
        }
        
        File *nowPlayingFile = [[Player sharedPlayer]nowPlayingFile];
        if ([files containsObject:nowPlayingFile]) {
            artistLabel.text = album.artist.name;
            label2.text = nowPlayingFile.title;
            label3.text = album.name;
        }
        else {
            artistLabel.text = album.artist.name;
            label2.text = album.name;
            label3.text = nil;
        }
    }
}

#pragma mark -
#pragma mark iCarousel taps

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index {
    return !albumFlipped;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (index == carousel.currentItemIndex) {
        [self flipAlbum];
    }
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *artistSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artist.name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:artistSortDescriptor, nameSortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupByAlbumArtist == %@", [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults]boolForKey:kGroupByAlbumArtistKey]]]];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
        
        [self performFetch];
    }
    return fetchedResultsController;
}

- (void)performFetch {
    NSError *error = nil;
    if (![[self fetchedResultsController]performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [coverflow reloadData];
    [self updateCoverFlowPositionAnimated:NO];
    
    if ([controller.fetchedObjects count] <= 0) {
        artistLabel.text = nil;
        label2.text = nil;
        label3.text = nil;
    }
}

- (TabBarController *)tabBarController {
    return [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [[self tabBarController]willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [[self tabBarController]willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [[self tabBarController]didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return [[self tabBarController]shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

// iOS 6 Rotation Methods

- (BOOL)shouldAutorotate {
    return [[self tabBarController]shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [[self tabBarController]supportedInterfaceOrientations];
}

- (void)dealloc {
    // This prevents a strange problem in which the fetched results controller continues to call -controllerDidChangeContent: after an instance of the CoverflowViewController has been deallocated.
    fetchedResultsController.delegate = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
