//
//  CPFillImage.m
//  CorePlot
//

#import "_CPFillImage.h"


@implementation _CPFillImage

#pragma mark -
#pragma mark init/dealloc

-(id)initWithImage:(CGImageRef)anImage 
{
	if (self = [super init]) 
	{
		// initialization
		fillImage = CGImageRetain(anImage);
	}
	return self;
}

-(void)dealloc
{
	CGImageRelease(fillImage);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	// do nothing--subclasses override to do drawing here
}

-(void)fillPathInContext:(CGContextRef)theContext
{
	// do nothing--subclasses override to do drawing here
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CGImageRef fillCopy = CGImageCreateCopy(self->fillImage);
	_CPFillImage *copy = [[[self class] allocWithZone:zone] initWithImage:fillCopy];
	CGImageRelease(fillCopy);
	
	return copy;
}

@end
