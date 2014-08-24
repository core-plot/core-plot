#import "CPTXYAxis.h"

#import "CPTConstraints.h"
#import "CPTFill.h"
#import "CPTLimitBand.h"
#import "CPTLineCap.h"
#import "CPTLineStyle.h"
#import "CPTMutablePlotRange.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/// @cond
@interface CPTXYAxis()

-(void)drawTicksInContext:(CGContextRef)context atLocations:(NSSet *)locations withLength:(CGFloat)length inRange:(CPTPlotRange *)labeledRange isMajor:(BOOL)major;

-(void)orthogonalCoordinateViewLowerBound:(CGFloat *)lower upperBound:(CGFloat *)upper forLayerSize:(const LayerSize *)layerSize;
-(CGPoint)viewPointForOrthogonalCoordinateDecimal:(NSDecimal)orthogonalCoord axisCoordinateDecimal:(NSDecimal)coordinateDecimalNumber forLayerSize:(const LayerSize *)layerSize;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A 2-dimensional cartesian (X-Y) axis class.
 **/
@implementation CPTXYAxis

/** @property NSDecimal orthogonalCoordinateDecimal
 *  @brief The data coordinate value where the axis crosses the orthogonal axis.
 *  If the @ref axisConstraints is non-nil, the constraints take priority and this property is ignored.
 *  @see @ref axisConstraints
 **/
@synthesize orthogonalCoordinateDecimal;

/** @property CPTConstraints *axisConstraints
 *  @brief The constraints used when positioning relative to the plot area.
 *  If @nil (the default), the axis is fixed relative to the plot space coordinates,
 *  crossing the orthogonal axis at @ref orthogonalCoordinateDecimal and moves only
 *  whenever the plot space ranges change.
 *  @see @ref orthogonalCoordinateDecimal
 **/
@synthesize axisConstraints;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTXYAxis object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref orthogonalCoordinateDecimal = @num{0}
 *  - @ref axisConstraints = @nil
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTXYAxis object.
 **/
-(instancetype)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
        axisConstraints             = nil;
        self.tickDirection          = CPTSignNone;
    }
    return self;
}

/// @}

/// @cond

