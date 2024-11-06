//
//  LoginViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/3/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginNavigationController.h"
#import "AppDelegate.h"
#import "TextFieldCell.h"
#import "SkinManager.h"
#import "UIImage+SafeStretchableImage.h"
#import "UITableView+SafeReload.h"

#define MAXIMUM_LOGIN_ATTEMPTS							5
#define LOCKOUT_SECONDS_ARRAY							[NSArray arrayWithObjects:@"60", @"300", @"900", @"1800", @"3600", nil]

#define FIRST_IMAGE_VIEW_BLOCK							[NSArray arrayWithObjects:imageView1, imageView2, imageView3, imageView4, nil]
#define SECOND_IMAGE_VIEW_BLOCK							[NSArray arrayWithObjects:imageView5, imageView6, imageView7, imageView8, nil]
#define THIRD_IMAGE_VIEW_BLOCK							[NSArray arrayWithObjects:imageView9, imageView10, imageView11, imageView12, nil]

static NSString *kFailedPasscodeAttemptsKey				= @"Failed Passcode Attempts";
static NSString *kPasscodeKey							= @"Passcode";
static NSString *kPermittedLoginAccessTimeKey			= @"Permitted Login Access Time";
static NSString *kPermittedAuthenticationAccessTimeKey	= @"Permitted Authentication Access Time";
static NSString *kSimplePasscodeKey						= @"Simple Passcode";
static NSString *kNumericPasscodeKey					= @"Numeric Passcode";

static NSString *kBoxEmptyImageName						= @"Box-Empty";
static NSString *kBoxFullImageName						= @"Box-Full";

static NSString *kNumericCharacterSetStr				= @"1234567890";

static NSString *kFloatFormatSpecifierStr				= @"%f";
static NSString *kNullStr								= @"";

@interface LoginViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *loginScrollView;
@property (nonatomic, strong) IBOutlet UIView *failedPasscodeAttemptsView;
@property (nonatomic, strong) IBOutlet UILabel *failedPasscodeAttemptsLabel;
@property (nonatomic, strong) IBOutlet UIImageView *failedPasscodeAttemptsImageView;

@property (nonatomic, strong) IBOutlet UIView *fourDigitOneSegmentView;
@property (nonatomic, strong) IBOutlet UIView *fourDigitTwoSegmentView;
@property (nonatomic, strong) IBOutlet UIView *textFieldOneSegmentView;
@property (nonatomic, strong) IBOutlet UIView *textFieldTwoSegmentView;

@property (nonatomic, strong) IBOutlet UITableView *fourDigitOneSegmentTableView;
@property (nonatomic, strong) IBOutlet UITableView *fourDigitTwoSegmentTableView1;
@property (nonatomic, strong) IBOutlet UITableView *fourDigitTwoSegmentTableView2;
@property (nonatomic, strong) IBOutlet UITableView *textFieldOneSegmentTableView;
@property (nonatomic, strong) IBOutlet UITableView *textFieldTwoSegmentTableView1;
@property (nonatomic, strong) IBOutlet UITableView *textFieldTwoSegmentTableView2;

@property (nonatomic, strong) IBOutlet UITextField *fourDigitOneSegmentTextField;
@property (nonatomic, strong) IBOutlet UITextField *fourDigitTwoSegmentTextField1;
@property (nonatomic, strong) IBOutlet UITextField *fourDigitTwoSegmentTextField2;

@property (nonatomic, strong) IBOutlet UIImageView *imageView1;
@property (nonatomic, strong) IBOutlet UIImageView *imageView2;
@property (nonatomic, strong) IBOutlet UIImageView *imageView3;
@property (nonatomic, strong) IBOutlet UIImageView *imageView4;
@property (nonatomic, strong) IBOutlet UIImageView *imageView5;
@property (nonatomic, strong) IBOutlet UIImageView *imageView6;
@property (nonatomic, strong) IBOutlet UIImageView *imageView7;
@property (nonatomic, strong) IBOutlet UIImageView *imageView8;
@property (nonatomic, strong) IBOutlet UIImageView *imageView9;
@property (nonatomic, strong) IBOutlet UIImageView *imageView10;
@property (nonatomic, strong) IBOutlet UIImageView *imageView11;
@property (nonatomic, strong) IBOutlet UIImageView *imageView12;

