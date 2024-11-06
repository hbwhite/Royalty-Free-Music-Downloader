//
//  LoginTypes.h
//  Royalty Free Music Downloader
//
//  Created by Harrison White on 2/2/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

enum {
	kLoginViewTypeFourDigit,
	kLoginViewTypeTextField
};
typedef NSUInteger kLoginViewType;

enum {
	kLoginTypeLogin,
	kLoginTypeAuthenticate,
	kLoginTypeChangePasscode,
	kLoginTypeCreatePasscode
};
typedef NSUInteger kLoginType;