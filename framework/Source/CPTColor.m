#import "CPTColor.h"

#import "CPTColorSpace.h"
#import "CPTDefinitions.h"
#import "CPTPlatformSpecificCategories.h"
#import "NSCoderExtensions.h"

/** @brief An immutable color.
 *
 *  An immutable object wrapper class around @ref CGColorRef.
 *  It provides convenience methods to create the same predefined colors defined by
 *  @if MacOnly NSColor. @endif
 *  @if iOSOnly UIColor. @endif
 **/
@implementation CPTColor

/** @property nonnull CGColorRef cgColor
 *  @brief The @ref CGColorRef to wrap around.
 **/
@synthesize cgColor;

/** @property BOOL opaque
 *  @brief If @YES, the color is completely opaque.
 */
@dynamic opaque;

#pragma mark -
#pragma mark Factory Methods

/** @brief Returns a shared instance of CPTColor initialized with a fully transparent color.
 *
 *  @return A shared CPTColor object initialized with a fully transparent color.
 **/
+(nonnull instancetype)clearColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        CGFloat values[4] = { CPTFloat(0.0), CPTFloat(0.0), CPTFloat(0.0), CPTFloat(0.0) };

        CGColorRef clear = CGColorCreate([CPTColorSpace genericRGBSpace].cgColorSpace, values);

        color = [[CPTColor alloc] initWithCGColor:clear];

        CGColorRelease(clear);
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque white color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque white color.
 **/
+(nonnull instancetype)whiteColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [self colorWithGenericGray:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque 67% gray color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque 67% gray color.
 **/
+(nonnull instancetype)lightGrayColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [self colorWithGenericGray:(CGFloat)(2.0 / 3.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque 50% gray color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque 50% gray color.
 **/
+(nonnull instancetype)grayColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [self colorWithGenericGray:CPTFloat(0.5)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque 33% gray color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque 33% gray color.
 **/
+(nonnull instancetype)darkGrayColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [self colorWithGenericGray:(CGFloat)(1.0 / 3.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque black color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque black color.
 **/
+(nonnull instancetype)blackColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [self colorWithGenericGray:CPTFloat(0.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque red color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque red color.
 **/
+(nonnull instancetype)redColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(1.0)
                                                 green:CPTFloat(0.0)
                                                  blue:CPTFloat(0.0)
                                                 alpha:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque green color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque green color.
 **/
+(nonnull instancetype)greenColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.0)
                                                 green:CPTFloat(1.0)
                                                  blue:CPTFloat(0.0)
                                                 alpha:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque blue color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque blue color.
 **/
+(nonnull instancetype)blueColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.0)
                                                 green:CPTFloat(0.0)
                                                  blue:CPTFloat(1.0)
                                                 alpha:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque cyan color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque cyan color.
 **/
+(nonnull instancetype)cyanColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.0)
                                                 green:CPTFloat(1.0)
                                                  blue:CPTFloat(1.0)
                                                 alpha:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque yellow color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque yellow color.
 **/
+(nonnull instancetype)yellowColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(1.0) green:CPTFloat(1.0) blue:CPTFloat(0.0) alpha:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque magenta color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque magenta color.
 **/
+(nonnull instancetype)magentaColor
{
    static CPTColor *color = nil;

    if ( nil == color ) {
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(1.0) green:CPTFloat(0.0) blue:CPTFloat(1.0) alpha:CPTFloat(1.0)];
    }
    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque orange color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque orange color.
 **/
+(nonnull instancetype)orangeColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(1.0) green:CPTFloat(0.5) blue:CPTFloat(0.0) alpha:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque purple color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque purple color.
 **/
+(nonnull instancetype)purpleColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.5) green:CPTFloat(0.0) blue:CPTFloat(0.5) alpha:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque brown color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque brown color.
 **/
+(nonnull instancetype)brownColor
{
    static CPTColor *color           = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        color = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.6) green:CPTFloat(0.4) blue:CPTFloat(0.2) alpha:CPTFloat(1.0)];
    });

    return color;
}