@property (nonatomic, strong) NSDecimalNumberHandler *decimalNumberHandler;
@property (nonatomic, strong) NSTimer *lockoutModeStatusTimer;
@property (nonatomic, strong) NSMutableString *updatedPasscode;
@property (nonatomic) NSInteger currentBlock;
@property (nonatomic) kLoginViewType originalFirstSegmentLoginViewType;
@property (readwrite) BOOL didEnterIncorrectPasscode;
@property (readwrite) BOOL noMatchViewEnabled;
@property (readwrite) BOOL passcodeIsNotDifferent;
@property (readwrite) BOOL passcodesDidNotMatch;
@property (readwrite) BOOL isInLockoutMode;

- (void)backButtonPressed;
- (IBAction)textFieldEditingChanged;
- (void)textFieldEditingChangedAction;
- (void)updatePasscodeBoxes:(NSArray *)passcodeBoxes;
- (void)textFieldDidFinishEditing;
- (BOOL)passcodeExists;
- (BOOL)passcodeIsCorrect:(NSString *)passcode;
- (void)authenticationDidFail;
- (void)authenticationDidSucceed;
- (void)setUpNextButton;
- (void)setUpDoneButton;
- (void)updateFailedPasscodeAttemptsLabel;
- (void)enterLockoutMode;
- (void)updateLockoutModeStatus;
- (void)didFinish;
- (void)addFirstSegmentSubview;
- (void)addBothSegmentSubviews;
- (UITableView *)currentTableView;
- (UITextField *)currentTextField;
- (UITableView *)tableViewForBlock:(NSInteger)block;
- (UITextField *)textFieldForBlock:(NSInteger)block;
- (void)reloadTableViews;
- (NSString *)permittedAccessTimeKey;
- (NSInteger)minutesBeforeLogin;

@end

@implementation LoginViewController

// Public
@synthesize delegate;
@synthesize firstSegmentLoginViewType;
@synthesize secondSegmentLoginViewType;
@synthesize loginType;
@synthesize finished;

// Private
@synthesize originalFirstSegmentLoginViewType;

@synthesize loginScrollView;
@synthesize failedPasscodeAttemptsView;
@synthesize failedPasscodeAttemptsLabel;
@synthesize failedPasscodeAttemptsImageView;
@synthesize decimalNumberHandler;

@synthesize fourDigitOneSegmentView;
@synthesize fourDigitTwoSegmentView;
@synthesize textFieldOneSegmentView;
@synthesize textFieldTwoSegmentView;

@synthesize fourDigitOneSegmentTableView;
@synthesize fourDigitTwoSegmentTableView1;
@synthesize fourDigitTwoSegmentTableView2;
@synthesize textFieldOneSegmentTableView;
@synthesize textFieldTwoSegmentTableView1;
@synthesize textFieldTwoSegmentTableView2;

@synthesize fourDigitOneSegmentTextField;
@synthesize fourDigitTwoSegmentTextField1;
@synthesize fourDigitTwoSegmentTextField2;

@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize imageView4;
@synthesize imageView5;
@synthesize imageView6;
@synthesize imageView7;
@synthesize imageView8;
@synthesize imageView9;
@synthesize imageView10;
@synthesize imageView11;
@synthesize imageView12;

@synthesize lockoutModeStatusTimer;
@synthesize updatedPasscode;
@synthesize currentBlock;

@synthesize didEnterIncorrectPasscode;
@synthesize noMatchViewEnabled;
@synthesize passcodeIsNotDifferent;
@synthesize passcodesDidNotMatch;
@synthesize isInLockoutMode;

- (void)backButtonPressed {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)textFieldEditingChanged {
	[self textFieldEditingChangedAction];
}
	
- (void)textFieldEditingChangedAction {
	UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
	if ([[[self currentTextField]text]length] > 0) {
		if (!rightBarButtonItem.enabled) {
			rightBarButtonItem.enabled = YES;
		}
	}
	else if (rightBarButtonItem.enabled) {
		rightBarButtonItem.enabled = NO;
	}
	if (currentBlock == 0) {
		if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
			[self updatePasscodeBoxes:FIRST_IMAGE_VIEW_BLOCK];
		}
	}
	else if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
		if (currentBlock == 1) {
			[self updatePasscodeBoxes:SECOND_IMAGE_VIEW_BLOCK];
		}
		else {
			[self updatePasscodeBoxes:THIRD_IMAGE_VIEW_BLOCK];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // This prevents the user from pressing the done button when the four digit login view is shown on the iPad.
    if (((currentBlock == 0) && (firstSegmentLoginViewType != kLoginViewTypeFourDigit)) || ((currentBlock > 0) && (secondSegmentLoginViewType != kLoginViewTypeFourDigit))) {
        [self textFieldDidFinishEditing];
    }
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    finished = NO;
}

