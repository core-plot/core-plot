//
//  CPFillGradient.m
//  CorePlot
//

#import "_CPFillGradient.h"
#import "CPGradient.h"


@implementation _CPFillGradient

#pragma mark -
#pragma mark init/dealloc

-(id)initWithGradient:(CPGradient *)aGradient 
{
	if (self = [super init]) 
	{
		// initialization
		fillGradient = [aGradient retain];
	}
	return self;
}

-(void)dealloc
{
	[fillGradient release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	[fillGradient fillRect:theRect inContext:theContext];
}

-(void)fillPathInContext:(CGContextRef)theContext
{
	[fillGradient fillPathInContext:theContext];
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	_CPFillGradient *copy = [[[self class] allocWithZone:zone] initWithGradient:[self->fillGradient copy]];
	
	return copy;
}

@end
