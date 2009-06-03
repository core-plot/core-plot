//
//  KTTabItem.m
//  KTUIKit
//
//  Created by Cathy on 18/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTTabItem.h"


@implementation KTTabItem
@synthesize label = mLabel;
@synthesize identifier = mIdentifier;
@synthesize tabViewController = wTabViewController;
@synthesize viewController = wViewController;


- (id)initWithViewController:(KTViewController*)theViewController
{
	if(theViewController==nil)
	{
		[self release];
		return nil;
	}
	
	if(self = [super init])
	{
		wViewController = theViewController;
	}
	return self;
}

- (void)dealloc
{
	[mLabel release];
	[super dealloc];
}

@end
