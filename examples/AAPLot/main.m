//
//  main.m
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright Sounds Broken inc. 2009. All rights reserved.
//

#ifdef DEBUG
#if TARGET_IPHONE_SIMULATOR
#import <Foundation/NSDebug.h>
#import "GTMStackTrace.h"

void exceptionHandler(NSException *exception) {
	NSLog(@"%@", GTMStackTraceFromException(exception));
}
#endif
#endif

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
#ifdef DEBUG
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"Debug enabled");	
	NSDebugEnabled = YES;
	NSZombieEnabled = YES;
	NSDeallocateZombies = NO;
	NSHangOnUncaughtException = YES;
	[NSAutoreleasePool enableFreedObjectCheck:YES];
	NSSetUncaughtExceptionHandler(&exceptionHandler);
#endif	
#endif
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, nil);
	[pool release];
	return retVal;
}