-(instancetype)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTXYAxis *theLayer = (CPTXYAxis *)layer;

        orthogonalCoordinateDecimal = theLayer->orthogonalCoordinateDecimal;
        axisConstraints             = theLayer->axisConstraints;
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

    [coder encodeDecimal:self.orthogonalCoordinateDecimal forKey:@"CPTXYAxis.orthogonalCoordinateDecimal"];
    [coder encodeObject:self.axisConstraints forKey:@"CPTXYAxis.axisConstraints"];
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        orthogonalCoordinateDecimal = [coder decodeDecimalForKey:@"CPTXYAxis.orthogonalCoordinateDecimal"];
        axisConstraints             = [coder decodeObjectForKey:@"CPTXYAxis.axisConstraints"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Coordinate Transforms

/// @cond

-(void)orthogonalCoordinateViewLowerBound:(CGFloat *)lower upperBound:(CGFloat *)upper forLayerSize:(const LayerSize *)layerSize
{
    CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
    CPTXYPlotSpace *xyPlotSpace        = (CPTXYPlotSpace *)self.plotSpace;
    CPTPlotRange *orthogonalRange      = [xyPlotSpace plotRangeForCoordinate:orthogonalCoordinate];

    NSAssert(orthogonalRange != nil, @"The orthogonalRange was nil in orthogonalCoordinateViewLowerBound:upperBound:");

    NSDecimal zero          = CPTDecimalFromInteger(0);
    CGPoint lowerBoundPoint = [self viewPointForOrthogonalCoordinateDecimal:orthogonalRange.location axisCoordinateDecimal:zero forLayerSize:layerSize];
    CGPoint upperBoundPoint = [self viewPointForOrthogonalCoordinateDecimal:orthogonalRange.end axisCoordinateDecimal:zero forLayerSize:layerSize];

    switch ( self.coordinate ) {
        case CPTCoordinateX:
            *lower = lowerBoundPoint.y;
            *upper = upperBoundPoint.y;
            break;

        case CPTCoordinateY:
            *lower = lowerBoundPoint.x;
            *upper = upperBoundPoint.x;
            break;

        default:
            *lower = NAN;
            *upper = NAN;
            break;
    }
}

-(CGPoint)viewPointForOrthogonalCoordinateDecimal:(NSDecimal)orthogonalCoord axisCoordinateDecimal:(NSDecimal)coordinateDecimalNumber forLayerSize:(const LayerSize *)layerSize
{
    CPTCoordinate myCoordinate         = self.coordinate;
    CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(myCoordinate);

    NSDecimal plotPoint[2];

    plotPoint[myCoordinate]         = coordinateDecimalNumber;
    plotPoint[orthogonalCoordinate] = orthogonalCoord;

    CPTPlotArea *thePlotArea = self.plotArea;

    return [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2 forLayerSize:layerSize] fromLayer:thePlotArea];
}

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber
{
    CPTPlotArea *thePlotArea = self.plotArea;
    LayerSize layerSizeValue;
    const LayerSize *layerSize;
    if ( thePlotArea ) {
        layerSizeValue.asFloat = thePlotArea.bounds.size;
        layerSizeValue.width = CPTDecimalFromCGFloat(layerSizeValue.asFloat.width);
        layerSizeValue.height = CPTDecimalFromCGFloat(layerSizeValue.asFloat.height);
        layerSize = &layerSizeValue;
    } else {
        layerSize = nil;
    }
    return [self viewPointForCoordinateDecimalNumber:coordinateDecimalNumber forLayerSize:layerSize];
}

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber forLayerSize:(const LayerSize *)layerSize
{
    CGPoint point = [self viewPointForOrthogonalCoordinateDecimal:self.orthogonalCoordinateDecimal
                                            axisCoordinateDecimal:coordinateDecimalNumber
                                                     forLayerSize:layerSize];

    CPTConstraints *theAxisConstraints = self.axisConstraints;

    if ( theAxisConstraints ) {
        CGFloat lb, ub;
        [self orthogonalCoordinateViewLowerBound:&lb upperBound:&ub forLayerSize:layerSize];
        CGFloat constrainedPosition = [theAxisConstraints positionForLowerBound:lb upperBound:ub];

        switch ( self.coordinate ) {
            case CPTCoordinateX:
                point.y = constrainedPosition;
                break;

            case CPTCoordinateY:
                point.x = constrainedPosition;
                break;

            default:
                break;
        }
    }

    if ( isnan(point.x) || isnan(point.y) ) {
        NSLog( @"[CPTXYAxis viewPointForCoordinateDecimalNumber:%@] was %@", NSDecimalString(&coordinateDecimalNumber, nil), CPTStringFromPoint(point) );

        if ( isnan(point.x) ) {
            point.x = CPTFloat(0.0);
        }
        if ( isnan(point.y) ) {
            point.y = CPTFloat(0.0);
        }
    }

    return point;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)drawTicksInContext:(CGContextRef)context atLocations:(NSSet *)locations withLength:(CGFloat)length inRange:(CPTPlotRange *)labeledRange isMajor:(BOOL)major
{
    CPTLineStyle *lineStyle = (major ? self.majorTickLineStyle : self.minorTickLineStyle);

    if ( !lineStyle ) {
        return;
    }

    CGFloat lineWidth = lineStyle.lineWidth;

    CPTAlignPointFunction alignmentFunction = NULL;
    if ( ( self.contentsScale > CPTFloat(1.0) ) && (round(lineWidth) == lineWidth) ) {
        alignmentFunction = CPTAlignIntegralPointToUserSpace;
    }
    else {
        alignmentFunction = CPTAlignPointToUserSpace;
    }

    CPTPlotArea *thePlotArea = self.plotArea;
    LayerSize layerSizeValue;
    const LayerSize *layerSize;
    if ( thePlotArea ) {
        layerSizeValue.asFloat = thePlotArea.bounds.size;
        layerSizeValue.width = CPTDecimalFromCGFloat(layerSizeValue.asFloat.width);
        layerSizeValue.height = CPTDecimalFromCGFloat(layerSizeValue.asFloat.height);
        layerSize = &layerSizeValue;
    } else {
        layerSize = nil;
    }

    [lineStyle setLineStyleInContext:context];
    CGContextBeginPath(context);

    for ( NSDecimalNumber *tickLocation in locations ) {
        NSDecimal locationDecimal = tickLocation.decimalValue;

        if ( labeledRange && ![labeledRange contains:locationDecimal] ) {
            continue;
        }

        // Tick end points
        CGPoint baseViewPoint  = [self viewPointForCoordinateDecimalNumber:locationDecimal forLayerSize:layerSize];
        CGPoint startViewPoint = baseViewPoint;
        CGPoint endViewPoint   = baseViewPoint;

        CGFloat startFactor = CPTFloat(0.0);
        CGFloat endFactor   = CPTFloat(0.0);
        switch ( self.tickDirection ) {
            case CPTSignPositive:
                endFactor = CPTFloat(1.0);
                break;

            case CPTSignNegative:
                endFactor = CPTFloat(-1.0);
                break;

            case CPTSignNone:
                startFactor = CPTFloat(-0.5);
                endFactor   = CPTFloat(0.5);
                break;
        }

        switch ( self.coordinate ) {
            case CPTCoordinateX:
                startViewPoint.y += length * startFactor;
                endViewPoint.y   += length * endFactor;
                break;

            case CPTCoordinateY:
                startViewPoint.x += length * startFactor;
                endViewPoint.x   += length * endFactor;
                break;

            default:
                NSLog(@"Invalid coordinate in [CPTXYAxis drawTicksInContext:]");
        }

        startViewPoint = alignmentFunction(context, startViewPoint);
        endViewPoint   = alignmentFunction(context, endViewPoint);

        // Add tick line
        CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
        CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
    }
    // Stroke tick line
    [lineStyle strokePathInContext:context];
}

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    [super renderAsVectorInContext:context];

    [self relabel];

    CPTPlotRange *thePlotRange    = [self.plotSpace plotRangeForCoordinate:self.coordinate];
    CPTMutablePlotRange *range    = [thePlotRange mutableCopy];
    CPTPlotRange *theVisibleRange = self.visibleRange;
    if ( theVisibleRange ) {
        [range intersectionPlotRange:theVisibleRange];
    }

    CPTMutablePlotRange *labeledRange = nil;

    switch ( self.labelingPolicy ) {
        case CPTAxisLabelingPolicyNone:
        case CPTAxisLabelingPolicyLocationsProvided:
            labeledRange = range;
            break;

        default:
            break;
    }

    // Ticks
    [self drawTicksInContext:context atLocations:self.minorTickLocations withLength:self.minorTickLength inRange:labeledRange isMajor:NO];
    [self drawTicksInContext:context atLocations:self.majorTickLocations withLength:self.majorTickLength inRange:labeledRange isMajor:YES];

    // Axis Line
    CPTLineStyle *theLineStyle = self.axisLineStyle;
    CPTLineCap *minCap         = self.axisLineCapMin;
    CPTLineCap *maxCap         = self.axisLineCapMax;

    if ( theLineStyle || minCap || maxCap ) {
        // If there is a separate axis range given then restrict the axis to that range, overriding the visible range
        // given for grid lines and ticks.
        CPTPlotRange *theVisibleAxisRange = self.visibleAxisRange;
        if ( theVisibleAxisRange ) {
            range = [theVisibleAxisRange mutableCopy];
        }
        CPTAlignPointFunction alignmentFunction = CPTAlignPointToUserSpace;
        if ( theLineStyle ) {
            CGFloat lineWidth = theLineStyle.lineWidth;
            if ( ( self.contentsScale > CPTFloat(1.0) ) && (round(lineWidth) == lineWidth) ) {
                alignmentFunction = CPTAlignIntegralPointToUserSpace;
            }

            CGPoint startViewPoint = alignmentFunction(context, [self viewPointForCoordinateDecimalNumber:range.location]);
            CGPoint endViewPoint   = alignmentFunction(context, [self viewPointForCoordinateDecimalNumber:range.end]);
            [theLineStyle setLineStyleInContext:context];
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
            CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
            [theLineStyle strokePathInContext:context];
        }

        CGPoint axisDirection = CGPointZero;
        if ( minCap || maxCap ) {
            switch ( self.coordinate ) {
                case CPTCoordinateX:
                    axisDirection = ( range.lengthDouble >= CPTFloat(0.0) ) ? CPTPointMake(1.0, 0.0) : CPTPointMake(-1.0, 0.0);
                    break;

                case CPTCoordinateY:
                    axisDirection = ( range.lengthDouble >= CPTFloat(0.0) ) ? CPTPointMake(0.0, 1.0) : CPTPointMake(0.0, -1.0);
                    break;

                default:
                    break;
            }
        }

        if ( minCap ) {
            NSDecimal endPoint = range.minLimit;
            CGPoint viewPoint  = alignmentFunction(context, [self viewPointForCoordinateDecimalNumber:endPoint]);
            [minCap renderAsVectorInContext:context atPoint:viewPoint inDirection:CPTPointMake(-axisDirection.x, -axisDirection.y)];
        }

        if ( maxCap ) {
            NSDecimal endPoint = range.maxLimit;
            CGPoint viewPoint  = alignmentFunction(context, [self viewPointForCoordinateDecimalNumber:endPoint]);
            [maxCap renderAsVectorInContext:context atPoint:viewPoint inDirection:axisDirection];
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Grid Lines

/// @cond

-(void)drawGridLinesInContext:(CGContextRef)context isMajor:(BOOL)major
{
    CPTLineStyle *lineStyle = (major ? self.majorGridLineStyle : self.minorGridLineStyle);

    if ( lineStyle ) {
        CPTPlotArea *thePlotArea = self.plotArea;
        LayerSize layerSizeValue;
        const LayerSize *layerSize;
        if ( thePlotArea ) {
            layerSizeValue.asFloat = thePlotArea.bounds.size;
            layerSizeValue.width = CPTDecimalFromCGFloat(layerSizeValue.asFloat.width);
            layerSizeValue.height = CPTDecimalFromCGFloat(layerSizeValue.asFloat.height);
            layerSize = &layerSizeValue;
        } else {
            layerSize = nil;
        }

        [super renderAsVectorInContext:context];

        [self relabel];

        CPTPlotSpace *thePlotSpace           = self.plotSpace;
        NSSet *locations                     = (major ? self.majorTickLocations : self.minorTickLocations);
        CPTCoordinate selfCoordinate         = self.coordinate;
        CPTCoordinate orthogonalCoordinate   = CPTOrthogonalCoordinate(selfCoordinate);
        CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
        CPTPlotRange *theGridLineRange       = self.gridLinesRange;
        CPTMutablePlotRange *labeledRange    = nil;

        switch ( self.labelingPolicy ) {
            case CPTAxisLabelingPolicyNone:
            case CPTAxisLabelingPolicyLocationsProvided:
            {
                labeledRange = [[self.plotSpace plotRangeForCoordinate:self.coordinate] mutableCopy];
                CPTPlotRange *theVisibleRange = self.visibleRange;
                if ( theVisibleRange ) {
                    [labeledRange intersectionPlotRange:theVisibleRange];
                }
            }
            break;

            default:
                break;
        }

        if ( theGridLineRange ) {
            [orthogonalRange intersectionPlotRange:theGridLineRange];
        }

        NSDecimal startPlotPoint[2];
        NSDecimal endPlotPoint[2];
        startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
        endPlotPoint[orthogonalCoordinate]   = orthogonalRange.end;
        CGPoint originTransformed = [self convertPoint:self.bounds.origin fromLayer:thePlotArea];

        CGFloat lineWidth = lineStyle.lineWidth;

        CPTAlignPointFunction alignmentFunction = NULL;
        if ( ( self.contentsScale > CPTFloat(1.0) ) && (round(lineWidth) == lineWidth) ) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace;
        }
        else {
            alignmentFunction = CPTAlignPointToUserSpace;
        }

        CGContextBeginPath(context);

        for ( NSDecimalNumber *location in locations ) {
            NSDecimal locationDecimal = location.decimalValue;

            if ( labeledRange && ![labeledRange contains:locationDecimal] ) {
                continue;
            }

            startPlotPoint[selfCoordinate] = locationDecimal;
            endPlotPoint[selfCoordinate]   = locationDecimal;

            // Start point
            CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2 forLayerSize:layerSize];
            startViewPoint.x += originTransformed.x;
            startViewPoint.y += originTransformed.y;

            // End point
            CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2 forLayerSize:layerSize];
            endViewPoint.x += originTransformed.x;
            endViewPoint.y += originTransformed.y;

            // Align to pixels
            startViewPoint = alignmentFunction(context, startViewPoint);
            endViewPoint   = alignmentFunction(context, endViewPoint);

            // Add grid line
            CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
            CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
        }

        // Stroke grid lines
        [lineStyle setLineStyleInContext:context];
        [lineStyle strokePathInContext:context];
    }
}

