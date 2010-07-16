//
//  FileResource.h
//  iChm
//
//  Created by Robin Lu on 10/17/08.
//  Copyright 2008 robinlu.com. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CFNetwork/CFHTTPMessage.h>
@class HTTPConnection;

@protocol WebFileResourceDelegate <NSObject>

@required
// number of the files
- (NSInteger)numberOfFiles;

// the file name by the index
- (NSString*)fileNameAtIndex:(NSInteger)index;

// provide full file path by given file name
- (NSString*)filePathForFileName:(NSString*)filename;
@optional
// handle newly uploaded file. After uploading, the file is stored in
// the temparory directory, you need to implement this method to move
// it to proper location and update the file list.
- (void)newFileDidUpload:(NSString*)name inTempPath:(NSString*)tmpPath;

// implement this method to delete requested file and update the file list
- (void)fileShouldDelete:(NSString*)fileName;

@end


@interface FileResource : NSObject {
	CFHTTPMessageRef request;
	NSDictionary *parameters;
	HTTPConnection *connection;
	id <WebFileResourceDelegate> delegate;
}

@property (assign, nonatomic) id <WebFileResourceDelegate> delegate;

+ (BOOL)canHandle:(CFHTTPMessageRef)request;

- (id)initWithConnection:(HTTPConnection*)conn;

- (void)handleRequest;
- (void)actionList;
- (void)actionDelete:(NSString*)fileName;
- (void)actionShow:(NSString*)fileName;
- (void)actionNew;
@end
