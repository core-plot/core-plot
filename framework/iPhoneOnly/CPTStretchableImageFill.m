//
//  LDStretchableImageFill.m
//  iLuxDemo
//
//  Created by Vitalii Topoliuk on 8/2/12.
//  Copyright (c) 2012 Luxoft. All rights reserved.
//

#import "CPTStretchableImageFill.h"

@implementation CPTStretchableImageFill

@synthesize stretchableImage = _stretchableImage;
@synthesize leftInset = _leftInset;
@synthesize rightInset = _rightInset;
@synthesize topInset = _topInset;
@synthesize bottomInset = _bottomInset;

- (id)initWithStretchableImage:(CPTNativeImage*)image
{
	NSParameterAssert(image != nil);
	
	self = [super init];
	if (self)
	{
		_stretchableImage = image;
	}
	
	return self;
}

- (id)init
{
	return [self initWithStretchableImage:nil];
}

#pragma mark -

- (id)copyWithZone:(NSZone*)zone
{
	CPTStretchableImageFill* copy = [[[self class] allocWithZone:zone] initWithStretchableImage:self.stretchableImage];
	copy.topInset = self.topInset;
	copy.bottomInset = self.bottomInset;
	copy.leftInset = self.leftInset;
	copy.rightInset = self.rightInset;
	
	return copy;
}

- (void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	theRect.origin.x += 0.5;
	theRect.origin.y += 0.5;
	[self.stretchableImage drawInRect:theRect];
}

- (void)fillPathInContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	
	CGRect bounds = CGContextGetPathBoundingBox(theContext);
	bounds = CGRectIntegral(bounds);
	
	CGContextClip(theContext);
	UIGraphicsPushContext(theContext);
	[self.stretchableImage drawInRect:bounds];
	UIGraphicsPopContext();
	
	CGContextRestoreGState(theContext);
}

@end
