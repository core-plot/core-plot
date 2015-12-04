#import "_CPTFillImage.h"

#import "CPTImage.h"

/// @cond
@interface _CPTFillImage()

@property (nonatomic, readwrite, copy, nullable) CPTImage *fillImage;

@end

/// @endcond

/** @brief Draws CPTImage area fills.
 *
 *  Drawing methods are provided to fill rectangular areas and arbitrary drawing paths.
 **/

@implementation _CPTFillImage

/** @property CPTImage *fillImage
 *  @brief The fill image.
 **/
@synthesize fillImage;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated _CPTFillImage object with the provided image.
 *  @param anImage The image.
 *  @return The initialized _CPTFillImage object.
 **/
-(instancetype)initWithImage:(CPTImage *)anImage
{
    if ( (self = [super init]) ) {
        fillImage = anImage;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the image into the given graphics context inside the provided rectangle.
 *  @param rect The rectangle to draw into.
 *  @param context The graphics context to draw into.
 **/
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context
{
    [self.fillImage drawInRect:rect inContext:context];
}

/** @brief Draws the image into the given graphics context clipped to the current drawing path.
 *  @param context The graphics context to draw into.
 **/
-(void)fillPathInContext:(CGContextRef)context
{
    CGContextSaveGState(context);

    CGRect bounds = CGContextGetPathBoundingBox(context);
    CGContextClip(context);
    [self.fillImage drawInRect:bounds inContext:context];

    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Opacity

-(BOOL)isOpaque
{
    return self.fillImage.opaque;
}

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    _CPTFillImage *copy = [[[self class] allocWithZone:zone] init];

    copy.fillImage = self.fillImage;

    return copy;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(Class)classForCoder
{
    return [CPTFill class];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.fillImage forKey:@"_CPTFillImage.fillImage"];
}

/// @endcond

/** @brief Returns an object initialized from data in a given unarchiver.
 *  @param coder An unarchiver object.
 *  @return An object initialized from data in a given unarchiver.
 */
-(instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        fillImage = [coder decodeObjectOfClass:[CPTImage class]
                                        forKey:@"_CPTFillImage.fillImage"];
    }
    return self;
}

#pragma mark -
#pragma mark NSSecureCoding Methods

/// @cond

+(BOOL)supportsSecureCoding
{
    return YES;
}

/// @endcond

@end
