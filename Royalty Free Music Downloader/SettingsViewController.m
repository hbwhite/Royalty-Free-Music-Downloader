//
//  SettingsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 3/18/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "BrowserViewController.h"
#import "RemoveAdsNavigationController.h"
#import "BrowserSettingsViewController.h"
#import "DownloadSettingsViewController.h"
#import "WiFiTransferViewController.h"
#import "SkinsViewController.h"
#import "PlayerSettingsViewController.h"
#import "SmartPlaylistSettingsViewController.h"
#import "LoginNavigationController.h"
#import "PasscodeSettingsViewController.h"
#import "DataManager.h"
#import "MBProgressHUD.h"
#import "TTTUnitOfInformationFormatter.h"
#import "StandardGroupedCell.h"
#import "UpdateLibraryCell.h"
#import "IconCell.h"
#import "IconDetailCell.h"
#import "SkinManager.h"
#import "UIViewController+SafeModal.h"

static NSString *kRemoveAdsPurchasedKey         = @"Remove Ads Purchased";

static NSString *kPasscodeKey                   = @"Passcode";
static NSString *kSimplePasscodeKey             = @"Simple Passcode";

static NSString *kHelpURLStr                    = @"http://www.harrisonapps.com/royaltyfreemusic/";
static NSString *kApplicationURLStr             = @"http://itunes.apple.com/app/id876912798";

static NSString *kShareTextStr                  = @"Check out this awesome app. It lets you download unlimited royalty free music!";

static NSString *kSuggestionsEmailAddressStr    = @"royaltyfreemusicsuggestions@harrisonapps.com";
static NSString *kBugReportsEmailAddressStr     = @"royaltyfreemusicbugreports@harrisonapps.com";
static NSString *kSupportEmailAddressStr        = @"royaltyfreemusic@harrisonapps.com";

@interface SettingsViewController ()

@property (nonatomic, strong) TTTUnitOfInformationFormatter *formatter;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;

- (void)skinDidChange;
- (void)shareViaEmail;
- (void)shareViaMessage;
- (void)shareViaFacebook;
- (void)shareViaTwitter;
- (void)pushPasscodeSettingsViewControllerAnimated:(BOOL)animated;

@end

@implementation SettingsViewController

// Private
@synthesize formatter;
@synthesize percentFormatter;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    formatter = [[TTTUnitOfInformationFormatter alloc]init];
    [formatter setDisplaysInTermsOfBytes:YES];
    [formatter setUsesIECBinaryPrefixesForCalculation:YES];
    [formatter setUsesIECBinaryPrefixesForDisplay:NO];
    
    percentFormatter = [[NSNumberFormatter alloc]init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setLocale:[NSLocale currentLocale]];
    [percentFormatter setMinimumFractionDigits:2];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(skinDidChange) name:kSkinDidChangeNotification object:nil];
}