// This prevents the keyboard from hiding on the iPad (this is critical as the four-digit passcode views have hidden keyboards).
// The "finished" variable must be checked here because if the text field can never end editing, no other text fields can become the first responder.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return finished;
}

- (void)textFieldDidFinishEditing {
    finished = YES;
    
	if (currentBlock == 0) {
		if ((loginType == kLoginTypeCreatePasscode) || ((loginType != kLoginTypeCreatePasscode) && ([self passcodeIsCorrect:[[self currentTextField]text]]))) {
			[self authenticationDidSucceed];
		}
		else {
			[self authenticationDidFail];
		}
	}
	else if (currentBlock == 1) {
		NSString *passcode = [[self currentTextField]text];
		if ([self passcodeIsCorrect:passcode]) {
			if (!passcodeIsNotDifferent) {
				passcodeIsNotDifferent = YES;
                
				[[self currentTableView]safelyReloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                
				UITextField *currentTextField = [self currentTextField];
				if (![currentTextField isFirstResponder]) {
					[currentTextField becomeFirstResponder];
				}
			}
		}
		else {
			[updatedPasscode setString:passcode];
			if (passcodeIsNotDifferent) {
				passcodeIsNotDifferent = NO;
			}
			currentBlock = 2;
			if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
				[self setUpDoneButton];
			}
			UITextField *currentTextField = [self currentTextField];
			if (![currentTextField isFirstResponder]) {
                [currentTextField becomeFirstResponder];
			}
			[loginScrollView setContentOffset:CGPointMake((self.view.frame.size.width * 2), 0) animated:YES];
		}
	}
	else {
		if ([updatedPasscode isEqualToString:[[self textFieldForBlock:2]text]]) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
			if ([updatedPasscode rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:kNumericCharacterSetStr]invertedSet]].length > 0) {
				if ([defaults boolForKey:kNumericPasscodeKey]) {
					[defaults setBool:NO forKey:kNumericPasscodeKey];
				}
			}
			else if (![defaults boolForKey:kNumericPasscodeKey]) {
				[defaults setBool:YES forKey:kNumericPasscodeKey];
			}
            
            [defaults setObject:updatedPasscode forKey:kPasscodeKey];
            [defaults synchronize];
			
			if (loginType == kLoginTypeChangePasscode) {
				if (originalFirstSegmentLoginViewType == kLoginViewTypeFourDigit) {
					NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
					[defaults setBool:NO forKey:kSimplePasscodeKey];
					[defaults synchronize];
				}
			}
			[self didFinish];
		}
		else {
			currentBlock = 1;
			passcodesDidNotMatch = YES;
			if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
				firstSegmentLoginViewType = kLoginViewTypeTextField;
				[fourDigitOneSegmentView removeFromSuperview];
				textFieldOneSegmentView.frame = self.view.bounds;
				[loginScrollView insertSubview:textFieldOneSegmentView atIndex:0];
				[self setUpNextButton];
			}
            
			[[self tableViewForBlock:0]safelyReloadData];
			[[self tableViewForBlock:1]safelyReloadData];
			[[self textFieldForBlock:1]setText:kNullStr];
			
			UITextField *currentTextField = [self currentTextField];
			if (![currentTextField isFirstResponder]) {
                [currentTextField becomeFirstResponder];
			}
			
			[self setUpNextButton];
			
			[loginScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
			[loginScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
			[[self textFieldForBlock:2]setText:kNullStr];
		}
	}
}

