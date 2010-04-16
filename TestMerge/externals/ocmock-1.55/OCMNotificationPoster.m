//---------------------------------------------------------------------------------------
//  $Id: OCMNotificationPoster.m 50 2009-07-16 06:48:19Z erik $
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "OCMNotificationPoster.h"


@implementation OCMNotificationPoster

- (id)initWithNotification:(id)aNotification
{
	[super init];
	notification = [aNotification retain];
	return self;
}

- (void)dealloc
{
	[notification release];
	[super dealloc];
}

- (void)handleInvocation:(NSInvocation *)anInvocation
{
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}


@end
