
#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

#import "DataManager.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@interface MyHTTPConnection ()

@property (nonatomic, strong) NSString *storeFilePath;

@end

@implementation MyHTTPConnection

@synthesize storeFilePath;

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"])
	{
		return YES;
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }

		// enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
	HTTPLogTrace();
    
    NSString *filePath = [self filePathForURI:path];
	
	if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
		return [[HTTPFileResponse alloc]initWithFilePath:filePath forConnection:self];
	}
	else {
        // This is necessary to handle spaces (which show up as "%20") in URLs properly.
        NSData *browseData = [[self createBrowseableIndex:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:[path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]dataUsingEncoding:NSUTF8StringEncoding];
        return [[HTTPDataResponse alloc]initWithData:browseData];
	}
}

- (NSString *)createBrowseableIndex:(NSString *)path
{
    NSArray *array = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head>"];
	[outdata appendString:@"<title>Files from Royalty Free Music Downloader</title>"];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
    [outdata appendFormat:@"<img width=\"72\" height=\"72\" src=\"%@\"> Royalty Free Music Downloader</img>", @"data:image/png;base64,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"];
	[outdata appendString:@"<h1>Files from Royalty Free Music Downloader</h1>"];
    [outdata appendString:@"<bq>The following files are hosted live from the Royalty Free Music Downloader Documents folder.</bq>"];
    [outdata appendString:@"<p>"];
	[outdata appendString:@"<a href=\"..\">..</a><br />\n"];
    for (NSString __strong *fname in array)
    {
        if ([fname length] > 0) {
            if (![[fname substringToIndex:1]isEqualToString:@"."]) {
                NSDictionary *fileDict = [[NSFileManager defaultManager]attributesOfItemAtPath:[path stringByAppendingPathComponent:fname] error:nil];
                //NSLog(@"fileDict: %@", fileDict);
                NSString *modDate = [[fileDict objectForKey:NSFileModificationDate] description];
                if ([[fileDict objectForKey:NSFileType] isEqualToString: @"NSFileTypeDirectory"]) fname = [fname stringByAppendingString:@"/"];
                
                NSString *mime = [self mimeForExt:[fname pathExtension]];
                if (mime) {
                    [outdata appendFormat:@"<a href=\"%@\">%@</a>		(%8.1f Kb, %@)<br />\n", [fname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], fname, [[fileDict objectForKey:NSFileSize] floatValue] / 1024, modDate];
                }
            }
        }
    }
    [outdata appendString:@"</p>"];
	
	[outdata appendString:@"<form action=\"\" method=\"post\" enctype=\"multipart/form-data\" name=\"form1\" id=\"form1\">"];
    [outdata appendString:@"<label>upload file"];
    [outdata appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
    [outdata appendString:@"</label>"];
    [outdata appendString:@"<label>"];
    [outdata appendString:@"<input type=\"submit\" name=\"button\" id=\"button\" value=\"Submit\" />"];
    [outdata appendString:@"</label>"];
    [outdata appendString:@"</form>"];
	
	// @"{\"results\":[{\"name\":\"test\"} , {\"name\":\"test1\"} ]}";
	[outdata appendString:@"<div id='json' style='display:none'>{{\"results\":["];
	for (NSString __strong *fname in array)
    {
        if ([fname length] > 0) {
            if (![[fname substringToIndex:1]isEqualToString:@"."]) {
                NSDictionary *jsonDict = [[NSFileManager defaultManager]attributesOfItemAtPath:[path stringByAppendingPathComponent:fname] error:nil];
                //NSLog(@"fileDict: %@", fileDict);
                
                if ([[jsonDict objectForKey:NSFileType] isEqualToString: @"NSFileTypeDirectory"]) fname = [fname stringByAppendingString:@"/"];
                // { name: "Acadia", location: "Maine, USA" },
                
                
                NSString *mime = [self mimeForExt:[fname pathExtension]];
                if (mime) {
                    // [outdata appendFormat:@"{\"name\": \"%@\"} ,", fname,  [[jsonDict objectForKey:NSFileSize] floatValue] / 1024];
                    [outdata appendFormat:@"{\"name\": \"%@\"} ,", fname];
                    
                    //[outdata appendFormat:@"\"<a href=\"%@\">%@</a>\"},\n", fname, fname, [[jsonDict objectForKey:NSFileSize] floatValue] / 1024];
                }
            }
        }
    }
    [outdata appendString:@" {\"name\":\"test1\"} ]}"];
    [outdata appendString:@"}</div>"];
	
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return outdata;
}

- (NSString *)mimeForExt:(NSString *)ext {
    NSString *mimeTypeString = nil;
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (mimeType) {
        mimeTypeString = (__bridge NSString *)mimeType;
    }
    else {
        mimeTypeString = @"application/octet-stream";
    }
    
    return mimeTypeString;
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate

- (void) processStartOfPartWithHeader:(MultipartMessageHeader *)header {
	// in this sample, we are not interested in parts, other then file parts.
	// check content disposition to find out filename

    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
	NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];

    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
		// an empty form sent. we won't handle it.
		return;
	}
    
    // This is necessary to handle spaces (which show up as "%20") in URLs properly.
	NSString *uploadDirPath = [[config documentRoot]stringByAppendingPathComponent:[[self requestURI]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
	BOOL isDir = YES;
	if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
		[[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
    NSString *filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        storeFile = nil;
    }
    else {
		HTTPLogVerbose(@"Saving file to %@", filePath);
		if (![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
			HTTPLogError(@"Could not create directory at path: %@", filePath);
		}
		if (![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
			HTTPLogError(@"Could not create file at path: %@", filePath);
		}
        
        storeFilePath = filePath;
        
		storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
}


- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header 
{
	// here we just write the output from parser to the file.
	if( storeFile ) {
		[storeFile writeData:data];
	}
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    // -importItemAtPathIfApplicable: must be called on the main thread.
    [[DataManager sharedDataManager]performSelectorOnMainThread:@selector(importItemAtPathIfApplicable:) withObject:storeFilePath waitUntilDone:YES];
    storeFilePath = nil;
    
	// as the file part is over, we close the file.
	[storeFile closeFile];
	storeFile = nil;
}

- (void) processPreambleData:(NSData*) data 
{
    // if we are interested in preamble data, we could process it here.

}

- (void) processEpilogueData:(NSData*) data 
{
    // if we are interested in epilogue data, we could process it here.

}

@end
