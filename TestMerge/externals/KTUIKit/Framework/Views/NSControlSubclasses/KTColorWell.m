//
//  KTColorWell.m
//  KTUIKit
//
//  Created by Cathy Shive on 11/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KTColorWell.h"
#import "KTLayoutManager.h"

NSString* const KTColorWellDidActivateNotification = @"KTColorWellDidActivateNotification";

@implementation KTColorWell
//=========================================================== 
// - initWithFrame
//=========================================================== 
- (id)initWithFrame:(NSRect)theFrame
{
	if(![super initWithFrame:theFrame])
		return nil;
	
	// Layout
	KTLayoutManager * aLayoutManger = [[[KTLayoutManager alloc] initWithView:self] autorelease];
	[self setViewLayoutManager:aLayoutManger];
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	[theCoder encodeObject:[self viewLayoutManager] forKey:@"layoutManager"];
}

//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{
	if (![super initWithCoder:theCoder])
		return nil;
		
	KTLayoutManager * aLayoutManager = [theCoder decodeObjectForKey:@"layoutManager"];
	if(aLayoutManager == nil)
		aLayoutManager = [[[KTLayoutManager alloc] initWithView:self] autorelease];
	else
		[aLayoutManager setView:self];
	[self setViewLayoutManager:aLayoutManager];

	return self;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{	
	[mLayoutManager release];
	[super dealloc];
}

//=========================================================== 
// - activate:
//=========================================================== 
- (void)activate:(BOOL)exclusive
{
	// make NSColorWell slightly more friendly by broadcasting a notificaiton that it is is now active 
	// so that other custom views using the color panel can stop listening to the color changes
	[[NSNotificationCenter defaultCenter] postNotificationName:KTColorWellDidActivateNotification object:self userInfo:nil];
	[super activate:exclusive];
}

//=========================================================== 
// - setViewLayoutManager
//=========================================================== 
- (void)setViewLayoutManager:(KTLayoutManager*)theLayoutManager
{
	if(mLayoutManager != theLayoutManager)
	{
		[mLayoutManager release];
		mLayoutManager = [theLayoutManager retain];
		[self setAutoresizingMask:NSViewNotSizable];
	}
}

//=========================================================== 
// - viewLayoutManager
//=========================================================== 
- (KTLayoutManager*)viewLayoutManager
{
	return mLayoutManager;
}

//=========================================================== 
// - setFrame
//=========================================================== 
- (void)setFrame:(NSRect)theFrame
{
	[super setFrame:theFrame];
}

//=========================================================== 
// - frame
//=========================================================== 
- (NSRect)frame
{
	return [super frame];
}

//=========================================================== 
// - parent
//=========================================================== 
- (id<KTViewLayout>)parent
{
	if([[self superview] conformsToProtocol:@protocol(KTViewLayout)])
		return (id<KTViewLayout>)[self superview];
	else
		return nil;
}

//=========================================================== 
// - children
//=========================================================== 
- (NSArray*)children
{
	return nil;
}

@end
