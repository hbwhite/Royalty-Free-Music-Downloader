//
//  DownloadsTabBarItem.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 4/17/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "DownloadsTabBarItem.h"
#import "DataManager.h"
#import "Downloader.h"

static NSString *kPreventSleepModeKey   = @"Prevent Sleep Mode";

@interface DownloadsTabBarItem ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)updateBadge;

@end

@implementation DownloadsTabBarItem

// Private
@synthesize fetchedResultsController;

- (id)init {
    self = [super init];
    if (self) {
        [self updateBadge];
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!fetchedResultsController) {
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedDataManager]managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *indexSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:indexSortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state != %@) AND (state != %@)", [NSNumber numberWithInteger:kDownloadStatePaused], [NSNumber numberWithInteger:kDownloadStateFailed]];
        [fetchRequest setPredicate:predicate];
        
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // This delegate method must be implemented (in addition to the delegate being set) for the fetched results controller to track changes to the managed object context.
    
    [self updateBadge];
}

- (void)updateBadge {
    NSInteger downloadCount = [[[self fetchedResultsController]fetchedObjects]count];
    if (downloadCount > 0) {
        self.badgeValue = [NSString stringWithFormat:@"%i", downloadCount];
    }
    else {
        self.badgeValue = nil;
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    
    [application setApplicationIconBadgeNumber:downloadCount];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kPreventSleepModeKey]) {
        [application setIdleTimerDisabled:(downloadCount > 0)];
    }
    else {
        [application setIdleTimerDisabled:NO];
    }
}

@end
