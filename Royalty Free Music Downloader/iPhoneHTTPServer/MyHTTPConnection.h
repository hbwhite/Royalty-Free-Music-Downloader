#import <MobileCoreServices/MobileCoreServices.h>
#import "HTTPConnection.h"

@class MultipartFormDataParser;

@interface MyHTTPConnection : HTTPConnection  {
    MultipartFormDataParser*        parser;
	NSFileHandle*					storeFile;
    NSString *storeFilePath;
}

@end