- (void)updatePasscodeBoxes:(NSArray *)passcodeBoxes {
	UIImage *boxEmptyImage = [UIImage imageNamed:kBoxEmptyImageName];
	UIImage *boxFullImage = [UIImage imageNamed:kBoxFullImageName];
	for (int i = 0; i < 4; i++) {
		UIImageView *imageView = [passcodeBoxes objectAtIndex:i];
		if ([[[self currentTextField]text]length] > i) {
			if (![imageView.image isEqual:boxFullImage]) {
				imageView.image = boxFullImage;
			}
		}
		else if (![imageView.image isEqual:boxEmptyImage]) {
			imageView.image = boxEmptyImage;
		}
	}
	UITextField *currentTextField = [self currentTextField];
	NSInteger textLength = [currentTextField.text length];
	if (textLength >= 4) {
		if (textLength > 4) {
			currentTextField.text = [currentTextField.text substringToIndex:4];
		}
		if (currentBlock == 0) {
			if ((loginType == kLoginTypeCreatePasscode) || ((loginType != kLoginTypeCreatePasscode) && ([self passcodeIsCorrect:[[self currentTextField]text]]))) {
				[self authenticationDidSucceed];
			}
			else {
				currentTextField.text = kNullStr;
				[self updatePasscodeBoxes:passcodeBoxes];
				[self authenticationDidFail];
			}
		}
		else if (currentBlock == 1) {
			NSString *passcode = [[self currentTextField]text];
			if ([self passcodeIsCorrect:passcode]) {
				if (!passcodeIsNotDifferent) {
					passcodeIsNotDifferent = YES;
                    
					[[self currentTableView]safelyReloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
				}
				currentTextField.text = kNullStr;
				[self updatePasscodeBoxes:passcodeBoxes];
			}
			else {
				[updatedPasscode setString:passcode];
				if (passcodeIsNotDifferent) {
					passcodeIsNotDifferent = NO;
				}
				currentBlock = 2;
				UITextField *currentTextField = [self currentTextField];
				if (![currentTextField isFirstResponder]) {
					finished = YES;
					[currentTextField becomeFirstResponder];
				}
				[loginScrollView setContentOffset:CGPointMake((self.view.frame.size.width * 2), 0) animated:YES];
			}
		}
		else {
			if ([updatedPasscode isEqualToString:[[self textFieldForBlock:2]text]]) {
				if (loginType == kLoginTypeChangePasscode) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:updatedPasscode forKey:kPasscodeKey];
                    [defaults synchronize];
                    
					if (originalFirstSegmentLoginViewType == kLoginViewTypeTextField) {
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						[defaults setBool:YES forKey:kSimplePasscodeKey];
						[defaults synchronize];
					}
				}
				else if (loginType == kLoginTypeCreatePasscode) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:updatedPasscode forKey:kPasscodeKey];
                    [defaults synchronize];
				}
				[self didFinish];
			}
			else {
				currentBlock = 1;
				if (firstSegmentLoginViewType == kLoginViewTypeTextField) {
					firstSegmentLoginViewType = kLoginViewTypeFourDigit;
					[textFieldOneSegmentView removeFromSuperview];
					fourDigitOneSegmentView.frame = self.view.bounds;
					[loginScrollView insertSubview:fourDigitOneSegmentView atIndex:0];
				}
				UITextField *currentTextField = [self currentTextField];
				if (![currentTextField isFirstResponder]) {
					finished = YES;
					[currentTextField becomeFirstResponder];
				}
				passcodesDidNotMatch = YES;
                
				[[self tableViewForBlock:0]safelyReloadData];
				[[self tableViewForBlock:1]safelyReloadData];
				[[self textFieldForBlock:1]setText:kNullStr];
				[self updatePasscodeBoxes:SECOND_IMAGE_VIEW_BLOCK];
				[loginScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
				[loginScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
				[[self textFieldForBlock:2]setText:kNullStr];
				[self updatePasscodeBoxes:THIRD_IMAGE_VIEW_BLOCK];
			}
		}
	}
}

- (BOOL)passcodeExists {
	return ([[NSUserDefaults standardUserDefaults]objectForKey:kPasscodeKey] != nil);
}

- (BOOL)passcodeIsCorrect:(NSString *)passcode {
	return [passcode isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kPasscodeKey]];
}