- (void)skinDidChange {
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        if (![[NSUserDefaults standardUserDefaults]boolForKey:kRemoveAdsPurchasedKey]) {
            return @"This removes all ads in the app.";
        }
    }
    else if (section == 1) {
        return @"Press this button to import files from iTunes File Sharing or if your iPod music library is out of sync with the app.";
    }
    else if (section == 7) {
        NSString *version = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"];
        
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSDictionary *attributes = [[NSFileManager defaultManager]attributesOfFileSystemForPath:documentsDirectoryPath error:nil];
        NSNumber *diskSpace = [attributes objectForKey:NSFileSystemSize];
        NSNumber *freeSpace = [attributes objectForKey:NSFileSystemFreeSize];
        NSString *formattedDiskSpace = [formatter stringFromNumber:diskSpace ofUnit:TTTByte];
        NSString *formattedFreeSpace = [formatter stringFromNumber:freeSpace ofUnit:TTTByte];
        double freeSpacePercentage = ([freeSpace doubleValue] / [diskSpace doubleValue]);
        NSString *formattedFreeSpacePercentage = [percentFormatter stringFromNumber:[NSNumber numberWithFloat:freeSpacePercentage]];
        return [NSString stringWithFormat:@"Royalty Free Music Downloader v%@\nDisk Space: %@\nFree Space: %@ (%@)", version, formattedDiskSpace, formattedFreeSpace, formattedFreeSpacePercentage];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
        {
            if (![[NSUserDefaults standardUserDefaults]boolForKey:kRemoveAdsPurchasedKey]) {
                return 1;
            }
            return 0;
        }
        case 1:
            return 1;
        case 2:
            return 2;
        case 3:
        {
            // Most of the appearance functions used by the iOS 6 skin are only available in iOS 5.0 or later, so the iOS 6 skin is disallowed on firmwares prior to iOS 5.0.
            // Because devices on older firmwares can only use the default skin, the skins panel is hidden.
            if ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending) {
                return 1;
            }
            else {
                return 0;
            }
        }
        case 4:
            return 2;
        case 5:
        {
            // The Wi-Fi Transfer system uses features only available in iOS 5.0 or later.
            if ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending) {
                return 1;
            }
            else {
                return 0;
            }
        }
        case 6:
            return 1;
        case 7:
            return 6;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell 1";
        
        StandardGroupedCell *cell = (StandardGroupedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[StandardGroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textLabel.text = @"Remove Ads";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        return cell;
    }
    else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"Cell 2";
        
        UpdateLibraryCell *cell = (UpdateLibraryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UpdateLibraryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textLabel.text = @"Update Library";
        
        return cell;
    }
    else if (indexPath.section == 3) {
        static NSString *CellIdentifier = @"Cell 3";
        
        IconDetailCell *cell = (IconDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[IconDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        cell.textLabel.text = @"Skins";
        
        if ([SkinManager iOS6Skin]) {
            cell.detailLabel.text = @"iOS 6";
        }
        else {
            cell.detailLabel.text = @"Default";
        }
        
        cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Skins"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"Skins-Selected"];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell 4";
        
        IconCell *cell = (IconCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[IconCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configure];
        
        // Configure the cell...
        
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Player & iPod Library";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"iPod"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"iPod-Selected"];
            }
            else {
                cell.textLabel.text = @"Smart Playlists";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Smart_Playlists"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Smart_Playlists-Selected"];
            }
        }
        else if (indexPath.section == 4) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Browser";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Browser"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Browser-Selected"];
            }
            else {
                cell.textLabel.text = @"Downloads";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Downloads"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Downloads-Selected"];
            }
        }
        else if (indexPath.section == 5) {
            cell.textLabel.text = @"Wi-Fi Transfer";
            cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Wi-Fi"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"Wi-Fi-Selected"];
        }
        else if (indexPath.section == 6) {
            cell.textLabel.text = @"Passcode Lock";
            cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Passcode"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"Passcode-Selected"];
        }
        else {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Help / Info";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Help"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Help-Selected"];
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = @"Tell a Friend";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Share"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Share-Selected"];
            }
            else if (indexPath.row == 2) {
                cell.textLabel.text = @"Rate or Review the App";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Review"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Review-Selected"];
            }
            else if (indexPath.row == 3) {
                cell.textLabel.text = @"Send Suggestions";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Send_Suggestions"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Send_Suggestions-Selected"];
            }
            else if (indexPath.row == 4) {
                cell.textLabel.text = @"Report Bugs";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Report_Bugs"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Report_Bugs-Selected"];
            }
            else {
                cell.textLabel.text = @"Contact Support";
                cell.imageView.image = [UIImage iOS7SkinImageNamed:@"Contact"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Contact-Selected"];
            }
        }
        
        return cell;
    }
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
     [detailViewController release];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        RemoveAdsNavigationController *removeAdsNavigationController = [[RemoveAdsNavigationController alloc]init];
        removeAdsNavigationController.removeAdsNavigationControllerDelegate = self;
        [self safelyPresentModalViewController:removeAdsNavigationController animated:YES completion:nil];
    }
    else if (indexPath.section == 1) {
        [[DataManager sharedDataManager]updateLibraryWithUpdateType:kLibraryUpdateTypeComplete];
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            PlayerSettingsViewController *playerSettingsViewController = [[PlayerSettingsViewController alloc]init];
            playerSettingsViewController.title = @"Player & iPod Library";
            [self.navigationController pushViewController:playerSettingsViewController animated:YES];
        }
        else {
            SmartPlaylistSettingsViewController *smartPlaylistSettingsViewController = [[SmartPlaylistSettingsViewController alloc]init];
            smartPlaylistSettingsViewController.title = @"Smart Playlists";
            [self.navigationController pushViewController:smartPlaylistSettingsViewController animated:YES];
        }
    }
    else if (indexPath.section == 3) {
        SkinsViewController *skinsViewController = [[SkinsViewController alloc]init];
        skinsViewController.title = @"Skins";
        [self.navigationController pushViewController:skinsViewController animated:YES];
    }
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            BrowserSettingsViewController *browserSettingsViewController = [[BrowserSettingsViewController alloc]init];
            browserSettingsViewController.title = @"Browser";
            [self.navigationController pushViewController:browserSettingsViewController animated:YES];
        }
        else {
            DownloadSettingsViewController *downloadSettingsViewController = [[DownloadSettingsViewController alloc]init];
            downloadSettingsViewController.title = @"Downloads";
            [self.navigationController pushViewController:downloadSettingsViewController animated:YES];
        }
    }
    else if (indexPath.section == 5) {
        WiFiTransferViewController *wifiTransferViewController = [[WiFiTransferViewController alloc]init];
        wifiTransferViewController.title = @"Wi-Fi Transfer";
        [self.navigationController pushViewController:wifiTransferViewController animated:YES];
    }
    else if (indexPath.section == 6) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:kPasscodeKey]) {
			LoginNavigationController *loginNavigationController = nil;
			
            // The second segment type is irrelevant in this case.
			if ([defaults boolForKey:kSimplePasscodeKey]) {
                loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:kLoginViewTypeFourDigit secondSegmentType:kLoginViewTypeFourDigit loginType:kLoginTypeAuthenticate];
			}
			else {
                loginNavigationController = [[LoginNavigationController alloc]initWithFirstSegmentType:kLoginViewTypeTextField secondSegmentType:kLoginViewTypeTextField loginType:kLoginTypeAuthenticate];
			}
            
            loginNavigationController.loginNavigationControllerDelegate = self;
			[self safelyPresentModalViewController:loginNavigationController animated:YES completion:nil];
		}
		else {
            [self pushPasscodeSettingsViewControllerAnimated:YES];
		}
    }
    else {
        if (indexPath.row == 0) {
            TabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController];
            NSArray *viewControllers = tabBarController.viewControllers;
            for (int i = 0; i < [viewControllers count]; i++) {
                UIViewController *viewController = [[viewControllers objectAtIndex:i]topViewController];
                if ([viewController isKindOfClass:[BrowserViewController class]]) {
                    // The BrowserViewController must be initialized first.
                    tabBarController.selectedIndex = i;
                    
                    BrowserViewController *browserViewController = (BrowserViewController *)viewController;
                    browserViewController.currentURL = [NSURL URLWithString:kHelpURLStr];
                    [browserViewController loadWebView];
                    break;
                }
            }
        }
        else if (indexPath.row == 1) {
            if ([MFMessageComposeViewController canSendText]) {
                if ((NSClassFromString(@"SLComposeViewController")) || (NSClassFromString(@"TWTweetComposeViewController"))) {
                    if (NSClassFromString(@"SLComposeViewController")) {
                        UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                    initWithTitle:@"Tell a Friend"
                                                                    delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                    destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Mail", @"Message", @"Facebook", @"Twitter", nil];
                        sharingOptionsActionSheet.tag = 0;
                        [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                    }
                    else {
                        UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                    initWithTitle:@"Tell a Friend"
                                                                    delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                    destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Mail", @"Message", @"Twitter", nil];
                        sharingOptionsActionSheet.tag = 1;
                        [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                    }
                }
                else {
                    /*
                    if ([FBDialogs canPresentOSIntegratedShareDialogWithSession:nil]) {
                        UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                    initWithTitle:@"Tell a Friend"
                                                                    delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                    destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Mail", @"Message", @"Facebook", nil];
                        sharingOptionsActionSheet.tag = 2;
                        [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                    }
                    else {*/
                        UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                    initWithTitle:@"Tell a Friend"
                                                                    delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                    destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Mail", @"Message", nil];
                        sharingOptionsActionSheet.tag = 3;
                        [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                    // }
                }
            }
            else if ((NSClassFromString(@"SLComposeViewController")) || (NSClassFromString(@"TWTweetComposeViewController"))) {
                if (NSClassFromString(@"SLComposeViewController")) {
                    UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                initWithTitle:@"Tell a Friend"
                                                                delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                destructiveButtonTitle:nil
                                                                otherButtonTitles:@"Mail", @"Facebook", @"Twitter", nil];
                    sharingOptionsActionSheet.tag = 4;
                    [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                }
                else {
                    /*
                    if ([FBDialogs canPresentOSIntegratedShareDialogWithSession:nil]) {
                        UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                    initWithTitle:@"Tell a Friend"
                                                                    delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                    destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Mail", @"Facebook", @"Twitter", nil];
                        sharingOptionsActionSheet.tag = 5;
                        [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                    }
                    else {*/
                        UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                    initWithTitle:@"Tell a Friend"
                                                                    delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                    destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Mail", @"Twitter", nil];
                        sharingOptionsActionSheet.tag = 6;
                        [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                    // }
                }
            }
            else {
                /*
                if ([FBDialogs canPresentOSIntegratedShareDialogWithSession:nil]) {
                    UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                initWithTitle:@"Tell a Friend"
                                                                delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                destructiveButtonTitle:nil
                                                                otherButtonTitles:@"Mail", @"Facebook", nil];
                    sharingOptionsActionSheet.tag = 7;
                    [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                }
                else {*/
                    UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
                                                                initWithTitle:@"Tell a Friend"
                                                                delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                destructiveButtonTitle:nil
                                                                otherButtonTitles:@"Mail", nil];
                    sharingOptionsActionSheet.tag = 8;
                    [sharingOptionsActionSheet showFromRect:[[tableView cellForRowAtIndexPath:indexPath]frame] inView:tableView animated:YES];
                // }
            }
        }
        else if (indexPath.row == 2) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:kApplicationURLStr]];
        }
        else {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
                mailComposeViewController.mailComposeDelegate = self;
                
                if (indexPath.row == 3) {
                    [mailComposeViewController setToRecipients:[NSArray arrayWithObject:kSuggestionsEmailAddressStr]];
                    [mailComposeViewController setSubject:@"Suggestions"];
                    
                    // For whatever reason, an extra newline is required here.
                    [mailComposeViewController setMessageBody:@"Please tell us how we can make the app better for you:\n\n\n" isHTML:NO];
                }
                else if (indexPath.row == 4) {
                    [mailComposeViewController setToRecipients:[NSArray arrayWithObject:kBugReportsEmailAddressStr]];
                    [mailComposeViewController setSubject:@"Bug Report"];
                    
                    // For whatever reason, an extra newline is required here.
                    [mailComposeViewController setMessageBody:@"Please describe the steps necessary to reproduce this problem:\n\n\n" isHTML:NO];
                }
                else {
                    [mailComposeViewController setToRecipients:[NSArray arrayWithObject:kSupportEmailAddressStr]];
                }
                
                // Apple will reject apps that use full screen modal view controllers on the iPad.
                if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                }
                
                [self safelyPresentModalViewController:mailComposeViewController animated:YES completion:nil];
            }
            else {
                UIAlertView *cannotSendMailAlert = [[UIAlertView alloc]
                                                    initWithTitle:@"Cannot Send Email"
                                                    message:@"You must configure your device to work with your email account in order to send email. Would you like to do this now?"
                                                    delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                    otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
                [cannotSendMailAlert show];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet.tag == 0) {
            if (buttonIndex == 0) {
                [self shareViaEmail];
            }
            else if (buttonIndex == 1) {
                [self shareViaMessage];
            }
            else if (buttonIndex == 2) {
                [self shareViaFacebook];
            }
            else {
                [self shareViaTwitter];
            }
        }
        else if (actionSheet.tag == 1) {
            if (buttonIndex == 0) {
                [self shareViaEmail];
            }
            else if (buttonIndex == 1) {
                [self shareViaMessage];
            }
            else {
                [self shareViaTwitter];
            }
        }
        else if (actionSheet.tag == 2) {
            if (buttonIndex == 0) {
                [self shareViaEmail];
            }
            else if (buttonIndex == 1) {
                [self shareViaMessage];
            }
            else {
                [self shareViaFacebook];
            }
        }
        else if (actionSheet.tag == 3) {
            if (buttonIndex == 0) {
                [self shareViaEmail];
            }
            else {
                [self shareViaMessage];
            }
        }
        else if (actionSheet.tag == 4) {
            if (buttonIndex == 0) {
                [self shareViaEmail];
            }
            else if (buttonIndex == 1) {
                [self shareViaFacebook];
            }
            else {
                [self shareViaTwitter];
            }
        }
        else if (actionSheet.tag == 5) {
            if (buttonIndex == 0) {
                [self shareViaEmail];
            }
            else if (buttonIndex == 1) {
                [self shareViaFacebook];
            }
            else {
                [self shareViaTwitter];
            }
        }
        else if (actionSheet.tag == 6) {
            if (buttonIndex == 0) {
                [self shareViaEmail];
            }
            else {
                [self shareViaTwitter];
            }
        }
        else if (actionSheet.tag == 7) {
            if (buttonIndex == 0) {
                [self shareViaEmail];
            }
            else {
                [self shareViaFacebook];
            }
        }
        else {
            [self shareViaEmail];
        }
    }
}