/// @endcond

#pragma mark -
#pragma mark Background Bands

/// @cond

-(void)drawBackgroundBandsInContext:(CGContextRef)context
{
    NSArray *bandArray   = self.alternatingBandFills;
    NSUInteger bandCount = bandArray.count;

    if ( bandCount > 0 ) {
        NSArray *locations = [self.majorTickLocations allObjects];

        if ( locations.count > 0 ) {
            CPTPlotArea *thePlotArea = self.plotArea;
            LayerSize layerSizeValue;
            const LayerSize *layerSize;
            if ( thePlotArea ) {
                layerSizeValue.asFloat = thePlotArea.bounds.size;
                layerSizeValue.width = CPTDecimalFromCGFloat(layerSizeValue.asFloat.width);
                layerSizeValue.height = CPTDecimalFromCGFloat(layerSizeValue.asFloat.height);
                layerSize = &layerSizeValue;
            } else {
                layerSize = nil;
            }

            CPTPlotSpace *thePlotSpace = self.plotSpace;

            CPTCoordinate selfCoordinate = self.coordinate;
            CPTMutablePlotRange *range   = [[thePlotSpace plotRangeForCoordinate:selfCoordinate] mutableCopy];
            if ( range ) {
                CPTPlotRange *theVisibleRange = self.visibleRange;
                if ( theVisibleRange ) {
                    [range intersectionPlotRange:theVisibleRange];
                }
            }

            CPTCoordinate orthogonalCoordinate   = CPTOrthogonalCoordinate(selfCoordinate);
            CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
            CPTPlotRange *theGridLineRange       = self.gridLinesRange;

            if ( theGridLineRange ) {
                [orthogonalRange intersectionPlotRange:theGridLineRange];
            }

            NSDecimal zero                   = CPTDecimalFromInteger(0);
            NSSortDescriptor *sortDescriptor = nil;
            if ( range ) {
                if ( CPTDecimalGreaterThanOrEqualTo(range.length, zero) ) {
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
                }
                else {
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
                }
            }
            else {
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            }
            locations = [locations sortedArrayUsingDescriptors:@[sortDescriptor]];

            NSUInteger bandIndex = 0;
            id null              = [NSNull null];
            NSDecimal lastLocation;
            if ( range ) {
                lastLocation = range.location;
            }
            else {
                lastLocation = CPTDecimalNaN();
            }

            NSDecimal startPlotPoint[2];
            NSDecimal endPlotPoint[2];
            if ( orthogonalRange ) {
                startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
                endPlotPoint[orthogonalCoordinate]   = orthogonalRange.end;
            }
            else {
                startPlotPoint[orthogonalCoordinate] = CPTDecimalNaN();
                endPlotPoint[orthogonalCoordinate]   = CPTDecimalNaN();
            }

            for ( NSDecimalNumber *location in locations ) {
                NSDecimal currentLocation = [location decimalValue];
                if ( !CPTDecimalEquals(CPTDecimalSubtract(currentLocation, lastLocation), zero) ) {
                    CPTFill *bandFill = bandArray[bandIndex++];
                    bandIndex %= bandCount;

                    if ( bandFill != null ) {
                        // Start point
                        startPlotPoint[selfCoordinate] = currentLocation;
                        CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2 forLayerSize:layerSize];

                        // End point
                        endPlotPoint[selfCoordinate] = lastLocation;
                        CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2 forLayerSize:layerSize];

                        // Fill band
                        CGRect fillRect = CPTRectMake( MIN(startViewPoint.x, endViewPoint.x),
                                                       MIN(startViewPoint.y, endViewPoint.y),
                                                       ABS(endViewPoint.x - startViewPoint.x),
                                                       ABS(endViewPoint.y - startViewPoint.y) );
                        [bandFill fillRect:CPTAlignIntegralRectToUserSpace(context, fillRect) inContext:context];
                    }
                }

                lastLocation = currentLocation;
            }

            // Fill space between last location and the range end
            NSDecimal endLocation;
            if ( range ) {
                endLocation = range.end;
            }
            else {
                endLocation = CPTDecimalNaN();
            }
            if ( !CPTDecimalEquals(lastLocation, endLocation) ) {
                CPTFill *bandFill = bandArray[bandIndex];

                if ( bandFill != null ) {
                    // Start point
                    startPlotPoint[selfCoordinate] = endLocation;
                    CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2 forLayerSize:layerSize];

                    // End point
                    endPlotPoint[selfCoordinate] = lastLocation;
                    CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2 forLayerSize:layerSize];

                    // Fill band
                    CGRect fillRect = CPTRectMake( MIN(startViewPoint.x, endViewPoint.x),
                                                   MIN(startViewPoint.y, endViewPoint.y),
                                                   ABS(endViewPoint.x - startViewPoint.x),
                                                   ABS(endViewPoint.y - startViewPoint.y) );
                    [bandFill fillRect:CPTAlignIntegralRectToUserSpace(context, fillRect) inContext:context];
                }
            }
        }
    }
}

