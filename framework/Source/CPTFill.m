#import "CPTFill.h"

#import "CPTColor.h"
#import "CPTImage.h"
#import "_CPTFillColor.h"
#import "_CPTFillGradient.h"
#import "_CPTFillImage.h"

/** @brief Draws area fills.
 *
 *  CPTFill instances can be used to fill drawing areas with colors (including patterns),
 *  gradients, and images. Drawing methods are provided to fill rectangular areas and
 *  arbitrary drawing paths.
 **/

@implementation CPTFill

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPTFill instance initialized with a given color.
 *  @param aColor The color.
 *  @return A new CPTFill instance initialized with the given color.
 **/
+(CPTFill *)fillWithColor:(CPTColor *)aColor
{
    return [[(_CPTFillColor *)[_CPTFillColor alloc] initWithColor : aColor] autorelease];
}

/** @brief Creates and returns a new CPTFill instance initialized with a given gradient.
 *  @param aGradient The gradient.
 *  @return A new CPTFill instance initialized with the given gradient.
 **/
+(CPTFill *)fillWithGradient:(CPTGradient *)aGradient
{
    return [[[_CPTFillGradient alloc] initWithGradient:aGradient] autorelease];
}

/** @brief Creates and returns a new CPTFill instance initialized with a given image.
 *  @param anImage The image.
 *  @return A new CPTFill instance initialized with the given image.
 **/
+(CPTFill *)fillWithImage:(CPTImage *)anImage
{
    return [[(_CPTFillImage *)[_CPTFillImage alloc] initWithImage : anImage] autorelease];
}

/** @brief Initializes a newly allocated CPTFill object with the provided color.
 *  @param aColor The color.
 *  @return The initialized CPTFill object.
 **/
-(id)initWithColor:(CPTColor *)aColor
{
    [self release];

    self = [(_CPTFillColor *)[_CPTFillColor alloc] initWithColor : aColor];

    return self;
}

/** @brief Initializes a newly allocated CPTFill object with the provided gradient.
 *  @param aGradient The gradient.
 *  @return The initialized CPTFill object.
 **/
-(id)initWithGradient:(CPTGradient *)aGradient
{
    [self release];

    self = [[_CPTFillGradient alloc] initWithGradient:aGradient];

    return self;
}

/** @brief Initializes a newly allocated CPTFill object with the provided image.
 *  @param anImage The image.
 *  @return The initialized CPTFill object.
 **/
-(id)initWithImage:(CPTImage *)anImage
{
    [self release];

    self = [(_CPTFillImage *)[_CPTFillImage alloc] initWithImage : anImage];

    return self;
}

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    // do nothing--implemented in subclasses
    return nil;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    // do nothing--implemented in subclasses
}

-(id)initWithCoder:(NSCoder *)coder
{
    id fill = [coder decodeObjectForKey:@"_CPTFillColor.fillColor"];

    if ( fill ) {
        return [self initWithColor:fill];
    }

    fill = [coder decodeObjectForKey:@"_CPTFillGradient.fillGradient"];
    if ( fill ) {
        return [self initWithGradient:fill];
    }

    fill = [coder decodeObjectForKey:@"_CPTFillImage.fillImage"];
    if ( fill ) {
        return [self initWithImage:fill];
    }

    return self;
}

/// @endcond

@end

#pragma mark -

@implementation CPTFill(AbstractMethods)

/** @property BOOL opaque
 *  @brief If @YES, the fill is completely opaque.
 */
@dynamic opaque;

#pragma mark -
#pragma mark Opacity

-(BOOL)isOpaque
{
    // do nothing--subclasses override to describe the fill opacity
    return NO;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the gradient into the given graphics context inside the provided rectangle.
 *  @param rect The rectangle to draw into.
 *  @param context The graphics context to draw into.
 **/
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context
{
    // do nothing--subclasses override to do drawing here
}

/** @brief Draws the gradient into the given graphics context clipped to the current drawing path.
 *  @param context The graphics context to draw into.
 **/
-(void)fillPathInContext:(CGContextRef)context
{
    // do nothing--subclasses override to do drawing here
}

@end
