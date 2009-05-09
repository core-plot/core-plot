//
//  CPFillColor.m
//  CorePlot
//

#import "_CPFillColor.h"


@implementation _CPFillColor

#pragma mark -
#pragma mark init/dealloc

-(id)initWithColor:(CGColorRef)aColor 
{
	if (self = [super init]) 
	{
		// initialization
		fillColor = CGColorRetain(aColor);
	}
	return self;
}

-(void)dealloc
{
	CGColorRelease(fillColor);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	CGContextSetFillColorWithColor(theContext, fillColor);
	CGContextFillRect(theContext, theRect);
	CGContextRestoreGState(theContext);
}

-(void)fillPathInContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	CGContextSetFillColorWithColor(theContext, fillColor);
	CGContextFillPath(theContext);
	CGContextRestoreGState(theContext);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CGColorRef fillCopy = CGColorCreateCopy(self->fillColor);
	_CPFillColor *copy = [(_CPFillColor *)[[self class] allocWithZone:zone] initWithColor:fillCopy];
	CGColorRelease(fillCopy);
	
	return copy;
}

@end
