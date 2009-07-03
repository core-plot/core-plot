
#import "_CPFillGradient.h"
#import "CPGradient.h"

@interface _CPFillGradient()

@property (nonatomic, readwrite, copy) CPGradient *fillGradient;

@end

@implementation _CPFillGradient

@synthesize fillGradient;

#pragma mark -
#pragma mark init/dealloc

-(id)initWithGradient:(CPGradient *)aGradient 
{
	if (self = [super init]) 
	{
		// initialization
		self.fillGradient = aGradient;
	}
	return self;
}

-(void)dealloc
{
	self.fillGradient = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	[self.fillGradient fillRect:theRect inContext:theContext];
}

-(void)fillPathInContext:(CGContextRef)theContext
{
	[self.fillGradient fillPathInContext:theContext];
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	_CPFillGradient *copy = [[[self class] allocWithZone:zone] initWithGradient:[self.fillGradient copyWithZone:zone]];
	
	return copy;
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.fillGradient forKey:@"fillGradient"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( self = [super init] ) {
		fillGradient = [[coder decodeObjectForKey:@"fillGradient"] retain];
	}
	return self;
}

@end
