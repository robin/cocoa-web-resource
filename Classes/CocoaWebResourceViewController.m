//
//  CocoaWebResourceViewController.m
//  CocoaWebResource
//
//  Created by Robin Lu on 12/1/08.
//  Copyright robinlu.com 2008. All rights reserved.
//

#import "CocoaWebResourceViewController.h"

@implementation CocoaWebResourceViewController

// load file list
- (void)loadFileList
{
	[fileList removeAllObjects];
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager]
									  enumeratorAtPath:docDir];
	NSString *pname;
	while (pname = [direnum nextObject])
	{
		[fileList addObject:pname];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	fileList = [[NSMutableArray alloc] init];
	[self loadFileList];
	
	// set up the http server
	httpServer = [[HTTPServer alloc] init];
	[httpServer setType:@"_http._tcp."];	
	[httpServer setPort:8080];
	[httpServer setName:@"CocoaWebResource"];
	[httpServer setupBuiltInDocroot];
	httpServer.fileResourceDelegate = self;

    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	httpServer.fileResourceDelegate = nil;
	[httpServer release];
	[fileList release];
    [super dealloc];
}

#pragma mark actions
- (IBAction)toggleService:(id)sender
{
	NSError *error;
	if ([(UISwitch*)sender isOn])
	{
		BOOL serverIsRunning = [httpServer start:&error];
		if(!serverIsRunning)
		{
			NSLog(@"Error starting HTTP Server: %@", error);
		}		
		[urlLabel setText:[NSString stringWithFormat:@"http://%@:%d", [httpServer hostName], [httpServer port]]];
	}
	else
	{
		[httpServer stop];
		[urlLabel setText:@""];
	}
}

#pragma mark WebFileResourceDelegate
// number of the files
- (NSInteger)numberOfFiles
{
	return [fileList count];
}

// the file name by the index
- (NSString*)fileNameAtIndex:(NSInteger)index
{
	return [fileList objectAtIndex:index];
}

// provide full file path by given file name
- (NSString*)filePathForFileName:(NSString*)filename
{
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}

// handle newly uploaded file. After uploading, the file is stored in
// the temparory directory, you need to implement this method to move
// it to proper location and update the file list.
- (void)newFileDidUpload:(NSString*)name inTempPath:(NSString*)tmpPath
{
	if (name == nil || tmpPath == nil)
		return;
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	NSString *path = [NSString stringWithFormat:@"%@/%@", docDir, name];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	if (![fm moveItemAtPath:tmpPath toPath:path error:&error])
	{
		NSLog(@"can not move %@ to %@ because: %@", tmpPath, path, error );
	}
		
	[self loadFileList];
	
}

// implement this method to delete requested file and update the file list
- (void)fileShouldDelete:(NSString*)fileName
{
	NSString *path = [self filePathForFileName:fileName];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	if(![fm removeItemAtPath:path error:&error])
	{
		NSLog(@"%@ can not be removed because:%@", path, error);
	}
	[self loadFileList];
}

@end