-(void)drawBackgroundLimitsInContext:(CGContextRef)context
{
    NSArray *limitArray = self.backgroundLimitBands;

    if ( limitArray.count > 0 ) {
        CPTPlotArea *thePlotArea = self.plotArea;
        LayerSize layerSizeValue;
        const LayerSize *layerSize;
        if ( thePlotArea ) {
            layerSizeValue.asFloat = thePlotArea.bounds.size;
            layerSizeValue.width = CPTDecimalFromCGFloat(layerSizeValue.asFloat.width);
            layerSizeValue.height = CPTDecimalFromCGFloat(layerSizeValue.asFloat.height);
            layerSize = &layerSizeValue;
        } else {
            layerSize = nil;
        }

        CPTPlotSpace *thePlotSpace = self.plotSpace;

        CPTCoordinate selfCoordinate = self.coordinate;
        CPTMutablePlotRange *range   = [[thePlotSpace plotRangeForCoordinate:selfCoordinate] mutableCopy];

        if ( range ) {
            CPTPlotRange *theVisibleRange = self.visibleRange;
            if ( theVisibleRange ) {
                [range intersectionPlotRange:theVisibleRange];
            }
        }

        CPTCoordinate orthogonalCoordinate   = CPTOrthogonalCoordinate(selfCoordinate);
        CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
        CPTPlotRange *theGridLineRange       = self.gridLinesRange;

        if ( theGridLineRange ) {
            [orthogonalRange intersectionPlotRange:theGridLineRange];
        }

        NSDecimal startPlotPoint[2];
        NSDecimal endPlotPoint[2];
        startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
        endPlotPoint[orthogonalCoordinate]   = orthogonalRange.end;

        for ( CPTLimitBand *band in self.backgroundLimitBands ) {
            CPTFill *bandFill = band.fill;

            if ( bandFill ) {
                CPTMutablePlotRange *bandRange = [band.range mutableCopy];
                if ( bandRange ) {
                    [bandRange intersectionPlotRange:range];

                    // Start point
                    startPlotPoint[selfCoordinate] = bandRange.location;
                    CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2 forLayerSize:layerSize];

                    // End point
                    endPlotPoint[selfCoordinate] = bandRange.end;
                    CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2 forLayerSize:layerSize];

                    // Fill band
                    CGRect fillRect = CPTRectMake( MIN(startViewPoint.x, endViewPoint.x),
                                                   MIN(startViewPoint.y, endViewPoint.y),
                                                   ABS(endViewPoint.x - startViewPoint.x),
                                                   ABS(endViewPoint.y - startViewPoint.y) );
                    [bandFill fillRect:CPTAlignIntegralRectToUserSpace(context, fillRect) inContext:context];
                }
            }
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    CPTPlotRange *range    = [self.plotSpace plotRangeForCoordinate:self.coordinate];
    CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:range.location];
    CGPoint endViewPoint   = [self viewPointForCoordinateDecimalNumber:range.end];

    return [NSString stringWithFormat:@"<%@ with range: %@ viewCoordinates: %@ to %@>",
            [super description],
            range,
            CPTStringFromPoint(startViewPoint),
            CPTStringFromPoint(endViewPoint)];
}

