//
//  LoginNavigationController.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/1/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginNavigationControllerDelegate.h"
#import "LoginViewControllerDelegate.h"
#import "LoginTypes.h"

@class LoginViewController;

@interface LoginNavigationController : UINavigationController <LoginViewControllerDelegate> {
@public
	id <LoginNavigationControllerDelegate> __unsafe_unretained loginNavigationControllerDelegate;
@private
    LoginViewController *loginViewController;
}

@property (nonatomic, unsafe_unretained) id <LoginNavigationControllerDelegate> loginNavigationControllerDelegate;

- (id)initWithFirstSegmentType:(kLoginViewType)firstSegmentType secondSegmentType:(kLoginViewType)secondSegmentType loginType:(kLoginType)loginType;

@end
