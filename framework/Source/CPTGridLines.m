#import "CPTGridLines.h"

#import "CPTAxis.h"

/**
 *  @brief An abstract class that draws grid lines for an axis.
 **/
@implementation CPTGridLines

/** @property __cpt_weak CPTAxis *axis
 *  @brief The axis.
 **/
@synthesize axis;

/** @property BOOL major
 *  @brief If @YES, draw the major grid lines, else draw the minor grid lines.
 **/
@synthesize major;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTGridLines object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref axis = @nil
 *  - @ref major = @NO
 *  - @ref needsDisplayOnBoundsChange = @YES
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTGridLines object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        axis  = nil;
        major = NO;

        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTGridLines *theLayer = (CPTGridLines *)layer;

        axis  = theLayer->axis;
        major = theLayer->major;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeConditionalObject:self.axis forKey:@"CPTGridLines.axis"];
    [coder encodeBool:self.major forKey:@"CPTGridLines.major"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        axis  = [coder decodeObjectForKey:@"CPTGridLines.axis"];
        major = [coder decodeBoolForKey:@"CPTGridLines.major"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    [self.axis drawGridLinesInContext:context isMajor:self.major];
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setAxis:(CPTAxis *)newAxis
{
    if ( newAxis != axis ) {
        axis = newAxis;
        [self setNeedsDisplay];
    }
}

/// @endcond

@end
