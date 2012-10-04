#import "CPTLineStyle.h"

#import "CPTColor.h"
#import "CPTDefinitions.h"
#import "CPTFill.h"
#import "CPTMutableLineStyle.h"
#import "NSCoderExtensions.h"
#import "NSNumberExtensions.h"

/// @cond
@interface CPTLineStyle()

@property (nonatomic, readwrite, assign) CGLineCap lineCap;
@property (nonatomic, readwrite, assign) CGLineJoin lineJoin;
@property (nonatomic, readwrite, assign) CGFloat miterLimit;
@property (nonatomic, readwrite, assign) CGFloat lineWidth;
@property (nonatomic, readwrite, retain) NSArray *dashPattern;
@property (nonatomic, readwrite, assign) CGFloat patternPhase;
@property (nonatomic, readwrite, retain) CPTColor *lineColor;
@property (nonatomic, readwrite, retain) CPTFill *lineFill;

@end

/// @endcond

/** @brief Immutable wrapper for various line drawing properties.
 *
 *  Create a CPTMutableLineStyle if you want to customize properties.
 *
 *  @see See Apple&rsquo;s <a href="http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_paths/dq_paths.html#//apple_ref/doc/uid/TP30001066-CH211-TPXREF105">Quartz 2D</a>
 *  and <a href="http://developer.apple.com/documentation/GraphicsImaging/Reference/CGContext/Reference/reference.html">CGContext</a>
 *  documentation for more information about each of these properties.
 **/

@implementation CPTLineStyle

/** @property CGLineCap lineCap;
 *  @brief The style for the endpoints of lines drawn in a graphics context. Default is @ref kCGLineCapButt.
 **/
@synthesize lineCap;

/** @property CGLineJoin lineJoin
 *  @brief The style for the joins of connected lines in a graphics context. Default is @ref kCGLineJoinMiter.
 **/
@synthesize lineJoin;

/** @property CGFloat miterLimit
 *  @brief The miter limit for the joins of connected lines in a graphics context. Default is @num{10.0}.
 **/
@synthesize miterLimit;

/** @property CGFloat lineWidth
 *  @brief The line width for a graphics context. Default is @num{1.0}.
 **/
@synthesize lineWidth;

/** @property NSArray *dashPattern
 *  @brief The dash-and-space pattern for the line. Default is @nil.
 **/
@synthesize dashPattern;

/** @property CGFloat patternPhase
 *  @brief The starting phase of the line dash pattern. Default is @num{0.0}.
 **/
@synthesize patternPhase;

/** @property CPTColor *lineColor
 *  @brief The current stroke color in a context. Default is solid black.
 **/
@synthesize lineColor;

/** @property CPTFill *lineFill
 *  @brief The current line fill. Default is @nil.
 *
 *  If @nil, the line is drawn using the
 *  @ref lineColor.
 **/
@synthesize lineFill;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPTLineStyle instance.
 *  @return A new CPTLineStyle instance.
 **/
+(id)lineStyle
{
    return [[[self alloc] init] autorelease];
}

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTLineStyle object.
 *
 *  The initialized object will have the following properties:
 *  - @ref lineCap = @ref kCGLineCapButt
 *  - @ref lineJoin = @ref kCGLineJoinMiter
 *  - @ref miterLimit = @num{10.0}
 *  - @ref lineWidth = @num{1.0}
 *  - @ref dashPattern = @nil
 *  - @ref patternPhase = @num{0.0}
 *  - @ref lineColor = opaque black
 *  - @ref lineFill = @nil
 *
 *  @return The initialized object.
 **/