- (void)authenticationDidFail {
	if (!didEnterIncorrectPasscode) {
		didEnterIncorrectPasscode = YES;
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger failedPasscodeAttempts = ([defaults integerForKey:kFailedPasscodeAttemptsKey] + 1);
    [defaults setInteger:failedPasscodeAttempts forKey:kFailedPasscodeAttemptsKey];
    
	if (failedPasscodeAttempts > MAXIMUM_LOGIN_ATTEMPTS) {
		NSInteger index = (failedPasscodeAttempts - (MAXIMUM_LOGIN_ATTEMPTS + 1));
		NSString *timeIntervalString = nil;
		if (index < [LOCKOUT_SECONDS_ARRAY count]) {
			timeIntervalString = [LOCKOUT_SECONDS_ARRAY objectAtIndex:index];
		}
		else {
			timeIntervalString = [LOCKOUT_SECONDS_ARRAY lastObject];
		}
        [defaults setDouble:(CFAbsoluteTimeGetCurrent() + [timeIntervalString integerValue]) forKey:[self permittedAccessTimeKey]];
		[self enterLockoutMode];
	}
    
    [defaults synchronize];
    
	[self updateFailedPasscodeAttemptsLabel];
    
	[[self currentTableView]safelyReloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	UITextField *currentTextField = [self currentTextField];
	if (![currentTextField isFirstResponder]) {
		finished = YES;
        [currentTextField becomeFirstResponder];
	}
}

- (void)authenticationDidSucceed {
	if ((loginType == kLoginTypeLogin) || (loginType == kLoginTypeAuthenticate)) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:[self permittedAccessTimeKey]];
        [defaults removeObjectForKey:kFailedPasscodeAttemptsKey];
        [defaults synchronize];
		
		if (delegate) {
			if ([delegate respondsToSelector:@selector(loginViewControllerDidAuthenticate)]) {
				[delegate loginViewControllerDidAuthenticate];
			}
		}
		[self didFinish];
	}
	else {
		if (didEnterIncorrectPasscode) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:kFailedPasscodeAttemptsKey];
            [defaults synchronize];
            
			didEnterIncorrectPasscode = NO;
			failedPasscodeAttemptsView.hidden = YES;
		}
		currentBlock = 1;
		if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
			[self setUpNextButton];
		}
		else if (self.navigationItem.rightBarButtonItem) {
			self.navigationItem.rightBarButtonItem = nil;
		}
		UITextField *currentTextField = [self currentTextField];
		if (![currentTextField isFirstResponder]) {
			finished = YES;
            [currentTextField becomeFirstResponder];
		}
		[loginScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
	}
}

- (void)setUpNextButton {
	UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(textFieldDidFinishEditing)];
	nextButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = nextButton;
}

- (void)setUpDoneButton {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldDidFinishEditing)];
	doneButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)updateFailedPasscodeAttemptsLabel {
	NSInteger failedPasscodeAttempts = [[NSUserDefaults standardUserDefaults]integerForKey:kFailedPasscodeAttemptsKey];
	if (failedPasscodeAttempts > 0) {
		failedPasscodeAttemptsLabel.text = [NSString stringWithFormat:@"%i Failed Passcode Attempt%@", failedPasscodeAttempts, (failedPasscodeAttempts > 1) ? @"s" : kNullStr];
		if (failedPasscodeAttemptsView.hidden) {
			failedPasscodeAttemptsView.hidden = NO;
		}
	}
	else if (!failedPasscodeAttemptsView.hidden) {
		failedPasscodeAttemptsView.hidden = YES;
	}
}

- (void)enterLockoutMode {
	if (!isInLockoutMode) {
		isInLockoutMode = YES;
	}
	didEnterIncorrectPasscode = NO;
	[[self currentTextField]setText:kNullStr];
	[self updateLockoutModeStatus];
	if (lockoutModeStatusTimer) {
		[lockoutModeStatusTimer invalidate];
		lockoutModeStatusTimer = nil;
	}
	lockoutModeStatusTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLockoutModeStatus) userInfo:nil repeats:YES];
}

