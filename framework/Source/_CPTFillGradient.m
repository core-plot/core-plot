#import "_CPTFillGradient.h"

#import "CPTGradient.h"

///	@cond
@interface _CPTFillGradient()

@property (nonatomic, readwrite, copy) CPTGradient *fillGradient;

@end

///	@endcond

/** @brief Draws CPTGradient area fills.
 *
 *	Drawing methods are provided to fill rectangular areas and arbitrary drawing paths.
 **/

@implementation _CPTFillGradient

/** @property fillGradient
 *  @brief The fill gradient.
 **/
@synthesize fillGradient;

#pragma mark -
#pragma mark init/dealloc

/** @brief Initializes a newly allocated _CPTFillGradient object with the provided gradient.
 *  @param aGradient The gradient.
 *  @return The initialized _CPTFillGradient object.
 **/
-(id)initWithGradient:(CPTGradient *)aGradient
{
	if ( (self = [super init]) ) {
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

/** @brief Draws the gradient into the given graphics context inside the provided rectangle.
 *  @param theRect The rectangle to draw into.
 *  @param theContext The graphics context to draw into.
 **/
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	[self.fillGradient fillRect:theRect inContext:theContext];
}

/** @brief Draws the gradient into the given graphics context clipped to the current drawing path.
 *  @param theContext The graphics context to draw into.
 **/
-(void)fillPathInContext:(CGContextRef)theContext
{
	[self.fillGradient fillPathInContext:theContext];
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	_CPTFillGradient *copy = [[[self class] allocWithZone:zone] init];

	copy->fillGradient = [self->fillGradient copyWithZone:zone];

	return copy;
}

#pragma mark -
#pragma mark NSCoding methods

-(Class)classForCoder
{
	return [CPTFill class];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.fillGradient forKey:@"_CPTFillGradient.fillGradient"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		fillGradient = [[coder decodeObjectForKey:@"_CPTFillGradient.fillGradient"] retain];
	}
	return self;
}

@end
