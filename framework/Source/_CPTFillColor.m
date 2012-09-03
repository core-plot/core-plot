#import "_CPTFillColor.h"

#import "CPTColor.h"

/// @cond
@interface _CPTFillColor()

@property (nonatomic, readwrite, copy) CPTColor *fillColor;

@end

/// @endcond

/** @brief Draws CPTColor area fills.
 *
 *  Drawing methods are provided to fill rectangular areas and arbitrary drawing paths.
 **/

@implementation _CPTFillColor

/** @property fillColor
 *  @brief The fill color.
 **/
@synthesize fillColor;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated _CPTFillColor object with the provided color.
 *  @param aColor The color.
 *  @return The initialized _CPTFillColor object.
 **/
-(id)initWithColor:(CPTColor *)aColor
{
    if ( (self = [super init]) ) {
        fillColor = [aColor retain];
    }
    return self;
}

/// @cond

-(void)dealloc
{
    [fillColor release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/** @brief Draws the color into the given graphics context inside the provided rectangle.
 *  @param rect The rectangle to draw into.
 *  @param context The graphics context to draw into.
 **/
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.fillColor.cgColor);
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
}

/** @brief Draws the color into the given graphics context clipped to the current drawing path.
 *  @param context The graphics context to draw into.
 **/
-(void)fillPathInContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.fillColor.cgColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    _CPTFillColor *copy = [[[self class] allocWithZone:zone] init];

    copy->fillColor = [self->fillColor copyWithZone:zone];

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
    [coder encodeObject:self.fillColor forKey:@"_CPTFillColor.fillColor"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        fillColor = [[coder decodeObjectForKey:@"_CPTFillColor.fillColor"] retain];
    }
    return self;
}

/// @endcond

@end
