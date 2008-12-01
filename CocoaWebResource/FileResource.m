//
//  FileResource.m
//  iChm
//
//  Created by Robin Lu on 10/17/08.
//  Copyright 2008 robinlu.com. All rights reserved.
//

#import "FileResource.h"
#import "RegexKitLite.h"
#import "HTTPConnection.h"
#import "HTTPServer.h"
#import "HTTPResponse.h"

@implementation FileResource

@synthesize delegate;

+ (BOOL)canHandle:(CFHTTPMessageRef)request
{
	CFURLRef url = CFHTTPMessageCopyRequestURL(request);
	NSString* fullpath = [(NSString*)CFURLCopyPath(url) autorelease];
	NSString* path = [[fullpath componentsSeparatedByString:@"/"] objectAtIndex:1];
	path = [[path componentsSeparatedByString:@"."] objectAtIndex:0];
	NSComparisonResult rslt = [path caseInsensitiveCompare:@"files"];
	CFRelease(url);
	return rslt == NSOrderedSame;
}

- (id)initWithConnection:(HTTPConnection*)conn
{
	if (self = [self init])
	{
		request = conn.request;
		parameters = conn.params;
		connection = conn;
		[connection retain];
		delegate = nil;
	}
	return self;
}

- (void)dealloc
{
	[connection release];
	[super dealloc];
}

- (void)handleRequest
{
	CFURLRef url = CFHTTPMessageCopyRequestURL(request);
	NSString *method = (NSString *)CFHTTPMessageCopyRequestMethod(request);
	NSString* path = [(NSString*)CFURLCopyPath(url) autorelease];
	NSString *_method = [parameters objectForKey:@"_method"];
	
	if ([method isEqualToString:@"GET"])
	{
		if (NSOrderedSame == [path caseInsensitiveCompare:@"/files"])
			[self actionList];
		else
		{
			NSArray *segs = [path componentsSeparatedByString:@"/"];
			if ([segs count] >= 2)
			{
				NSString* fileName = [segs objectAtIndex:2];
				[self actionShow:fileName];
			}			
		}
	}
	else if (([method isEqualToString:@"POST"]) && _method && [[_method lowercaseString] isEqualToString:@"delete"])
	{
		NSArray *segs = [path componentsSeparatedByString:@"/"];
		if ([segs count] >= 2)
		{
			NSString* fileName = [segs objectAtIndex:2];
			[self actionDelete:fileName];
		}
	}
	else if (([method isEqualToString:@"POST"]))
	{
		[self actionNew];
	}
	
	CFRelease(url);
	[method release];
}

- (void)actionDelete:(NSString*)fileName
{
	if (delegate == nil)
	{
		[connection handleServiceUnavailable];
		return;
	}
	
	if  ([delegate respondsToSelector:@selector(fileShouldDelete:)])
	{
		[delegate fileShouldDelete:[fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
	}
	[connection redirectoTo:@"/"];	
}

- (void)actionList
{
	if (delegate == nil)
	{
		[connection handleResourceNotFound];
		return;
	}
	
	NSMutableString *output = [[NSMutableString alloc] init];
	[output appendString:@"["];
	for(int i = 0; i<[delegate numberOfFiles]; ++i)
	{
		NSString* filename = [delegate fileNameAtIndex:i];
		NSString* file = [filename stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"] ;
		[output appendFormat:@"{'name':'%@', 'id':%d},", file, i];
	}
	if ([output length] > 1)
	{
		NSRange range = NSMakeRange([output length] - 1, 1);
		[output replaceCharactersInRange:range withString:@"]"];
	}
	else
	{
		[output appendString:@"]"];
	}
	
	[connection sendString:output mimeType:nil];
	[output release];
}

- (void)actionShow:(NSString*)fileName
{
	if (delegate == nil)
	{
		[connection handleResourceNotFound];
		return;
	}
	
	NSString* filePath = [delegate filePathForFileName:[fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
	if (filePath == nil)
	{
		[connection handleResourceNotFound];
		return;
	}
	
	HTTPFileResponse* response = [[[HTTPFileResponse alloc] initWithFilePath:filePath] autorelease];
	[connection handleResponse:response method:@"GET"];
}

- (void)actionNew
{
	if (delegate == nil)
	{
		[connection handleServiceUnavailable];
		return;
	}
	
	NSString *tmpfile = [parameters objectForKey:@"tmpfilename"];
	NSString *filename = [parameters objectForKey:@"newfile"];
	if ([delegate respondsToSelector:@selector(newFileDidUpload:inTempPath:)])
		[delegate newFileDidUpload:filename inTempPath:tmpfile];
	
	[connection redirectoTo:@"/"];
}

@end
