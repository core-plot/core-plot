#import "_CPTFillGradient.h"

#import "CPTGradient.h"

/// @cond
@interface _CPTFillGradient()

@property (nonatomic, readwrite, copy) CPTGradient *fillGradient;

@end

/// @endcond

/** @brief Draws CPTGradient area fills.
 *
 *  Drawing methods are provided to fill rectangular areas and arbitrary drawing paths.
 **/

@implementation _CPTFillGradient

/** @property fillGradient
 *  @brief The fill gradient.
 **/
@synthesize fillGradient;

#pragma mark -
#pragma mark Init/Dealloc

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

/// @cond

-(void)dealloc
{
    [fillGradient release];

    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/** @brief Draws the gradient into the given graphics context inside the provided rectangle.
 *  @param rect The rectangle to draw into.
 *  @param context The graphics context to draw into.
 **/
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context
{
    [self.fillGradient fillRect:rect inContext:context];
}

/** @brief Draws the gradient into the given graphics context clipped to the current drawing path.
 *  @param context The graphics context to draw into.
 **/
-(void)fillPathInContext:(CGContextRef)context
{
    [self.fillGradient fillPathInContext:context];
}

#pragma mark -
#pragma mark Opacity

-(BOOL)isOpaque
{
    return self.fillGradient.opaque;
}

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    _CPTFillGradient *copy = [[[self class] allocWithZone:zone] init];

    copy->fillGradient = [self->fillGradient copyWithZone:zone];

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
    [coder encodeObject:self.fillGradient forKey:@"_CPTFillGradient.fillGradient"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        fillGradient = [[coder decodeObjectForKey:@"_CPTFillGradient.fillGradient"] retain];
    }
    return self;
}

/// @endcond

@end