/** @brief Creates and returns a new CPTColor instance initialized with the provided @ref CGColorRef.
 *  @param newCGColor The color to wrap.
 *  @return A new CPTColor instance initialized with the provided @ref CGColorRef.
 **/
+(nonnull instancetype)colorWithCGColor:(nonnull CGColorRef)newCGColor
{
    return [[CPTColor alloc] initWithCGColor:newCGColor];
}

/** @brief Creates and returns a new CPTColor instance initialized with the provided RGBA color components.
 *  @param red The red component (@num{0} ≤ @par{red} ≤ @num{1}).
 *  @param green The green component (@num{0} ≤ @par{green} ≤ @num{1}).
 *  @param blue The blue component (@num{0} ≤ @par{blue} ≤ @num{1}).
 *  @param alpha The alpha component (@num{0} ≤ @par{alpha} ≤ @num{1}).
 *  @return A new CPTColor instance initialized with the provided RGBA color components.
 **/
+(nonnull instancetype)colorWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[CPTColor alloc] initWithComponentRed:red green:green blue:blue alpha:alpha];
}

/** @brief Creates and returns a new CPTColor instance initialized with the provided gray level.
 *  @param gray The gray level (@num{0} ≤ @par{gray} ≤ @num{1}).
 *  @return A new CPTColor instance initialized with the provided gray level.
 **/
+(nonnull instancetype)colorWithGenericGray:(CGFloat)gray
{
    CGFloat values[4]   = { gray, gray, gray, CPTFloat(1.0) };
    CGColorRef colorRef = CGColorCreate([CPTColorSpace genericRGBSpace].cgColorSpace, values);
    CPTColor *color     = [[CPTColor alloc] initWithCGColor:colorRef];

    CGColorRelease(colorRef);
    return color;
}

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTColor object with the provided @ref CGColorRef.
 *
 *  @param newCGColor The color to wrap.
 *  @return The initialized CPTColor object.
 **/
-(nonnull instancetype)initWithCGColor:(nonnull CGColorRef)newCGColor
{
    if ( (self = [super init]) ) {
        CGColorRetain(newCGColor);
        cgColor = newCGColor;
    }
    return self;
}

/** @brief Initializes a newly allocated CPTColor object with the provided RGBA color components.
 *
 *  @param red The red component (@num{0} ≤ @par{red} ≤ @num{1}).
 *  @param green The green component (@num{0} ≤ @par{green} ≤ @num{1}).
 *  @param blue The blue component (@num{0} ≤ @par{blue} ≤ @num{1}).
 *  @param alpha The alpha component (@num{0} ≤ @par{alpha} ≤ @num{1}).
 *  @return The initialized CPTColor object.
 **/
-(nonnull instancetype)initWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    CGFloat colorComponents[4];

    colorComponents[0] = red;
    colorComponents[1] = green;
    colorComponents[2] = blue;
    colorComponents[3] = alpha;
    CGColorRef color = CGColorCreate([CPTColorSpace genericRGBSpace].cgColorSpace, colorComponents);
    self = [self initWithCGColor:color];
    CGColorRelease(color);
    return self;
}

/// @cond

-(nonnull instancetype)init
{
    return [self initWithComponentRed:0.0 green:0.0 blue:0.0 alpha:0.0];
}

-(void)dealloc
{
    CGColorRelease(cgColor);
}

/// @endcond

#pragma mark -
#pragma mark Creating colors from other colors

/** @brief Creates and returns a new CPTColor instance having color components identical to the current object
 *  but having the provided alpha component.
 *  @param alpha The alpha component (@num{0} ≤ @par{alpha} ≤ @num{1}).
 *  @return A new CPTColor instance having the provided alpha component.
 **/
-(nonnull instancetype)colorWithAlphaComponent:(CGFloat)alpha
{
    CGColorRef newCGColor = CGColorCreateCopyWithAlpha(self.cgColor, alpha);
    CPTColor *newColor    = [CPTColor colorWithCGColor:newCGColor];

    CGColorRelease(newCGColor);
    return newColor;
}

