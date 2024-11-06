//
//  TextViewCell.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/4/13.
//  Copyright (c) 2013 Harrison Apps, LLC. All rights reserved.
//

#import "TextViewCell.h"
#import "SkinManager.h"

@implementation TextViewCell

@synthesize textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // A height of 200 pixels is expected.
        textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, (self.frame.size.width - 20), 180)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textView.backgroundColor = [UIColor clearColor];
        textView.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:textView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configure {
    if ([SkinManager iOS6Skin]) {
        self.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