- (void)updateLockoutModeStatus {
	if ([self minutesBeforeLogin] <= 0) {
		if (lockoutModeStatusTimer) {
			[lockoutModeStatusTimer invalidate];
			lockoutModeStatusTimer = nil;
		}
		if (isInLockoutMode) {
			isInLockoutMode = NO;
		}
	}
    
	[[self currentTableView]safelyReloadData];
    
	UITextField *currentTextField = [self currentTextField];
	if (![currentTextField isFirstResponder]) {
		finished = YES;
        [currentTextField becomeFirstResponder];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.x == self.view.frame.size.width) {
		currentBlock = 1;
	}
	else if (scrollView.contentOffset.x == (self.view.frame.size.width * 2)) {
		currentBlock = 2;
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return !isInLockoutMode;
}

#pragma mark -
#pragma mark View lifecycle

- (void)didFinish {
    finished = YES;
	
    if (delegate) {
        if ([delegate respondsToSelector:@selector(loginViewControllerDidFinish)]) {
            [delegate loginViewControllerDidFinish];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // This is necessary for the view to be laid out correctly on iOS 7.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
	
	decimalNumberHandler = [[NSDecimalNumberHandler alloc]
							initWithRoundingMode:NSRoundUp
							scale:0
							raiseOnExactness:YES
							raiseOnOverflow:YES
							raiseOnUnderflow:YES
							raiseOnDivideByZero:YES];
	updatedPasscode = [[NSMutableString alloc]init];
    
    // This overrides the gray color setting in the SkinManager (intended for UITableView footer labels).
    failedPasscodeAttemptsLabel.textColor = [UIColor whiteColor];
    
	failedPasscodeAttemptsImageView.image = [[UIImage imageNamed:@"Failed_Passcode_Attempts"]safeStretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
    originalFirstSegmentLoginViewType = firstSegmentLoginViewType;
    
	if (loginType != kLoginTypeLogin) {
		if (!self.navigationItem.leftBarButtonItem) {
			UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didFinish)];
			self.navigationItem.leftBarButtonItem = cancelButton;
		}
	}
	if (firstSegmentLoginViewType == kLoginViewTypeTextField) {
		if (!self.navigationItem.rightBarButtonItem) {
			if ((loginType == kLoginTypeLogin) || (loginType == kLoginTypeAuthenticate)) {
				[self setUpDoneButton];
			}
			else {
				[self setUpNextButton];
			}
		}
	}
	if ((loginType == kLoginTypeLogin) || (loginType == kLoginTypeAuthenticate)) {
		loginScrollView.contentSize = self.view.frame.size;
		[self addFirstSegmentSubview];
	}
	else {
		loginScrollView.contentSize = CGSizeMake((self.view.frame.size.width * 3), self.view.frame.size.height);
		[self addBothSegmentSubviews];
		if (loginType == kLoginTypeCreatePasscode) {
            // Due to a bug in iOS 7, scroll view content offsets don't update immediately when they are first initialized.
            CGPoint contentOffset = CGPointMake(self.view.frame.size.width, 0);
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                while (!CGPointEqualToPoint(loginScrollView.contentOffset, contentOffset)) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        loginScrollView.contentOffset = contentOffset;
                    });
                }
            });
            
			for (int i = 0; i < 4; i++) {
				[[FIRST_IMAGE_VIEW_BLOCK objectAtIndex:i]setImage:[UIImage imageNamed:kBoxFullImageName]];
			}
			currentBlock = 1;
			UITextField *currentTextField = [self currentTextField];
			if (![currentTextField isFirstResponder]) {
				finished = YES;
                [currentTextField becomeFirstResponder];
			}
		}
	}
	
	[self updateFailedPasscodeAttemptsLabel];
	
	[self reloadTableViews];
	if ([[NSUserDefaults standardUserDefaults]integerForKey:kFailedPasscodeAttemptsKey] > MAXIMUM_LOGIN_ATTEMPTS) {
		[self enterLockoutMode];
	}
    
    UIColor *tableViewBackgroundColor = nil;
    
    if ([SkinManager iOS6Skin]) {
        tableViewBackgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
    }
    else if ([SkinManager iOS7Skin]) {
        tableViewBackgroundColor = [SkinManager iOS7SkinTableViewBackgroundColor];
    }
    
    if (tableViewBackgroundColor) {
        for (UITableView *tableView in [NSArray arrayWithObjects:
                                        fourDigitOneSegmentTableView,
                                        fourDigitTwoSegmentTableView1,
                                        fourDigitTwoSegmentTableView2,
                                        textFieldOneSegmentTableView,
                                        textFieldTwoSegmentTableView1,
                                        textFieldTwoSegmentTableView2,
                                        nil]) {
            
            tableView.backgroundColor = tableViewBackgroundColor;
            tableView.backgroundView.hidden = YES;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
	UITextField *currentTextField = [self currentTextField];
	if (![currentTextField isFirstResponder]) {
		finished = YES;
        [currentTextField becomeFirstResponder];
	}
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	if (lockoutModeStatusTimer) {
		[lockoutModeStatusTimer invalidate];
		lockoutModeStatusTimer = nil;
	}
    [super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
*/

- (void)addFirstSegmentSubview {
	[loginScrollView setContentSize:self.view.frame.size];
	if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
		fourDigitOneSegmentView.frame = self.view.bounds;
		[loginScrollView insertSubview:fourDigitOneSegmentView atIndex:0];
	}
	else if (firstSegmentLoginViewType == kLoginViewTypeTextField) {
		textFieldOneSegmentView.frame = self.view.bounds;
		[loginScrollView insertSubview:textFieldOneSegmentView atIndex:0];
	}
}

- (void)addBothSegmentSubviews {
	[self addFirstSegmentSubview];
	CGRect frame = CGRectMake(self.view.frame.size.width, 0, (self.view.frame.size.width * 2), self.view.frame.size.height);
	if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
		fourDigitTwoSegmentView.frame = frame;
		[loginScrollView insertSubview:fourDigitTwoSegmentView atIndex:0];
	}
	else if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
		textFieldTwoSegmentView.frame = frame;
		[loginScrollView insertSubview:textFieldTwoSegmentView atIndex:0];
	}
}

