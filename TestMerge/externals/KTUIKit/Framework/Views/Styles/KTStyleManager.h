//
//  KTStyleManager.h
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

#import <Cocoa/Cocoa.h>
#import "KTStyle.h"

@interface KTStyleManager : NSObject 
{
	NSColor *			mBackgroundColor;
	NSColor *			mBorderColorTop;
	NSColor *			mBorderColorRight;
	NSColor *			mBorderColorBottom;
	NSColor *			mBorderColorLeft;
	//NSColor *			mRoundedRectBorderColor;
	//BOOL				mDrawAsRoundedRect;
	
	CGFloat				mBorderWidthTop;
	CGFloat				mBorderWidthRight;
	CGFloat				mBorderWidthBottom;
	CGFloat				mBorderWidthLeft;
	//CGFloat				mRoundedRectBorderWidth;
	
	NSGradient *		mBackgroundGradient;
	CGFloat				mGradientAngle;
	NSImage *			mBackgroundImage;
	BOOL				mTileImage;
	
	id<KTStyle>			wView;
}

@property(readwrite,retain) NSColor * backgroundColor;
@property(readwrite,retain) NSGradient * backgroundGradient;
@property(readwrite,assign) CGFloat gradientAngle;
@property(readwrite,retain) NSColor * borderColorTop;
@property(readwrite,retain) NSColor * borderColorRight;
@property(readwrite,retain) NSColor * borderColorBottom;
@property(readwrite,retain) NSColor * borderColorLeft;
@property(readwrite,assign) CGFloat	borderWidthTop;
@property(readwrite,assign) CGFloat borderWidthRight;
@property(readwrite,assign) CGFloat borderWidthBottom;
@property(readwrite,assign) CGFloat borderWidthLeft;

- (id)initWithView:(id<KTStyle>)theView;
- (void)setView:(id<KTStyle>)theView;

// Extra configuration API
- (void)setBackgroundImage:(NSImage*)theBackgroundImage tile:(BOOL)theBool;
- (void)setBackgroundGradient:(NSGradient*)theGradient angle:(CGFloat)theAngle;
- (void)setBorderColor:(NSColor*)theColor;
- (void)setBorderColorTop:(NSColor*)TheTopColor right:(NSColor*)theRightColor bottom:(NSColor*)theBottomColor left:(NSColor*)theLeftColor;
- (void)setBorderWidth:(CGFloat)theWidth;
- (void)setBorderWidthTop:(CGFloat)theTopWidth right:(CGFloat)theRightWidth bottom:(CGFloat)theBottomWidth left:(CGFloat)theLeftWidth;
- (void)drawStylesInRect:(NSRect)TheFrame context:(CGContextRef)theContext view:(id<KTStyle>)theView;


@end
