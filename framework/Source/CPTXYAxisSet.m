#import "CPTXYAxisSet.h"

#import "CPTDefinitions.h"
#import "CPTLineStyle.h"
#import "CPTUtilities.h"
#import "CPTXYAxis.h"

/**
 *  @brief A set of cartesian (X-Y) axes.
 **/
@implementation CPTXYAxisSet

/** @property CPTXYAxis *xAxis
 *  @brief The x-axis.
 **/
@dynamic xAxis;

/** @property CPTXYAxis *yAxis
 *  @brief The y-axis.
 **/
@dynamic yAxis;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTXYAxisSet object with the provided frame rectangle.
 *
 *  This is the designated initializer. The @ref axes array
 *  will contain two new axes with the following properties:
 *
 *  <table>
 *  <tr><td>@bold{Axis}</td><td>@link CPTAxis::coordinate coordinate @endlink</td><td>@link CPTAxis::tickDirection tickDirection @endlink</td></tr>
 *  <tr><td>@ref xAxis</td><td>#CPTCoordinateX</td><td>#CPTSignNegative</td></tr>
 *  <tr><td>@ref yAxis</td><td>#CPTCoordinateY</td><td>#CPTSignNegative</td></tr>
 *  </table>
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTXYAxisSet object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        CPTXYAxis *xAxis = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame:newFrame];
        xAxis.coordinate    = CPTCoordinateX;
        xAxis.tickDirection = CPTSignNegative;

        CPTXYAxis *yAxis = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame:newFrame];
        yAxis.coordinate    = CPTCoordinateY;
        yAxis.tickDirection = CPTSignNegative;

        self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
        [xAxis release];
        [yAxis release];
    }
    return self;
}

/// @}

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    CPTLineStyle *theLineStyle = self.borderLineStyle;
    if ( theLineStyle ) {
        [super renderAsVectorInContext:context];

        CALayer *superlayer = self.superlayer;
        CGRect borderRect   = CPTAlignRectToUserSpace(context, [self convertRect:superlayer.bounds fromLayer:superlayer]);

        [theLineStyle setLineStyleInContext:context];
        [theLineStyle strokeRect:borderRect inContext:context];
    }
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(CPTXYAxis *)xAxis
{
    return (CPTXYAxis *)[self axisForCoordinate:CPTCoordinateX atIndex:0];
}

-(CPTXYAxis *)yAxis
{
    return (CPTXYAxis *)[self axisForCoordinate:CPTCoordinateY atIndex:0];
}

/// @endcond

@end
