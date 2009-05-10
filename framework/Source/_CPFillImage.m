//
//  CPFillImage.m
//  CorePlot
//

#import "_CPFillImage.h"
#import "CPImage.h"

@implementation _CPFillImage

#pragma mark -
#pragma mark init/dealloc

-(id)initWithImage:(CPImage *)anImage 
{
	if (self = [super init]) 
	{
		// initialization
		fillImage = [anImage retain];
	}
	return self;
}

-(void)dealloc
{
	[fillImage release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	[fillImage drawInRect:theRect inContext:theContext];
}

-(void)fillPathInContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	
	CGRect bounds = CGContextGetPathBoundingBox(theContext);
	CGContextClip(theContext);
	[fillImage drawInRect:bounds inContext:theContext];
	
	CGContextRestoreGState(theContext);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	_CPFillImage *copy = [[[self class] allocWithZone:zone] initWithImage:[self->fillImage copy]];
	
	return copy;
}

@end
