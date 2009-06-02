//
//  KTView.m
//  KTUIKit
//
//  Created by Cathy Shive on 05/20/2008.
//
// Copyright (c) Cathy Shive
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "KTUIKit" by Cathy Shive" will do.

#import "KTView.h"

@implementation KTView

@synthesize mouseDownCanMoveWindow = mMouseDownCanMoveWindow;
@synthesize opaque = mOpaque;
@synthesize canBecomeKeyView = mCanBecomeKeyView;
@synthesize canBecomeFirstResponder = mCanBecomeFirstResponder;

//=========================================================== 
// - initWithFrame:
//=========================================================== 
- (id)initWithFrame:(NSRect)theFrame
{
	if(![super initWithFrame:theFrame])
		return nil;
	
	// Layout
	KTLayoutManager * aLayoutManger = [[[KTLayoutManager alloc] initWithView:self] autorelease];
	[self setViewLayoutManager:aLayoutManger];
	[self setAutoresizesSubviews:NO];
	
	// Styles
	KTStyleManager * aStyleManager = [[[KTStyleManager alloc] initWithView:self] autorelease];
	[self setStyleManager:aStyleManager];
	
	// For Debugging
	[self setLabel:@"KTView"];
	
	[self setOpaque:NO];
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	
	[theCoder encodeObject:[self viewLayoutManager] forKey:@"layoutManager"];
	[theCoder encodeObject:[self styleManager] forKey:@"styleManager"];
	[theCoder encodeObject:[self label] forKey:@"label"];

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
	[self setAutoresizesSubviews:NO];
	[self setAutoresizingMask:NSViewNotSizable];
	
	KTStyleManager * aStyleManager = [theCoder decodeObjectForKey:@"styleManager"];
	[aStyleManager setView:self];
	[self setStyleManager:aStyleManager];
	[self setOpaque:NO];
	[self setLabel:[theCoder decodeObjectForKey:@"label"]];
	return self;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{	
	[mLayoutManager release];
	[mStyleManager release];
	[mLabel release];
	[super dealloc];
}

//=========================================================== 
// - isOpaque
//=========================================================== 
- (BOOL)isOpaque
{
	return mOpaque;
}

//=========================================================== 
// - canBecomeKeyView
//=========================================================== 
- (BOOL)canBecomeKeyView
{
	return mCanBecomeKeyView;
}

//=========================================================== 
// - canBecomeFirstResponder
//=========================================================== 
- (BOOL)canBecomeFirstResponder
{
	return mCanBecomeFirstResponder;
}


//=========================================================== 
// - mouseDownCanMoveWindow
//=========================================================== 
- (BOOL)mouseDownCanMoveWindow
{
	return mMouseDownCanMoveWindow;
}


#pragma mark -
#pragma mark Drawing
//=========================================================== 
// - drawRect:
//=========================================================== 
- (void)drawRect:(NSRect)theRect
{	
	CGContextRef aContext = [[NSGraphicsContext currentContext] graphicsPort];
	[mStyleManager drawStylesInRect:theRect context:aContext view:self];
	[self drawInContext:aContext];
}

//=========================================================== 
// - drawInContext:
//=========================================================== 
- (void)drawInContext:(CGContextRef)theContext
{
	// subclasses can override this to do custom drawing over the styles
}


#pragma mark -
#pragma mark Layout protocol
//=========================================================== 
// - setViewLayoutManager:
//===========================================================
- (void)setViewLayoutManager:(KTLayoutManager*)theLayoutManager
{
	if(mLayoutManager != theLayoutManager)
	{
		[mLayoutManager release];
		mLayoutManager = [theLayoutManager retain];
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
// - setFrame:
//===========================================================
- (void)setFrame:(NSRect)theFrame
{
	[super setFrame:theFrame];
}


//=========================================================== 
// - setFrameSize:
//===========================================================
- (void)setFrameSize:(NSSize)theSize
{
	[super setFrameSize:theSize];
	NSArray * aSubviewList = [self children];
	int aSubviewCount = [aSubviewList count];
	int i;
	for(i = 0; i < aSubviewCount; i++)
	{
		NSView * aSubview = [aSubviewList objectAtIndex:i];
		
		// if the subview conforms to the layout protocol, tell its layout
		// manager to refresh its layout
		if( [aSubview conformsToProtocol:@protocol(KTViewLayout)] )
		{
			[[(KTView*)aSubview viewLayoutManager] refreshLayout];
		}
	}	
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
	return [super subviews];
}

//=========================================================== 
// - addSubview:
//===========================================================
- (void)addSubview:(NSView*)theView
{
	[super addSubview:theView];
	if(		[theView conformsToProtocol:@protocol(KTViewLayout)] == NO
		&&	[theView autoresizingMask] != NSViewNotSizable)
		[self setAutoresizesSubviews:YES];
}



#pragma mark -
#pragma mark KTStyle protocol
//=========================================================== 
// - setStyleManager:
//===========================================================
- (void)setStyleManager:(KTStyleManager*)theStyleManager
{
	if(mStyleManager != theStyleManager)
	{
		[mStyleManager release];
		mStyleManager = [theStyleManager retain];
	}
}

//=========================================================== 
// - styleManager
//===========================================================
- (KTStyleManager*)styleManager
{
	return mStyleManager;
}

//=========================================================== 
// - window
//===========================================================
- (NSWindow *)window
{
	return [super window];
}

#pragma mark -
#pragma mark KTView protocol
//=========================================================== 
// - setLabel:
//===========================================================
- (void)setLabel:(NSString*)theLabel
{
	if(mLabel != theLabel)
	{
		[mLabel release];
		mLabel = [[NSString alloc] initWithString:theLabel];
	}
}

//=========================================================== 
// - label
//===========================================================
- (NSString*)label
{
	return mLabel;
}



@end