- (void)shareViaEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setSubject:@"Royalty Free Music Downloader"];
        [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@<br/><br/><a href=\"%@\">%@</a>", kShareTextStr, kApplicationURLStr, kApplicationURLStr] isHTML:YES];
        
        // Apple will reject apps that use full screen modal view controllers on the iPad.
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [self safelyPresentModalViewController:mailComposeViewController animated:YES completion:nil];
    }
    else {
        UIAlertView *cannotSendMailAlert = [[UIAlertView alloc]
                                            initWithTitle:@"Cannot Send Email"
                                            message:@"You must configure your device to work with your email account in order to send email. Would you like to do this now?"
                                            delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                            otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [cannotSendMailAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto:"]];
    }
}

- (void)shareViaMessage {
    MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc]init];
    messageComposeViewController.messageComposeDelegate = self;
    [messageComposeViewController setBody:[NSString stringWithFormat:@"%@\n\n%@", kShareTextStr, kApplicationURLStr]];
    
    // Apple will reject apps that use full screen modal view controllers on the iPad.
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        messageComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self safelyPresentModalViewController:messageComposeViewController animated:YES completion:nil];
}

- (void)shareViaFacebook {
    NSURL *url = [NSURL URLWithString:kApplicationURLStr];
    
    // if (NSClassFromString(@"SLComposeViewController")) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:kShareTextStr];
        
        if (![composeViewController addURL:url]) {
            [composeViewController setInitialText:[NSString stringWithFormat:@"%@\n\n%@", kShareTextStr, kApplicationURLStr]];
        }
        
        [self safelyPresentModalViewController:composeViewController animated:YES completion:nil];/*
    }
    else {
        [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                 initialText:kShareTextStr
                                                       image:nil
                                                         url:url
                                                     handler:nil];
    }*/
}

