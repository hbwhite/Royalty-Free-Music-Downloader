//
//  LoginViewController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/3/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewControllerDelegate.h"
#import "LoginTypes.h"

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
@public
    id <LoginViewControllerDelegate> __unsafe_unretained delegate;
	kLoginViewType firstSegmentLoginViewType;
	kLoginViewType secondSegmentLoginViewType;
	kLoginType loginType;
    BOOL finished;
@private
    IBOutlet UIScrollView *loginScrollView;
	IBOutlet UIView *failedPasscodeAttemptsView;
	IBOutlet UILabel *failedPasscodeAttemptsLabel;
	IBOutlet UIImageView *failedPasscodeAttemptsImageView;
	
	IBOutlet UIView *fourDigitOneSegmentView;
	IBOutlet UIView *fourDigitTwoSegmentView;
	IBOutlet UIView *textFieldOneSegmentView;
	IBOutlet UIView *textFieldTwoSegmentView;
	
	IBOutlet UITableView *fourDigitOneSegmentTableView;
	IBOutlet UITableView *fourDigitTwoSegmentTableView1;
	IBOutlet UITableView *fourDigitTwoSegmentTableView2;
	IBOutlet UITableView *textFieldOneSegmentTableView;
	IBOutlet UITableView *textFieldTwoSegmentTableView1;
	IBOutlet UITableView *textFieldTwoSegmentTableView2;
	
	IBOutlet UITextField *fourDigitOneSegmentTextField;
	IBOutlet UITextField *fourDigitTwoSegmentTextField1;
	IBOutlet UITextField *fourDigitTwoSegmentTextField2;
	
	IBOutlet UIImageView *imageView1;
	IBOutlet UIImageView *imageView2;
	IBOutlet UIImageView *imageView3;
	IBOutlet UIImageView *imageView4;
	IBOutlet UIImageView *imageView5;
	IBOutlet UIImageView *imageView6;
	IBOutlet UIImageView *imageView7;
	IBOutlet UIImageView *imageView8;
	IBOutlet UIImageView *imageView9;
	IBOutlet UIImageView *imageView10;
	IBOutlet UIImageView *imageView11;
	IBOutlet UIImageView *imageView12;
	
    NSDecimalNumberHandler *decimalNumberHandler;
	NSTimer *lockoutModeStatusTimer;
	NSMutableString *updatedPasscode;
	NSInteger currentBlock;
    kLoginViewType originalFirstSegmentLoginViewType;
	BOOL didEnterIncorrectPasscode;
	BOOL noMatchViewEnabled;
	BOOL passcodeIsNotDifferent;
	BOOL passcodesDidNotMatch;
	BOOL isInLockoutMode;
}

@property (nonatomic, unsafe_unretained) id <LoginViewControllerDelegate> delegate;
@property (nonatomic) kLoginViewType firstSegmentLoginViewType;
@property (nonatomic) kLoginViewType secondSegmentLoginViewType;
@property (nonatomic) kLoginType loginType;
@property (readwrite) BOOL finished;

@end
