//
//  CPFill.m
//  CorePlot
//

#import "CPFill.h"
#import "CPFillColor.h"
#import "CPFillGradient.h"
#import "CPFillImage.h"


@implementation CPFill

#pragma mark -
#pragma mark init/dealloc

+(CPFill *)fillWithColor:(CGColorRef)aColor 
{
	return [[(CPFillColor *)[CPFillColor alloc] initWithColor: aColor] autorelease];
}

+(CPFill *)fillWithGradient:(CPGradient *)aGradient 
{
	return [[[CPFillGradient alloc] initWithGradient: aGradient] autorelease];
}

+(CPFill *)fillWithImage:(CGImageRef)anImage 
{
	return [[[CPFillImage alloc] initWithImage: anImage] autorelease];
}

-(id)initWithColor:(CGColorRef)aColor 
{
	[self release];
	
	self = [(CPFillColor *)[CPFillColor alloc] initWithColor: aColor];
	
	return self;
}

-(id)initWithGradient:(CPGradient *)aGradient 
{
	[self release];
	
	self = [[CPFillGradient alloc] initWithGradient: aGradient];
	
	return self;
}

-(id)initWithImage:(CGImageRef)anImage 
{
	[self release];
	
	self = [[CPFillImage alloc] initWithImage: anImage];
	
	return self;
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
	// do nothing--implemented in subclasses
	return nil;
}

@end
