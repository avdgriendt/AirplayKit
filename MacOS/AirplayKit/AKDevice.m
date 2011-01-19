//
//  AKDevice.m
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Resource Interactive. All rights reserved.
//

#import "AKDevice.h"


@implementation AKDevice

@synthesize hostname, port, delegate, connected, socket;

#pragma mark -
#pragma mark Initialization

- (id) init
{
	if(self = [super init])
	{
		connected = NO;
	}
	
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (void) sendRawMessage:(NSString *)message
{
	self.socket.delegate = self;
	[self.socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:20 tag:1];
	[self.socket readDataWithTimeout:20.0 tag:1];
}

- (void) sendReverse
{
	NSString *message = @"POST /reverse HTTP/1.1\n"
							"Content-Length: 0\n"
							"User-Agent: MediaControl/1.0\n"
							"Upgrade: PTTH/1.0\n"
							"Connection: Upgrade\n\n";
	
	[self sendRawMessage:message];
}

- (void) sendContentURL:(NSString *)url
{
	NSString *body = [[NSString alloc] initWithFormat:@"Content-Location: %@\n"
														"Start-Position: 0\n\n", url];
	int length = [body length];
	
	NSString *message = [[NSString alloc] initWithFormat:@"POST /play HTTP/1.1\n"
															 "Content-Length: %d\n"
															 "User-Agent: MediaControl/1.0\n\n%@", length, body];
	
	
	[self sendRawMessage:message];
	
	[body release];
	[message release];
}

- (void) sendImage:(NSImage *)image
{
	NSData *data = image.TIFFRepresentation; // May need to optimize.
	
	// Send the raw data
	self.socket.delegate = self;
	[self.socket writeData:data withTimeout:20 tag:1];
	[self.socket readDataWithTimeout:20.0 tag:1];
}

#pragma mark -
#pragma mark Socket Delegate

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"Recevied raw : %@", message);
}

#pragma mark -
#pragma mark Cleanup

- (void) dealloc
{
	[socket release];
	[hostname release];
	[super dealloc];
}

@end