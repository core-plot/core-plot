
#import "CPFill.h"
#import "_CPFillColor.h"
#import "_CPFillGradient.h"
#import "_CPFillImage.h"
#import "CPColor.h"
#import "CPImage.h"

/** @brief Draws area fills.
 *
 *	CPFill instances can be used to fill drawing areas with colors (including patterns),
 *	gradients, and images. Drawing methods are provided to fill rectangular areas and
 *	arbitrary drawing paths.
 **/

@implementation CPFill

/// @defgroup CPFill CPFill
/// @{

#pragma mark -
#pragma mark init/dealloc

/** @brief Creates and returns a new CPFill instance initialized with a given color.
 *  @param aColor The color.
 *  @return A new CPFill instance initialized with the given color.
 **/
+(CPFill *)fillWithColor:(CPColor *)aColor 
{
	return [[(_CPFillColor *)[_CPFillColor alloc] initWithColor:aColor] autorelease];
}

/** @brief Creates and returns a new CPFill instance initialized with a given gradient.
 *  @param aGradient The gradient.
 *  @return A new CPFill instance initialized with the given gradient.
 **/
+(CPFill *)fillWithGradient:(CPGradient *)aGradient 
{
	return [[[_CPFillGradient alloc] initWithGradient: aGradient] autorelease];
}

/** @brief Creates and returns a new CPFill instance initialized with a given image.
 *  @param anImage The image.
 *  @return A new CPFill instance initialized with the given image.
 **/
+(CPFill *)fillWithImage:(CPImage *)anImage 
{
	return [[(_CPFillImage *)[_CPFillImage alloc] initWithImage:anImage] autorelease];
}

/** @brief Initializes a newly allocated CPFill object with the provided color.
 *  @param aColor The color.
 *  @return The initialized CPFill object.
 **/
-(id)initWithColor:(CPColor *)aColor 
{
	[self release];
	
	self = [(_CPFillColor *)[_CPFillColor alloc] initWithColor: aColor];
	
	return self;
}

/** @brief Initializes a newly allocated CPFill object with the provided gradient.
 *  @param aGradient The gradient.
 *  @return The initialized CPFill object.
 **/
-(id)initWithGradient:(CPGradient *)aGradient 
{
	[self release];
	
	self = [[_CPFillGradient alloc] initWithGradient: aGradient];
	
	return self;
}

/** @brief Initializes a newly allocated CPFill object with the provided image.
 *  @param anImage The image.
 *  @return The initialized CPFill object.
 **/
-(id)initWithImage:(CPImage *)anImage 
{
	[self release];
	
	self = [(_CPFillImage *)[_CPFillImage alloc] initWithImage: anImage];
	
	return self;
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	// do nothing--implemented in subclasses
	return nil;
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	// do nothing--implemented in subclasses
}

-(id)initWithCoder:(NSCoder *)coder
{
	// do nothing--implemented in subclasses
	return nil;
}

///	@}

@end

///	@brief CPFill abstract methods—must be overridden by subclasses
@implementation CPFill(AbstractMethods)

/// @addtogroup CPFill
/// @{

#pragma mark -
#pragma mark Drawing

/** @brief Draws the gradient into the given graphics context inside the provided rectangle.
 *  @param theRect The rectangle to draw into.
 *  @param theContext The graphics context to draw into.
 **/
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	// do nothing--subclasses override to do drawing here
}

/** @brief Draws the gradient into the given graphics context clipped to the current drawing path.
 *  @param theContext The graphics context to draw into.
 **/
-(void)fillPathInContext:(CGContextRef)theContext
{
	// do nothing--subclasses override to do drawing here
}

///	@}

@end
