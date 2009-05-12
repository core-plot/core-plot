//
//  CPFillColor.m
//  CorePlot
//

#import "_CPFillColor.h"
#import "CPColor.h"


@implementation _CPFillColor

#pragma mark -
#pragma mark init/dealloc

-(id)initWithColor:(CPColor *)aColor 
{
	if (self = [super init]) {
        fillColor = [aColor copy];
	}
	return self;
}

-(void)dealloc
{
    [fillColor release];
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	CGContextSetFillColorWithColor(theContext, fillColor.cgColor);
	CGContextFillRect(theContext, theRect);
	CGContextRestoreGState(theContext);
}

-(void)fillPathInContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	CGContextSetFillColorWithColor(theContext, fillColor.cgColor);
	CGContextFillPath(theContext);
	CGContextRestoreGState(theContext);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CPColor *colorCopy = [fillColor copyWithZone:zone];
	_CPFillColor *copy = [(_CPFillColor *)[[self class] allocWithZone:zone] initWithColor:colorCopy];
	[colorCopy release];
	
	return copy;
}

@end
