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
+(instancetype)fillWithColor:(CPTColor *)aColor
{
    return [[_CPTFillColor alloc] initWithColor:aColor];
}

/** @brief Creates and returns a new CPTFill instance initialized with a given gradient.
 *  @param aGradient The gradient.
 *  @return A new CPTFill instance initialized with the given gradient.
 **/
+(instancetype)fillWithGradient:(CPTGradient *)aGradient
{
    return [[_CPTFillGradient alloc] initWithGradient:aGradient];
}

/** @brief Creates and returns a new CPTFill instance initialized with a given image.
 *  @param anImage The image.
 *  @return A new CPTFill instance initialized with the given image.
 **/
+(instancetype)fillWithImage:(CPTImage *)anImage
{
    return [[_CPTFillImage alloc] initWithImage:anImage];
}

/** @brief Initializes a newly allocated CPTFill object with the provided color.
 *  @param aColor The color.
 *  @return The initialized CPTFill object.
 **/
-(instancetype)initWithColor:(CPTColor *)aColor
{
    self = [[_CPTFillColor alloc] initWithColor:aColor];

    return self;
}

/** @brief Initializes a newly allocated CPTFill object with the provided gradient.
 *  @param aGradient The gradient.
 *  @return The initialized CPTFill object.
 **/
-(instancetype)initWithGradient:(CPTGradient *)aGradient
{
    self = [[_CPTFillGradient alloc] initWithGradient:aGradient];

    return self;
}

/** @brief Initializes a newly allocated CPTFill object with the provided image.
 *  @param anImage The image.
 *  @return The initialized CPTFill object.
 **/
-(instancetype)initWithImage:(CPTImage *)anImage
{
    self = [[_CPTFillImage alloc] initWithImage:anImage];

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

-(instancetype)initWithCoder:(NSCoder *)coder
{
    id fill = [coder decodeObjectForKey:@"_CPTFillColor.fillColor"];

    if ( fill ) {
        return [self initWithColor:fill];
    }

    id gradient = [coder decodeObjectForKey:@"_CPTFillGradient.fillGradient"];
    if ( gradient ) {
        return [self initWithGradient:gradient];
    }

    id image = [coder decodeObjectForKey:@"_CPTFillImage.fillImage"];
    if ( image ) {
        return [self initWithImage:image];
    }

    return nil;
}

/// @endcond

@end

#pragma mark -

@implementation CPTFill(AbstractMethods)

/** @property BOOL opaque
 *  @brief If @YES, the fill is completely opaque.
 */
@dynamic opaque;

/** @property CGColorRef cgColor
 *  @brief Returns a @ref CGColorRef describing the fill if the fill can be represented as a color, @NULL otherwise.
 */
@dynamic cgColor;

#pragma mark -
#pragma mark Opacity

-(BOOL)isOpaque
{
    // do nothing--subclasses override to describe the fill opacity
    return NO;
}

#pragma mark -
#pragma mark Color

-(CGColorRef)cgColor
{
    // do nothing--subclasses override to describe the color
    return NULL;
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
