//
//  RemoveAdsViewController.m
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import "RemoveAdsViewController.h"
#import "AppDelegate.h"
#import "TabBarController.h"
#import "TabBarController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "StandardGroupedCell.h"
#import "SkinManager.h"
#import "SKProduct+LocalizedPrice.h"

static NSString *kRemoveAdsProductIdentifierStr     = @"com.harrisonapps.royaltyfreemusicdownloader.removeads";
static NSString *kRemoveAdsTransactionReceiptKey    = @"Remove Ads Transaction Receipt";
static NSString *kRemoveAdsPurchasedKey             = @"Remove Ads Purchased";

@interface RemoveAdsViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIAlertView *successAlert;
@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, strong) SKProduct *adFreeUpgradeProduct;
@property (nonatomic, strong) SKPaymentTransaction *pendingTransaction;
@property (readwrite) BOOL didCancel;

- (void)cancelButtonPressed;
- (void)cancel;
- (void)requestProductData;

@end

@implementation RemoveAdsViewController

// Public
@synthesize delegate;

// Private
@synthesize hud;
@synthesize successAlert;
@synthesize request;
@synthesize adFreeUpgradeProduct;
@synthesize didCancel;

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if ([[Reachability reachabilityForInternetConnection]isReachable]) {
        UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
        
        hud = [[MBProgressHUD alloc]initWithWindow:window];
        // The user can see the cancel button more easily if the background isn't dimmed, which is important if they have a slow Internet connection and the app is unable to connect.
        // hud.dimBackground = YES;
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Connecting...";
        
        // This allows the user to press the cancel button.
        hud.userInteractionEnabled = NO;
        
        [window addSubview:hud];
        [hud show:YES];
        
        [self requestProductData];
    }
    else {
        UIAlertView *noInternetConnection = [[UIAlertView alloc]
                                             initWithTitle:@"No Internet Connection"
                                             message:@"No Internet connection is available. Please connect to the Internet and try again."
                                             delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                             otherButtonTitles:nil];
        [noInternetConnection show];
    }
    
    if ([SkinManager iOS6Skin]) {
        self.tableView.backgroundColor = [SkinManager iOS6SkinTableViewBackgroundColor];
        self.tableView.backgroundView.hidden = YES;
    }
    else if ([SkinManager iOS7Skin]) {
        self.tableView.backgroundColor = [SkinManager iOS7SkinTableViewBackgroundColor];
        self.tableView.backgroundView.hidden = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (!didCancel) {
        [self cancel];
    }
    [super viewDidDisappear:animated];
}

- (void)cancelButtonPressed {
    [self cancel];
}

- (void)cancel {
    didCancel = YES;
    
    if (request) {
        [request cancel];
    }
    
    SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
    
    [paymentQueue removeTransactionObserver:self];
    
    for (int i = 0; i < [paymentQueue.transactions count]; i++) {
        SKPaymentTransaction *transaction = [paymentQueue.transactions objectAtIndex:i];
        [paymentQueue finishTransaction:transaction];
    }
    
    if ([[[(AppDelegate *)[[UIApplication sharedApplication]delegate]window]subviews]containsObject:hud]) {
        self.view.userInteractionEnabled = YES;
        [hud hide:YES];
    }
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(removeAdsViewControllerDidFinish)]) {
            [delegate removeAdsViewControllerDidFinish];
        }
    }
}

- (void)requestProductData {
    request = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifierStr]];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.view.userInteractionEnabled = YES;
    [hud hide:YES];
    
    NSArray *products = response.products;
    if ([products count] > 0) {
        adFreeUpgradeProduct = [products objectAtIndex:0];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
        
        // Restarts any purchases if they were interrupted last time the app was open.
        [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    }
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Connection Error"
                                   message:@"The app encountered an error while trying to connect to the server. Please try again later."
                                   delegate:self
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

#pragma -
#pragma Purchase helpers

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    if ([transaction.payment.productIdentifier isEqualToString:kRemoveAdsProductIdentifierStr]) {
        // Save the transaction receipt to disk.
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:transaction.transactionReceipt forKey:kRemoveAdsTransactionReceiptKey];
        [defaults synchronize];
    }
}

