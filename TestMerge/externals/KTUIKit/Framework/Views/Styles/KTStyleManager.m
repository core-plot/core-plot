//
//  KTStyleManager.m
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


/*
 (CS 11/12/08) This is a very basic implementation of the style manager
 you can configure it and it will draw. The plan is to eventually
 create a 'style sheet' object that can be used with bindings
 so that users can bind specific elements to the style sheet in IB. 
 Also the style manager should deal with color changes for different key states of views and their windows All for the future...
*/


#import "KTStyleManager.h"
#import "KTView.h"

#define kKTStyleManagerBackgroundColorKey @"backgroundColor"
#define kKTStyleManagerBackgroundGradientKey @"backgroundGradient"
#define kKTStyleManagerBackgroundGradientAngleKey @"gradientAngle"
#define kKTStyleManagerBorderWidthTopKey @"borderWidthTop"
#define kKTStyleManagerBorderWidthRightKey @"borderWidthRight"
#define kKTStyleManagerBorderWidthBottomKey @"borderWidthBottom"
#define kKTStyleManagerBorderWidthLeftKey @"borderWidthLeft"
#define kKTStyleManagerBorderColorTopKey @"borderColorTop"
#define kKTStyleManagerBorderColorRightKey @"borderColorRight"
#define kKTStyleManagerBorderColorBottomKey @"borderColorBottom"
#define kKTStyleManagerBorderColorLeftKey @"borderColorLeft"

@interface KTStyleManager (Private)
- (NSArray*)keysForCoding;
@end


@implementation KTStyleManager

@synthesize backgroundColor = mBackgroundColor;
@synthesize borderColorTop = mBorderColorTop;
@synthesize borderColorRight = mBorderColorRight;
@synthesize borderColorBottom = mBorderColorBottom;
@synthesize borderColorLeft = mBorderColorLeft;
@synthesize	borderWidthTop = mBorderWidthTop;
@synthesize borderWidthRight = mBorderWidthRight;
@synthesize borderWidthBottom = mBorderWidthBottom;
@synthesize borderWidthLeft = mBorderWidthLeft;
@synthesize backgroundGradient = mBackgroundGradient;
@synthesize gradientAngle = mGradientAngle;

//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithView:(id<KTStyle>)theView
{
	if(![super init])
		return self;
	
	[self setView:theView];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setBorderColorTop:[NSColor clearColor] right:[NSColor clearColor] bottom:[NSColor clearColor] left:[NSColor clearColor]];
	[self setBackgroundGradient:nil angle:0];
	[self setBorderWidth:0];
	return self;
}

//=========================================================== 
// - dealloc:
//=========================================================== 
- (void)dealloc
{
	[mBackgroundColor release];
	[mBorderColorTop release];
	[mBorderColorRight release];
	[mBorderColorBottom release];
	[mBorderColorLeft release];
	[mBackgroundGradient release];
	[mBackgroundImage release];
	
	[super dealloc];
}


//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{
	if ([[self superclass] instancesRespondToSelector:@selector(initWithCoder:)]) {
		if (![(id)super initWithCoder:theCoder])
			return nil;
	}
	
	for (NSString *key in [self keysForCoding])
		[self setValue:[theCoder decodeObjectForKey:key] forKey:key];
	
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{
	if ([[self superclass] instancesRespondToSelector:@selector(encodeWithCoder:)])
		[(id)super encodeWithCoder:theCoder];
	for (NSString *key in [self keysForCoding])
		[theCoder encodeObject:[self valueForKey:key] forKey:key];
}

//=========================================================== 
// - keysForCoding
//=========================================================== 
- (NSArray *)keysForCoding
{
	return [NSArray arrayWithObjects:kKTStyleManagerBackgroundColorKey,
									 kKTStyleManagerBackgroundGradientKey, 
									 kKTStyleManagerBackgroundGradientAngleKey, 
									 kKTStyleManagerBorderWidthTopKey, 
									 kKTStyleManagerBorderWidthRightKey, 
									 kKTStyleManagerBorderWidthBottomKey, 
									 kKTStyleManagerBorderWidthLeftKey, 
									 kKTStyleManagerBorderColorTopKey, 
									 kKTStyleManagerBorderColorRightKey, 
									 kKTStyleManagerBorderColorBottomKey, 
									 kKTStyleManagerBorderColorLeftKey, nil];
}

//=========================================================== 
// - setNilValueForKey:
//=========================================================== 
- (void)setNilValueForKey:(NSString *)key;
{
	if([key isEqualToString:kKTStyleManagerBackgroundGradientAngleKey])
		[self setGradientAngle:0.0];
	else if([key isEqualToString:kKTStyleManagerBorderWidthTopKey])
		[self setBorderWidthTop:0.0];
	else if([key isEqualToString:kKTStyleManagerBorderWidthRightKey])
		[self setBorderWidthRight:0.0];
	else if([key isEqualToString:kKTStyleManagerBorderWidthBottomKey])
		[self setBorderWidthBottom:0.0];
	else if([key isEqualToString:kKTStyleManagerBorderWidthLeftKey])
		[self setBorderWidthLeft:0.0];

	else
		[super setNilValueForKey:key];
}