#pragma mark -

- (UITableView *)currentTableView {
	return [self tableViewForBlock:currentBlock];
}

- (UITextField *)currentTextField {
	return [self textFieldForBlock:currentBlock];
}

- (UITableView *)tableViewForBlock:(NSInteger)block {
	if (block == 0) {
		if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
			return fourDigitOneSegmentTableView;
		}
		else {
			return textFieldOneSegmentTableView;
		}
	}
	else {
		if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
			if (block == 1) {
				return fourDigitTwoSegmentTableView1;
			}
			else {
				return fourDigitTwoSegmentTableView2;
			}
		}
		else {
			if (block == 1) {
				return textFieldTwoSegmentTableView1;
			}
			else {
				return textFieldTwoSegmentTableView2;
			}
		}
	}
	return nil;
}

- (UITextField *)textFieldForBlock:(NSInteger)block {
	if (block == 0) {
		if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
			return fourDigitOneSegmentTextField;
		}
		else {
			return [(TextFieldCell *)[textFieldOneSegmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField];
		}
	}
	else if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
		if (block == 1) {
			return fourDigitTwoSegmentTextField1;
		}
		else {
			return fourDigitTwoSegmentTextField2;
		}
	}
	else {
		if (block == 1) {
			return [(TextFieldCell *)[textFieldTwoSegmentTableView1 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField];
		}
		else {
			return [(TextFieldCell *)[textFieldTwoSegmentTableView2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField];
		}
	}
}

- (void)reloadTableViews {
	for (int i = 0; i < 3; i++) {
		[[self tableViewForBlock:i]safelyReloadData];
	}
}

- (NSString *)permittedAccessTimeKey {
	if (loginType == kLoginTypeLogin) {
		return kPermittedLoginAccessTimeKey;
	}
	else if ((loginType == kLoginTypeAuthenticate) || (loginType == kLoginTypeChangePasscode)) {
		return kPermittedAuthenticationAccessTimeKey;
	}
	return nil;
}

- (NSInteger)minutesBeforeLogin {
	if (loginType != kLoginTypeCreatePasscode) {
		CFAbsoluteTime permittedAccessTime = [[NSUserDefaults standardUserDefaults]doubleForKey:[self permittedAccessTimeKey]];
		if (permittedAccessTime > 0) {
			double secondsBeforeLogin = (permittedAccessTime - CFAbsoluteTimeGetCurrent());
			if (secondsBeforeLogin > 0) {
				return [[[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:kFloatFormatSpecifierStr, (secondsBeforeLogin / 60.0)]]decimalNumberByRoundingAccordingToBehavior:decimalNumberHandler]integerValue];
			}
		}
	}
	return 0;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		if (tableView.tag == 0) {
			if ((firstSegmentLoginViewType == kLoginViewTypeTextField) || ((firstSegmentLoginViewType == kLoginViewTypeFourDigit) && (secondSegmentLoginViewType == kLoginViewTypeTextField) && (passcodesDidNotMatch))) {
				return 1;
			}
		}
		else if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
			return 1;
		}
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
        NSString *indent = kNullStr;
        if ([SkinManager iOS7]) {
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                indent = @"    ";
            }
            else {
                indent = @"            ";
            }
        }
        
		if (tableView.tag == 0) {
			NSString *prefix = kNullStr;
			NSString *suffix = kNullStr;
			if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
                if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    prefix = @"\n";
                }
			}
			else {
				suffix = @"\n ";
			}
            
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                prefix = [prefix stringByAppendingString:@"                   "];
            }
            
			if (([[NSUserDefaults standardUserDefaults]integerForKey:kFailedPasscodeAttemptsKey] > MAXIMUM_LOGIN_ATTEMPTS) && ([self minutesBeforeLogin] > 0)) {
				NSMutableString *tryAgainLaterString = nil;
				
				if (loginType == kLoginTypeLogin) {
                    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        tryAgainLaterString = [NSMutableString stringWithString:[indent stringByAppendingString:@"                App is disabled,\n"]];
                    }
                    else {
                        tryAgainLaterString = [NSMutableString stringWithString:[indent stringByAppendingString:@"                                   App is disabled,\n                   "]];
                    }
				}
				else {
					tryAgainLaterString = [NSMutableString stringWithString:prefix];
				}
				
				if ([self minutesBeforeLogin] == 1) {
					[tryAgainLaterString appendString:[indent stringByAppendingString:@"           Try again in 1 minute"]];
				}
				else if ([self minutesBeforeLogin] == 60) {
					[tryAgainLaterString appendString:[indent stringByAppendingString:@"             Try again in 1 hour"]];
				}
				else {
					[tryAgainLaterString appendString:[indent stringByAppendingFormat:@"          Try again in %i minutes", [self minutesBeforeLogin]]];
				}
				
				if (loginType == kLoginTypeLogin) {
					return tryAgainLaterString;
				}
				else {
					return [tryAgainLaterString stringByAppendingString:suffix];
				}
			}
			else {
				if (didEnterIncorrectPasscode) {
                    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        return [NSString stringWithFormat:@"%@             Incorrect passcode\n%@                     Try again", indent, indent];
                    }
                    else {
                        return [NSString stringWithFormat:@"%@                                Incorrect passcode\n%@                                        Try again", indent, indent];
                    }
				}
				else {
					if (loginType == kLoginTypeLogin) {
						return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"                Enter passcode"]stringByAppendingString:suffix];
					}
					else if (loginType == kLoginTypeAuthenticate) {
						return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"            Enter your passcode"]stringByAppendingString:suffix];
					}
					else if (loginType == kLoginTypeCreatePasscode) {
						return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"         Re-enter your passcode"]stringByAppendingString:suffix];
					}
					else {
						if (passcodesDidNotMatch) {
							return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"     Re-enter your new passcode"]stringByAppendingString:suffix];
						}
						else {
							return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"            Enter your passcode"]stringByAppendingString:suffix];
						}
					}
				}
			}
		}
		else {
			NSString *prefix = kNullStr;
			NSString *suffix = kNullStr;
			if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
                if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    prefix = @"\n";
                }
			}
			else {
				suffix = @"\n ";
			}
            
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                prefix = [prefix stringByAppendingString:@"                   "];
            }
            
			if (tableView.tag == 1) {
				if (loginType == kLoginTypeCreatePasscode) {
					return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"              Enter a passcode"]stringByAppendingString:suffix];
				}
				else {
					return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"       Enter your new passcode"]stringByAppendingString:suffix];
				}
			}
			else {
				if (loginType == kLoginTypeCreatePasscode) {
					return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"         Re-enter your passcode"]stringByAppendingString:suffix];
				}
				else {
					return [[[prefix stringByAppendingString:indent]stringByAppendingString:@"     Re-enter your new passcode"]stringByAppendingString:suffix];
				}
			}
		}
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		if (tableView.tag == 1) {
			if ((passcodeIsNotDifferent) || (passcodesDidNotMatch)) {
				NSString *prefix = kNullStr;
				if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
                    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        prefix = @"\n\n\n";
                    }
                    else {
                        prefix = @"\n\n\n\n";
                    }
				}
				if (passcodeIsNotDifferent) {
					return [prefix stringByAppendingString:@"Please enter a different passcode.\nYou cannot re-use the same passcode."];
				}
				else {
					return [prefix stringByAppendingString:@"The two passcodes did not match. Please try again."];
				}
			}
			else if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
				return @"If the passcode you enter is numeric, a numeric keypad will be shown instead of a full keyboard when you log in.";
			}
		}
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
	
	cell.textField.delegate = self;
	cell.textField.text = kNullStr;
	[cell.textField setSecureTextEntry:YES];
	[cell.textField addTarget:self action:@selector(textFieldEditingChangedAction) forControlEvents:UIControlEventEditingChanged];
	if (tableView.tag == 0) {
		if ([[NSUserDefaults standardUserDefaults]boolForKey:kNumericPasscodeKey]) {
			cell.textField.keyboardType = UIKeyboardTypeNumberPad;
		}
		if ((loginType == kLoginTypeLogin) || (loginType == kLoginTypeAuthenticate)) {
			cell.textField.returnKeyType = UIReturnKeyDone;
		}
		else {
			cell.textField.returnKeyType = UIReturnKeyNext;
		}
	}
	else if (tableView.tag == 1) {
		cell.textField.returnKeyType = UIReturnKeyNext;
	}
	else {
		cell.textField.returnKeyType = UIReturnKeyDone;
	}
	cell.textField.enablesReturnKeyAutomatically = YES;
    
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end
