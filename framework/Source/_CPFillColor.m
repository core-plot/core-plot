
#import "_CPFillColor.h"
#import "CPColor.h"

///	@cond
@interface _CPFillColor()

@property (nonatomic, readwrite, copy) CPColor *fillColor;

@end
///	@endcond

/** @brief Draws CPColor area fills.
 *
 *	Drawing methods are provided to fill rectangular areas and arbitrary drawing paths.
 **/

@implementation _CPFillColor

/** @property fillColor
 *  @brief The fill color.
 **/
@synthesize fillColor;

#pragma mark -
#pragma mark init/dealloc

/** @brief Initializes a newly allocated _CPFillColor object with the provided color.
 *  @param aColor The color.
 *  @return The initialized _CPFillColor object.
 **/
-(id)initWithColor:(CPColor *)aColor 
{
	if ( self = [super init] ) {
        fillColor = [aColor retain];
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

/** @brief Draws the color into the given graphics context inside the provided rectangle.
 *  @param theRect The rectangle to draw into.
 *  @param theContext The graphics context to draw into.
 **/
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	CGContextSetFillColorWithColor(theContext, self.fillColor.cgColor);
	CGContextFillRect(theContext, theRect);
	CGContextRestoreGState(theContext);
}

/** @brief Draws the color into the given graphics context clipped to the current drawing path.
 *  @param theContext The graphics context to draw into.
 **/
-(void)fillPathInContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	CGContextSetFillColorWithColor(theContext, self.fillColor.cgColor);
	CGContextFillPath(theContext);
	CGContextRestoreGState(theContext);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	_CPFillColor *copy = [[[self class] allocWithZone:zone] init];
	copy->fillColor = [self->fillColor copyWithZone:zone];
	
	return copy;
}

#pragma mark -
#pragma mark NSCoding methods

-(Class)classForCoder
{
	return [CPFill class];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.fillColor forKey:@"fillColor"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( self = [super init] ) {
		fillColor = [[coder decodeObjectForKey:@"fillColor"] retain];
	}
    return self;
}

@end