- (void)shareViaTwitter {
    NSURL *url = [NSURL URLWithString:kApplicationURLStr];
    
    if (NSClassFromString(@"SLComposeViewController")) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:kShareTextStr];
        
        if (![composeViewController addURL:url]) {
            [composeViewController setInitialText:[NSString stringWithFormat:@"%@\n%@", kShareTextStr, kApplicationURLStr]];
        }
        
        [self safelyPresentModalViewController:composeViewController animated:YES completion:nil];
    }
    else {
        TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc]init];
        [tweetComposeViewController setInitialText:kShareTextStr];
        
        if (![tweetComposeViewController addURL:url]) {
            [tweetComposeViewController setInitialText:[NSString stringWithFormat:@"%@\n%@", kShareTextStr, kApplicationURLStr]];
        }
        
        [self safelyPresentModalViewController:tweetComposeViewController animated:YES completion:nil];
    }
}

- (void)removeAdsNavigationControllerDidFinish {
    [self.tableView reloadData];
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)loginNavigationControllerDidAuthenticate {
    // The background views aren't completely obscured on the iPad.
    [self pushPasscodeSettingsViewControllerAnimated:([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)];
}

- (void)loginNavigationControllerDidFinish {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
}

- (void)pushPasscodeSettingsViewControllerAnimated:(BOOL)animated {
    PasscodeSettingsViewController *passcodeSettingsViewController = [[PasscodeSettingsViewController alloc]init];
    passcodeSettingsViewController.title = @"Passcode Lock";
    [self.navigationController pushViewController:passcodeSettingsViewController animated:animated];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultFailed) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error"
                                   message:@"Your message could not be sent. This could be due to little or no Internet connectivity."
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self safelyDismissModalViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultFailed) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error"
                                   message:@"Your message could not be sent. This could be due to little or no Internet connectivity."
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
