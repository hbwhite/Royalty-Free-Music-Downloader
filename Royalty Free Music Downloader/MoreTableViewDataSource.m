//
//  MoreTableViewDataSource.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 8/13/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "MoreTableViewDataSource.h"
#import "SkinManager.h"
#import "MoreTableViewCell.h"

@interface MoreTableViewDataSource ()

@property (nonatomic, strong) id <UITableViewDataSource> originalDataSource;
@property (nonatomic, strong) UITableView *tableView;

- (void)updateSkin;

@end

@implementation MoreTableViewDataSource

@synthesize originalDataSource = _originalDataSource;
@synthesize tableView = _tableView;

- (id)initWithOriginalDataSource:(id <UITableViewDataSource>)originalDataSource tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.originalDataSource = originalDataSource;
        self.tableView = tableView;
        
        [self updateSkin];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateSkin) name:kSkinDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateSkin {
    if ([SkinManager iOS6Skin]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [self.originalDataSource tableView:table numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *originalCell = [self.originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([SkinManager iOS6Skin]) {
        // This should not conflict with the identifier of the original cell.
        static NSString *CellIdentifier = @"Custom More Table View Cell";
        
        MoreTableViewCell *cell = (MoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[MoreTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textLabel.text = originalCell.textLabel.text;
        cell.imageView.image = originalCell.imageView.image;
        cell.imageView.highlightedImage = originalCell.imageView.highlightedImage;
        cell.accessoryType = originalCell.accessoryType;
        
        return cell;
    }

    return originalCell;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