/// @endcond

#pragma mark -
#pragma mark Titles

/// @cond

// Center title in the plot range by default
-(NSDecimal)defaultTitleLocation
{
    NSDecimal location;

    CPTPlotSpace *thePlotSpace  = self.plotSpace;
    CPTCoordinate theCoordinate = self.coordinate;

    CPTPlotRange *axisRange = [thePlotSpace plotRangeForCoordinate:theCoordinate];

    if ( axisRange ) {
        CPTScaleType scaleType = [thePlotSpace scaleTypeForCoordinate:theCoordinate];

        switch ( scaleType ) {
            case CPTScaleTypeLinear:
                location = axisRange.midPoint;
                break;

            case CPTScaleTypeLog:
            {
                double loc = axisRange.locationDouble;
                double end = axisRange.endDouble;

                if ( (loc > 0.0) && (end >= 0.0) ) {
                    location = CPTDecimalFromDouble( pow(10.0, ( log10(loc) + log10(end) ) / 2.0) );
                }
                else {
                    location = axisRange.midPoint;
                }
            }
            break;

            default:
                location = axisRange.midPoint;
                break;
        }
    }
    else {
        location = CPTDecimalFromInteger(0);
    }

    return location;
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setAxisConstraints:(CPTConstraints *)newConstraints
{
    if ( ![axisConstraints isEqualToConstraint:newConstraints] ) {
        axisConstraints = newConstraints;
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}

-(void)setOrthogonalCoordinateDecimal:(NSDecimal)newCoord
{
    if ( NSDecimalCompare(&orthogonalCoordinateDecimal, &newCoord) != NSOrderedSame ) {
        orthogonalCoordinateDecimal = newCoord;
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}

-(void)setCoordinate:(CPTCoordinate)newCoordinate
{
    if ( self.coordinate != newCoordinate ) {
        [super setCoordinate:newCoordinate];
        switch ( newCoordinate ) {
            case CPTCoordinateX:
                switch ( self.labelAlignment ) {
                    case CPTAlignmentLeft:
                    case CPTAlignmentCenter:
                    case CPTAlignmentRight:
                        // ok--do nothing
                        break;

                    default:
                        self.labelAlignment = CPTAlignmentCenter;
                        break;
                }
                break;

            case CPTCoordinateY:
                switch ( self.labelAlignment ) {
                    case CPTAlignmentTop:
                    case CPTAlignmentMiddle:
                    case CPTAlignmentBottom:
                        // ok--do nothing
                        break;

                    default:
                        self.labelAlignment = CPTAlignmentMiddle;
                        break;
                }
                break;

            default:
                [NSException raise:NSInvalidArgumentException format:@"Invalid coordinate: %lu", (unsigned long)newCoordinate];
                break;
        }
    }
}

/// @endcond

@end