//=========================================================== 
// - setView:
//=========================================================== 
- (void)setView:(id<KTStyle>)theView
{
	wView = theView;
}


//=========================================================== 
// - drawStylesInRect:
//=========================================================== 
- (void)drawStylesInRect:(NSRect)theRect context:(CGContextRef)theContext view:(id<KTStyle>)theView
{
	NSRect aViewBounds = [(NSView*)theView bounds];
	CGFloat r, g, b, a;
	
	// Background
	
	// Either draw a background gradient of solid color fill
	
	// not sure how to partially draw a gradient, so we'll have it draw in the entire view bounds
	// would like to find a way to optimize this
	if(mBackgroundGradient != nil)
		[mBackgroundGradient drawInRect:aViewBounds angle:mGradientAngle];
	else if(mBackgroundColor != [NSColor clearColor])
	{
		[[mBackgroundColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
		CGContextSetRGBFillColor(theContext, r, g, b, a);
		
		// only draw the dirty rect
		CGContextFillRect(theContext, NSRectToCGRect(theRect));
	}
	
	// also need to figure out a way to optimize image drawing so it only draws in the dirty rect of the view
	if(mBackgroundImage != nil)
	{
		NSPoint anImagePoint = aViewBounds.origin;
		NSSize anImageSize = [mBackgroundImage size];
		
		NSData * anImageData = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [mBackgroundImage representations]];
		CGImageSourceRef aCGImageSourceRef = CGImageSourceCreateWithData((CFDataRef)anImageData, NULL);
		CGImageRef aCGBackgroundImage = CGImageSourceCreateImageAtIndex(aCGImageSourceRef, 0, NULL);
		
		if(mTileImage)
			CGContextDrawTiledImage(theContext, CGRectMake(anImagePoint.x,anImagePoint.y, anImageSize.width, anImageSize.height), aCGBackgroundImage);
		else 
			CGContextDrawImage(theContext, CGRectMake(anImagePoint.x,anImagePoint.y, anImageSize.width, anImageSize.height), aCGBackgroundImage);	
		
		CFRelease(aCGImageSourceRef);
		CGImageRelease(aCGBackgroundImage);		
	}
	
	
	
	// Stroke - we can control color & line thickness of individual sides of the rectangle

	CGContextSetLineWidth(theContext, 1);
	NSPoint	aStrokePoint = aViewBounds.origin;
	
	// move the point to the top left corner to begin
	aStrokePoint.y = aViewBounds.size.height - .5;
	
	// Top
	// only draw if the top stroke is visible in the dirty rect
	if(aStrokePoint.y <= NSMaxY(theRect))
	{
		if(		mBorderWidthTop > 0 
			&&	mBorderColorTop != [NSColor clearColor])
		{
			CGContextBeginPath(theContext);
			CGContextMoveToPoint(theContext, aStrokePoint.x,  aStrokePoint.y);
			aStrokePoint.x+=aViewBounds.size.width - .5;
			CGContextAddLineToPoint(theContext, aStrokePoint.x,  aStrokePoint.y);
			CGContextSetLineWidth(theContext, mBorderWidthTop);
			[[mBorderColorTop colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
			CGContextSetRGBStrokeColor(theContext, r, g, b, a);
			CGContextStrokePath(theContext);
		}
		else
		{
			aStrokePoint.x += aViewBounds.size.width - .5;
		}
	}
	else // i know this is a dumb structure, will refactor after I'm certain everything is drawing OK.
	{
		aStrokePoint.x += aViewBounds.size.width - .5;
	}
	
	// Right
	
	// only draw if the right stroke is visible in the dirty rect
	if(aStrokePoint.x <= NSMaxX(theRect))
	{
		if(		mBorderWidthRight > 0 
			&&	mBorderColorRight != [NSColor clearColor])
		{
			CGContextBeginPath(theContext);
			CGContextMoveToPoint(theContext, aStrokePoint.x,  aStrokePoint.y);
			aStrokePoint.y-=aViewBounds.size.height - 1;  
			CGContextAddLineToPoint(theContext, aStrokePoint.x,  aStrokePoint.y);
			CGContextSetLineWidth(theContext, mBorderWidthRight);
			[[mBorderColorRight colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
			CGContextSetRGBStrokeColor(theContext, r, g, b, a);
			CGContextStrokePath(theContext);
		}
		else
		{
			aStrokePoint.y -= aViewBounds.size.height - 1;
		}
	}
	else
	{
		aStrokePoint.y -= aViewBounds.size.height - 1;
	}
	
	// Bottom
	// only draw if the bottom is visible in the dirty rect
	if(aStrokePoint.y>=NSMinY(theRect))
	{
		if(		mBorderWidthBottom > 0 
			&&	mBorderColorBottom != [NSColor clearColor])
		{
			CGContextBeginPath(theContext);
			CGContextMoveToPoint(theContext, aStrokePoint.x,  aStrokePoint.y);
			aStrokePoint.x-=aViewBounds.size.width - 1;     
			CGContextAddLineToPoint(theContext, aStrokePoint.x,  aStrokePoint.y);
			CGContextSetLineWidth(theContext, mBorderWidthBottom);
			[[mBorderColorBottom colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
			CGContextSetRGBStrokeColor(theContext, r, g, b, a);							   
			CGContextStrokePath(theContext);
		}
		else
		{
			aStrokePoint.x -= aViewBounds.size.width - 1;
		}
	}
	else
	{
		aStrokePoint.x -= aViewBounds.size.width - 1;	
	}
	
	// Left
	
	// only draw if the left stroke is visible in the dirty rect
	if(aStrokePoint.x >= NSMinX(theRect))
	{
		if(		mBorderWidthLeft > 0 
			&&	mBorderColorLeft != [NSColor clearColor])
		{
			CGContextBeginPath(theContext);
			CGContextMoveToPoint(theContext, aStrokePoint.x,  aStrokePoint.y);
			aStrokePoint.y+=aViewBounds.size.height; 
			CGContextAddLineToPoint(theContext, aStrokePoint.x,  aStrokePoint.y);
			CGContextSetLineWidth(theContext, mBorderWidthLeft);
			[[mBorderColorLeft colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
			CGContextSetRGBStrokeColor(theContext, r, g, b, a);
			CGContextStrokePath(theContext);
		}
	}
}


//=========================================================== 
// - setBorderWidth:
//=========================================================== 
- (void)setBorderWidth:(CGFloat)theWidth
{
	[self setBorderWidthTop:theWidth right:theWidth bottom:theWidth left:theWidth];
}

//=========================================================== 
// - setBorderWidthTop:right:bottom:left
//=========================================================== 
- (void)setBorderWidthTop:(CGFloat)theTopWidth right:(CGFloat)theRightWidth bottom:(CGFloat)theBottomWidth left:(CGFloat)theLeftWidth
{
	[self setBorderWidthTop:theTopWidth];
	[self setBorderWidthRight:theRightWidth];
	[self setBorderWidthBottom:theBottomWidth];
	[self setBorderWidthLeft:theLeftWidth];
}


//=========================================================== 
// - setBackgroundImage:
//=========================================================== 
- (void)setBackgroundImage:(NSImage*)theBackgroundImage tile:(BOOL)theBool
{
	if(mBackgroundImage != theBackgroundImage)
	{
		[theBackgroundImage retain];
		[mBackgroundImage release];
		mBackgroundImage = theBackgroundImage;
	}
	mTileImage = theBool;
	if(mTileImage)
	{
		if([wView isKindOfClass:[KTView class]])
			[(KTView*)wView setOpaque:YES];	
	}
}


// either save a gradient or a fill color
//=========================================================== 
// - setBackgroundColor:
//=========================================================== 
- (void)setBackgroundColor:(NSColor*)theColor
{
	if(mBackgroundColor!=theColor)
	{
		[mBackgroundColor release];
		mBackgroundColor = [theColor retain];
		if(mBackgroundColor!=nil)
			[self setBackgroundGradient:nil];
			
		if(		[mBackgroundColor alphaComponent] >= 1
			&&	[wView isKindOfClass:[KTView class]])
			[(KTView*)wView setOpaque:YES];
	}
}

//=========================================================== 
// - setBackgroundGradient:
//=========================================================== 
- (void)setBackgroundGradient:(NSGradient*)theGradient
{
	if(mBackgroundGradient!=theGradient)
	{
		[mBackgroundGradient release];
		mBackgroundGradient = [theGradient retain];
		if(mBackgroundGradient!=nil)
			[self setBackgroundColor:nil];
	}
}

//=========================================================== 
// - setBackgroundGradient:angle
//=========================================================== 
- (void)setBackgroundGradient:(NSGradient*)theGradient angle:(CGFloat)theAngle
{
	[self setBackgroundGradient:theGradient];
	[self setGradientAngle:theAngle];
}

//=========================================================== 
// - setBorderColor:
//=========================================================== 
- (void)setBorderColor:(NSColor*)theColor
{
	[self setBorderColorTop:theColor right:theColor bottom:theColor left:theColor];
}

//=========================================================== 
// - setBorderColor:
//=========================================================== 
- (void)setBorderColorTop:(NSColor*)theTopColor right:(NSColor*)theRightColor bottom:(NSColor*)theBottomColor left:(NSColor*)theLeftColor
{
	[self setBorderColorTop:theTopColor];
	[self setBorderColorRight:theRightColor];
	[self setBorderColorBottom:theBottomColor];
	[self setBorderColorLeft:theLeftColor];
}

@end