#pragma mark -
#pragma mark Opacity

/// @cond

-(BOOL)isOpaque
{
    return CGColorGetAlpha(self.cgColor) >= CPTFloat(1.0);
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    CGColorRef theColor = self.cgColor;

    [coder encodeCGColorSpace:CGColorGetColorSpace(theColor) forKey:@"CPTColor.colorSpace"];

    size_t numberOfComponents = CGColorGetNumberOfComponents(theColor);
    [coder encodeInt64:(int64_t)numberOfComponents forKey:@"CPTColor.numberOfComponents"];

    const CGFloat *colorComponents = CGColorGetComponents(theColor);

    for ( size_t i = 0; i < numberOfComponents; i++ ) {
        NSString *newKey = [[NSString alloc] initWithFormat:@"CPTColor.component[%zu]", i];
        [coder encodeCGFloat:colorComponents[i] forKey:newKey];
    }
}

/// @endcond

/** @brief Returns an object initialized from data in a given unarchiver.
 *  @param coder An unarchiver object.
 *  @return An object initialized from data in a given unarchiver.
 */
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if ( (self = [super init]) ) {
        CGColorSpaceRef colorSpace = [coder newCGColorSpaceDecodeForKey:@"CPTColor.colorSpace"];

        size_t numberOfComponents = (size_t)[coder decodeInt64ForKey:@"CPTColor.numberOfComponents"];

        CGFloat *colorComponents = malloc( numberOfComponents * sizeof(CGFloat) );

        for ( size_t i = 0; i < numberOfComponents; i++ ) {
            NSString *newKey = [[NSString alloc] initWithFormat:@"CPTColor.component[%zu]", i];
            colorComponents[i] = [coder decodeCGFloatForKey:newKey];
        }

        CGColorRef color = CGColorCreate(colorSpace, colorComponents);
        cgColor = color;

        CGColorSpaceRelease(colorSpace);
        free(colorComponents);
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

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(nonnull id)copyWithZone:(nullable NSZone *)zone
{
    CGColorRef cgColorCopy = NULL;

    CGColorRef myColor = self.cgColor;

    if ( myColor ) {
        cgColorCopy = CGColorCreateCopy(myColor);
        CPTColor *colorCopy = [[[self class] allocWithZone:zone] initWithCGColor:cgColorCopy];
        CGColorRelease(cgColorCopy);
        return colorCopy;
    }
    else {
        return nil;
    }
}

/// @endcond

#pragma mark -
#pragma mark Color comparison

/// @name Comparison
/// @{

/** @brief Returns a boolean value that indicates whether the received is equal to the given object.
 *  Colors are equal if they have equal @ref cgColor properties.
 *  @param object The object to be compared with the receiver.
 *  @return @YES if @par{object} is equal to the receiver, @NO otherwise.
 **/
-(BOOL)isEqual:(nullable id)object
{
    if ( self == object ) {
        return YES;
    }
    else if ( [object isKindOfClass:[self class]] ) {
        return CGColorEqualToColor(self.cgColor, ( (CPTColor *)object ).cgColor);
    }
    else {
        return NO;
    }
}

/// @}

/// @cond

-(NSUInteger)hash
{
    // Equal objects must hash the same.
    CGFloat theHash    = CPTFloat(0.0);
    CGFloat multiplier = CPTFloat(256.0);

    CGColorRef theColor            = self.cgColor;
    size_t numberOfComponents      = CGColorGetNumberOfComponents(theColor);
    const CGFloat *colorComponents = CGColorGetComponents(theColor);

    for ( NSUInteger i = 0; i < numberOfComponents; i++ ) {
        theHash    += multiplier * colorComponents[i];
        multiplier *= CPTFloat(256.0);
    }

    return (NSUInteger)theHash;
}

/// @endcond

#pragma mark -
#pragma mark Debugging

/// @cond

-(nullable id)debugQuickLookObject
{
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    return self.uiColor;

#else
    return self.nsColor;
#endif
}

/// @endcond

@end
