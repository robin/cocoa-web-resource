#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
// Note: You may need to add the CFNetwork Framework to your project
#import <CFNetwork/CFNetwork.h>
#endif

@class AsyncSocket;
@class HTTPServer;
@class FileResource;
@protocol HTTPResponse;


#define HTTPConnectionDidDieNotification  @"HTTPConnectionDidDie"

@interface HTTPConnection : NSObject
{
	AsyncSocket *asyncSocket;
	HTTPServer *server;
	
	CFHTTPMessageRef request;
	NSMutableDictionary *params;
	int bodyReadCount;
	int bodyLength;
	NSData *remainBody;
	NSFileHandle *tmpUploadFileHandle;
	
	int numHeaderLines;
	NSString *requestBoundry;
	NSString *userAgent;
	
	NSString *nonce;
	int lastNC;
	
	NSObject<HTTPResponse> *httpResponse;
	
	FileResource *resource;
	
	NSMutableArray *ranges;
	NSMutableArray *ranges_headers;
	NSString *ranges_boundry;
	int rangeIndex;
}

@property (readonly) NSDictionary* params;
@property (readonly) CFHTTPMessageRef request;

- (id)initWithAsyncSocket:(AsyncSocket *)newSocket forServer:(HTTPServer *)myServer;

- (BOOL)isSecureServer;

- (NSArray *)sslIdentityAndCertificates;

- (BOOL)isPasswordProtected:(NSString *)path;

- (BOOL)useDigestAccessAuthentication;

- (NSString *)realm;
- (NSString *)passwordForUser:(NSString *)username;

- (NSString *)filePathForURI:(NSString *)path;

- (NSObject<HTTPResponse> *)httpResponseForURI:(NSString *)path;

- (void)redirectoTo:(NSString*)path;
- (void)sendString:(NSString*)text mimeType:(NSString*)mimeType;

- (void)handleVersionNotSupported:(NSString *)version;
- (void)handleAuthenticationFailed;
- (void)handleResourceNotFound;
- (void)handleServiceUnavailable;
- (void)handleInvalidRequest:(NSData *)data;
- (void)handleUnknownMethod:(NSString *)method;
- (void)handleHTTPRequestBody:(NSData*)data tag:(long)tag;
- (void)handleResponse:(NSObject<HTTPResponse> *)rsp method:(NSString*)method;

- (void)parsePostBody:(NSData*)data;

- (NSData *)preprocessResponse:(CFHTTPMessageRef)response;
- (NSData *)preprocessErrorResponse:(CFHTTPMessageRef)response;

- (void)die;

@end