- (void)provideContent:(NSString *)productID restoringPurchase:(BOOL)restoringPurchase {
    if ([productID isEqualToString:kRemoveAdsProductIdentifierStr]) {
        // Remove ads.
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:kRemoveAdsPurchasedKey];
        [defaults synchronize];
        
        [[(AppDelegate *)[[UIApplication sharedApplication]delegate]tabBarController]removeAds];
        
        // This prevents the success alert from being shown multiple times and crashing the app when this view controller has already been dismissed.
        if (successAlert) {
            [successAlert dismissWithClickedButtonIndex:successAlert.cancelButtonIndex animated:NO];
        }
        
        if (restoringPurchase) {
            successAlert = [[UIAlertView alloc]
                            initWithTitle:@"Purchase Restored"
                            message:@"Your purchase was successfully restored. All ads have been removed from the app."
                            delegate:self
                            cancelButtonTitle:NSLocalizedString(@"OK", @"")
                            otherButtonTitles:nil];
            [successAlert show];
        }
        else {
            successAlert = [[UIAlertView alloc]
                            initWithTitle:@"Thank You"
                            message:@"Thank you for your purchase! All ads have been removed from the app."
                            delegate:self
                            cancelButtonTitle:NSLocalizedString(@"OK", @"")
                            otherButtonTitles:nil];
            [successAlert show];
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    self.view.userInteractionEnabled = YES;
    [hud hide:YES];
    
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier restoringPurchase:NO];
    
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    self.view.userInteractionEnabled = YES;
    [hud hide:YES];
    
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier restoringPurchase:YES];
    
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    self.view.userInteractionEnabled = YES;
    [hud hide:YES];
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Transaction Error"
                                   message:@"The app encountered an error while trying to process the transaction. Please try again later."
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles:nil];
        [errorAlert show];
    }
    
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    self.view.userInteractionEnabled = YES;
    [hud hide:YES];
    
    if (error.code != SKErrorPaymentCancelled) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Purchase Restoration Error"
                                   message:@"The app encountered an error while trying to restore your purchase. Please try again later."
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

// This could hide the hud before the transaction can be verified.
/*
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    self.view.userInteractionEnabled = YES;
    [hud hide:YES];
}
*/

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return @"Already Purchased?";
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"Price: %@\n\n%@", [adFreeUpgradeProduct localizedPrice], adFreeUpgradeProduct.localizedDescription];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (adFreeUpgradeProduct) {
        return 3;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    StandardGroupedCell *cell = (StandardGroupedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[StandardGroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configure];
    
    // Configure the cell...
    
    if (indexPath.section == 1) {
        cell.textLabel.text = @"Buy Now";
    }
    else {
        cell.textLabel.text = @"Restore Purchase";
    }
    
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    
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
    
    if (indexPath.section == 1) {
        if ([SKPaymentQueue canMakePayments]) {
            self.view.userInteractionEnabled = NO;
            hud.labelText = @"Purchasing...";
            [hud show:YES];
            
            SKPayment *payment = [SKPayment paymentWithProductIdentifier:kRemoveAdsProductIdentifierStr];
            [[SKPaymentQueue defaultQueue]addPayment:payment];
        }
        else {
            UIAlertView *purchasesDisabledAlert = [[UIAlertView alloc]
                                                   initWithTitle:@"Purchases Disabled"
                                                   message:@"In-app purchases have been disabled by the restrictions on this device. Please enable in-app purchases in the \"Restrictions\" section of the Settings app and try again."
                                                   delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                   otherButtonTitles:nil];
            [purchasesDisabledAlert show];
        }
    }
    else {
        self.view.userInteractionEnabled = NO;
        hud.labelText = @"Restoring Purchase...";
        [hud show:YES];
        
        [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (delegate) {
        if ([delegate respondsToSelector:@selector(removeAdsViewControllerDidFinish)]) {
            [delegate removeAdsViewControllerDidFinish];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// iOS 6 Rotation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
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

@end