-(id)init
{
    if ( (self = [super init]) ) {
        lineCap      = kCGLineCapButt;
        lineJoin     = kCGLineJoinMiter;
        miterLimit   = CPTFloat(10.0);
        lineWidth    = CPTFloat(1.0);
        dashPattern  = nil;
        patternPhase = CPTFloat(0.0);
        lineColor    = [[CPTColor blackColor] retain];
        lineFill     = nil;
    }
    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    [lineColor release];
    [lineFill release];
    [dashPattern release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.lineCap forKey:@"CPTLineStyle.lineCap"];
    [coder encodeInt:self.lineJoin forKey:@"CPTLineStyle.lineJoin"];
    [coder encodeCGFloat:self.miterLimit forKey:@"CPTLineStyle.miterLimit"];
    [coder encodeCGFloat:self.lineWidth forKey:@"CPTLineStyle.lineWidth"];
    [coder encodeObject:self.dashPattern forKey:@"CPTLineStyle.dashPattern"];
    [coder encodeCGFloat:self.patternPhase forKey:@"CPTLineStyle.patternPhase"];
    [coder encodeObject:self.lineColor forKey:@"CPTLineStyle.lineColor"];
    [coder encodeObject:self.lineFill forKey:@"CPTLineStyle.lineFill"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        lineCap      = (CGLineCap)[coder decodeIntForKey : @"CPTLineStyle.lineCap"];
        lineJoin     = (CGLineJoin)[coder decodeIntForKey : @"CPTLineStyle.lineJoin"];
        miterLimit   = [coder decodeCGFloatForKey:@"CPTLineStyle.miterLimit"];
        lineWidth    = [coder decodeCGFloatForKey:@"CPTLineStyle.lineWidth"];
        dashPattern  = [[coder decodeObjectForKey:@"CPTLineStyle.dashPattern"] retain];
        patternPhase = [coder decodeCGFloatForKey:@"CPTLineStyle.patternPhase"];
        lineColor    = [[coder decodeObjectForKey:@"CPTLineStyle.lineColor"] retain];
        lineFill     = [[coder decodeObjectForKey:@"CPTLineStyle.lineFill"] retain];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/** @brief Sets all of the line drawing properties in the given graphics context.
 *  @param context The graphics context.
 **/
-(void)setLineStyleInContext:(CGContextRef)context
{
    CGContextSetLineCap(context, lineCap);
    CGContextSetLineJoin(context, lineJoin);
    CGContextSetMiterLimit(context, miterLimit);
    CGContextSetLineWidth(context, lineWidth);
    NSUInteger dashCount = dashPattern.count;
    if ( dashCount > 0 ) {
        CGFloat *dashLengths = (CGFloat *)calloc( dashCount, sizeof(CGFloat) );

        NSUInteger dashCounter = 0;
        for ( NSNumber *currentDashLength in dashPattern ) {
            dashLengths[dashCounter++] = [currentDashLength cgFloatValue];
        }

        CGContextSetLineDash(context, patternPhase, dashLengths, dashCount);
        free(dashLengths);
    }
    else {
        CGContextSetLineDash(context, CPTFloat(0.0), NULL, 0);
    }
    CGContextSetStrokeColorWithColor(context, lineColor.cgColor);
}

/** @brief Stroke the current path in the given graphics context.
 *  Call @link CPTLineStyle::setLineStyleInContext: -setLineStyleInContext: @endlink first to set up the drawing properties.
 *
 *  @param context The graphics context.
 **/
-(void)strokePathInContext:(CGContextRef)context
{
    CPTFill *theFill = self.lineFill;

    if ( theFill ) {
        CGContextReplacePathWithStrokedPath(context);
        [theFill fillPathInContext:context];
    }
    else {
        CGContextStrokePath(context);
    }
}

/** @brief Stroke a rectangular path in the given graphics context.
 *  Call @link CPTLineStyle::setLineStyleInContext: -setLineStyleInContext: @endlink first to set up the drawing properties.
 *
 *  @param rect The rectangle to draw.
 *  @param context The graphics context.
 **/
-(void)strokeRect:(CGRect)rect inContext:(CGContextRef)context
{
    CPTFill *theFill = self.lineFill;

    if ( theFill ) {
        CGContextBeginPath(context);
        CGContextAddRect(context, rect);
        CGContextReplacePathWithStrokedPath(context);
        [theFill fillPathInContext:context];
    }
    else {
        CGContextStrokeRect(context, rect);
    }
}

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    CPTLineStyle *styleCopy = [[CPTLineStyle allocWithZone:zone] init];

    styleCopy->lineCap      = self->lineCap;
    styleCopy->lineJoin     = self->lineJoin;
    styleCopy->miterLimit   = self->miterLimit;
    styleCopy->lineWidth    = self->lineWidth;
    styleCopy->dashPattern  = [self->dashPattern copy];
    styleCopy->patternPhase = self->patternPhase;
    styleCopy->lineColor    = [self->lineColor copy];
    styleCopy->lineFill     = [self->lineFill copy];

    return styleCopy;
}

/// @endcond

#pragma mark -
#pragma mark NSMutableCopying Methods

/// @cond

-(id)mutableCopyWithZone:(NSZone *)zone
{
    CPTLineStyle *styleCopy = [[CPTMutableLineStyle allocWithZone:zone] init];

    styleCopy->lineCap      = self->lineCap;
    styleCopy->lineJoin     = self->lineJoin;
    styleCopy->miterLimit   = self->miterLimit;
    styleCopy->lineWidth    = self->lineWidth;
    styleCopy->dashPattern  = [self->dashPattern copy];
    styleCopy->patternPhase = self->patternPhase;
    styleCopy->lineColor    = [self->lineColor copy];
    styleCopy->lineFill     = [self->lineFill copy];

    return styleCopy;
}

/// @endcond

@end
