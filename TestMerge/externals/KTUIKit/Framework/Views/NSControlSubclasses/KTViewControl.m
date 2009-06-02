//
//  KTViewControl.m
//  KTUIKit
//
//  Created by Cathy Shive on 11/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KTViewControl.h"

@interface KTViewControl (Private)

@end

@implementation KTViewControl

@synthesize isEnabled = mIsEnabled;
@synthesize target = wTarget;
@synthesize action = wAction;

//=========================================================== 
// - initWithFrame:
//=========================================================== 
- (id)initWithFrame:(NSRect)theFrame
{
	if(![super initWithFrame:theFrame])
		return nil;
	mIsEnabled = YES;	
	return self;
}

//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{
	if (![super initWithCoder:theCoder])
		return nil;

	mIsEnabled = YES;
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
}


//=========================================================== 
// - performAction:
//=========================================================== 
- (void)performAction
{
	if([wTarget respondsToSelector:wAction])
		[wTarget performSelector:wAction withObject:self];
}

//=========================================================== 
// - setIsEnabled:
//=========================================================== 
- (void)setIsEnabled:(BOOL)theBool
{
	mIsEnabled = theBool;
	if(theBool==NO && [[self window] firstResponder]==self)
		[[self window] makeFirstResponder:nil];
	[self setNeedsDisplay:YES];
}
@end
