#import "CPTPolarAxis.h"

#import "CPTAxisLabel.h"
#import "CPTConstraints.h"
#import "CPTDefinitions.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLimitBand.h"
#import "CPTLineCap.h"
#import "CPTLineStyle.h"
#import "CPTMutablePlotRange.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"
#import "CPTGraphHostingView.h"
#import "CPTUtilities.h"
#import "CPTPolarPlotSpace.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/// @cond
@interface CPTPolarAxis()

-(void)drawTicksInContext:(nonnull CGContextRef)context atLocations:(nullable CPTNumberSet*)locations withLength:(CGFloat)length inRange:(nullable CPTPlotRange *)labeledRange isMajor:(BOOL)major;

-(void)orthogonalCoordinateViewLowerBound:(nonnull CGFloat *)lower upperBound:(nonnull CGFloat *)upper;
-(CGPoint)viewPointForOrthogonalCoordinate:(nullable NSNumber *)orthogonalCoord axisCoordinate:(nullable NSNumber *)coordinateValue;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A 2-dimensional cartesian (Polar) axis class.
 **/
@implementation CPTPolarAxis

/** @property NSNumber *orthogonalPosition
 *  @brief The data coordinate value where the axis crosses the orthogonal axis.
 *  If the @ref axisConstraints is non-nil, the constraints take priority and this property is ignored.
 *  @see @ref axisConstraints
 **/
@synthesize orthogonalPosition;

/** @property CPTConstraints *axisConstraints
 *  @brief The constraints used when positioning relative to the plot area.
 *  If @nil (the default), the axis is fixed relative to the plot space coordinates,
 *  crossing the orthogonal axis at @ref orthogonalPosition and moves only
 *  whenever the plot space ranges change.
 *  @see @ref orthogonalPosition
 **/
@synthesize axisConstraints;

/** @property nullable CPTNumberSet *alteredMajorTickLocations
 *  @brief A set of radial axis coordinates for all extended major tick marks.
 **/
@synthesize alteredMajorTickLocations;

/** @property nullable NSNumber *radialLabelLocation
 *  @brief The position along the axis where the axis title should be centered.
 *  If @NAN (the default), the @ref DefaultRadialLabelLocation will be used.
 **/
@synthesize radialLabelLocation;

/** @property nonnull NSNumber *defaultRadialLabelLocation
 *  @brief The position along the axis where the axis radial label should be centered
 *  if @ref radialLabelLocation is @NAN.
 **/
@dynamic defaultRadialLabelLocation;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPolarAxis object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref orthogonalPosition = @num{0}
 *  - @ref axisConstraints = @nil
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTPolarAxis object.
 **/
-(nonnull instancetype)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        orthogonalPosition = @0.0;
        axisConstraints    = nil;
        self.tickDirection = CPTSignNone;
        radialLabelLocation = @(NAN);
    }

    return self;
}

/// @}

/// @cond

-(nonnull instancetype)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTPolarAxis *theLayer = (CPTPolarAxis *)layer;

        orthogonalPosition = theLayer->orthogonalPosition;
        axisConstraints = theLayer->axisConstraints;
        radialLabelLocation = theLayer->radialLabelLocation;
    }
    return self;
}

-(void)dealloc
{
    axisConstraints = nil;
    alteredMajorTickLocations = nil;
    radialLabelLocation = nil;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.orthogonalPosition forKey:@"CPTPolarAxis.orthogonalPosition"];
    [coder encodeObject:self.axisConstraints forKey:@"CPTPolarAxis.axisConstraints"];
    [coder encodeObject:self.radialLabelLocation forKey:@"CPTPolarAxis.radialLabelLocation"];
}

-(nullable instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        orthogonalPosition = [coder decodeObjectForKey:@"CPTPolarAxis.orthogonalPosition"];
        axisConstraints    = [coder decodeObjectForKey:@"CPTPolarAxis.axisConstraints"];
        radialLabelLocation    = [coder decodeObjectForKey:@"CPTPolarAxis.radialLabelLocation"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Coordinate Transforms

/// @cond

-(void)orthogonalCoordinateViewLowerBound:(nonnull CGFloat *)lower upperBound:(nonnull CGFloat *)upper
{
    CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
    CPTPolarPlotSpace *polarPlotSpace  = (CPTPolarPlotSpace *)self.plotSpace;
    CPTPlotRange *orthogonalRange      = [polarPlotSpace plotRangeForCoordinate:orthogonalCoordinate];
    
    NSAssert(orthogonalRange != nil, @"The orthogonalRange was nil in orthogonalCoordinateViewLowerBound:upperBound:");
    
    CGPoint lowerBoundPoint = [self viewPointForOrthogonalCoordinate:orthogonalRange.location axisCoordinate:@0];
    CGPoint upperBoundPoint = [self viewPointForOrthogonalCoordinate:orthogonalRange.end axisCoordinate:@0];
    
    switch ( self.coordinate ) {
        case CPTCoordinateX:
            *lower = lowerBoundPoint.y;
            *upper = upperBoundPoint.y;
            break;
            
        case CPTCoordinateY:
            *lower = lowerBoundPoint.x;
            *upper = upperBoundPoint.x;
            break;
            
        case CPTCoordinateZ:
            *lower = 0.0;
            *upper = 0.0;
            break;
            
        default:
            *lower = (CGFloat)NAN;
            *upper = (CGFloat)NAN;
            break;
    }
}


-(CGPoint)viewPointForOrthogonalCoordinate:(nullable NSNumber *)orthogonalCoord axisCoordinate:(nullable NSNumber *)coordinateValue
{
    if(self.coordinate == CPTCoordinateZ) {
        CPTPlotArea *thePlotArea = self.plotArea;
        CPTPlotSpace *thePlotSpace = self.plotSpace;
        CGPoint originTransformed = [self convertPoint:self.frame.origin fromLayer:thePlotArea];
        
        NSDecimal centrePlotPoint[2];
        centrePlotPoint[0] = CPTDecimalFromDouble(0.0);
        centrePlotPoint[1] = CPTDecimalFromDouble(0.0);
        
        CGPoint centreViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:centrePlotPoint numberOfCoordinates:2];
        centreViewPoint.x += originTransformed.x;
        centreViewPoint.y += originTransformed.y;
        
        NSDecimal plotPoint[2];
        plotPoint[CPTCoordinateX] = self.radialLabelLocation.decimalValue;
        plotPoint[CPTCoordinateY] = CPTDecimalFromDouble(0.0);
        
        CGPoint radialLabelLocationPoint =  [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2] fromLayer:thePlotArea];
        CGFloat radialLabelLocationRadius = radialLabelLocationPoint.x - centreViewPoint.x;
        
        CGPoint labelPosition;
        if (((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees) {
            labelPosition = CGPointMake(radialLabelLocationRadius * (CGFloat)sin([coordinateValue doubleValue] / 180.0 * M_PI) + centreViewPoint.x, radialLabelLocationRadius * (CGFloat)cos([coordinateValue doubleValue] / 180.0 * M_PI) + centreViewPoint.y);
        }
        else {
            labelPosition = CGPointMake(radialLabelLocationRadius * (CGFloat)sin([coordinateValue floatValue]) + centreViewPoint.x, radialLabelLocationRadius * (CGFloat)cos([coordinateValue floatValue]) + centreViewPoint.y);
        }
        return labelPosition;
    }
    else
    {
        CPTCoordinate myCoordinate         = self.coordinate;
        CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(myCoordinate);
        
        NSDecimal plotPoint[2];
        plotPoint[myCoordinate]         = coordinateValue.decimalValue;
        plotPoint[orthogonalCoordinate] = orthogonalCoord.decimalValue;
        
        CPTPlotArea *thePlotArea = self.plotArea;
        
        CGPoint labelPosition = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2] fromLayer:thePlotArea];;
        if ( self.coordinate == CPTCoordinateY ) {
//            CPTPolarPlotSpace *thePolarPlotSpace = (CPTPolarPlotSpace*)self.plotSpace;
//            double ratio = thePolarPlotSpace.minorRange.lengthDouble / thePolarPlotSpace.majorRange.lengthDouble;
            double ratio = CPTDecimalDoubleValue(thePlotArea.heightDecimal) / CPTDecimalDoubleValue(thePlotArea.widthDecimal);
            labelPosition.y = (labelPosition.y - thePlotArea.bounds.size.height / 2.0) / ratio + thePlotArea.bounds.size.height / 2.0;
        }
        return labelPosition;
    }
}

-(CGPoint)viewPointForCoordinateValue:(nullable NSNumber *)coordinateValue
{
    CGPoint point = [self viewPointForOrthogonalCoordinate:self.orthogonalPosition
                                            axisCoordinate:coordinateValue];
    
    CPTConstraints *theAxisConstraints = self.axisConstraints;
    
    if ( theAxisConstraints ) {
        CGFloat lb, ub;
        [self orthogonalCoordinateViewLowerBound:&lb upperBound:&ub];
        CGFloat constrainedPosition = [theAxisConstraints positionForLowerBound:lb upperBound:ub];
        
        switch ( self.coordinate ) {
            case CPTCoordinateX:
                point.y = constrainedPosition;
                break;
                
            case CPTCoordinateY:
                point.x = constrainedPosition;
                break;
            
            case CPTCoordinateZ:
                point.x = constrainedPosition;
                point.y = constrainedPosition;
                break;
                
            default:
                break;
        }
    }
    
    if ( isnan(point.x) || isnan(point.y)) {
        NSLog( @"[CPTPolarAxis viewPointForCoordinateValue:%@] was %@", coordinateValue, CPTStringFromPoint(point) );
        
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

-(void)drawTicksInContext:(nonnull CGContextRef)context atLocations:(nullable CPTNumberSet*)locations withLength:(CGFloat)length inRange:(nullable CPTPlotRange *)labeledRange isMajor:(BOOL)major
{
    CPTLineStyle *lineStyle = (major ? self.majorTickLineStyle : self.minorTickLineStyle);

    if ( !lineStyle ) {
        return;
    }

    [lineStyle setLineStyleInContext:context];
    CGContextBeginPath(context);

    for ( NSDecimalNumber * __strong tickLocation in locations )
    {
//        if(self.coordinate == CPTCoordinateZ && ((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees) {
//            tickLocation = [tickLocation decimalNumberByMultiplyingBy: (NSDecimalNumber *)[NSDecimalNumber numberWithDouble: M_PI / 180.0]];
//        }
        if ( labeledRange && ![labeledRange containsNumber:tickLocation] ) {
            continue;
        }
        
        // Tick end points
        CGPoint baseViewPoint  = [self viewPointForCoordinateValue:tickLocation];
        CGPoint startViewPoint = baseViewPoint;
        CGPoint endViewPoint   = baseViewPoint;

        CGFloat startFactor = CPTFloat(0.0);
        CGFloat endFactor   = CPTFloat(0.0);
        switch ( self.tickDirection ) {
            case CPTSignPositive:
                endFactor = CPTFloat(1.0);
                break;

            case CPTSignNegative:
                endFactor = -CPTFloat(1.0);
                break;

            case CPTSignNone:
                startFactor = -CPTFloat(0.5);
                endFactor   = CPTFloat(0.5);
                break;

//            default:
//                NSLog(@"Invalid sign in [CPTPolarAxis drawTicksInContext:]");
//                break;
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
            
            case CPTCoordinateZ:
                startViewPoint.x += length * startFactor;
                startViewPoint.y += length * startFactor;
                endViewPoint.x   += length * endFactor;
                endViewPoint.y   += length * endFactor;
                break;


            default:
                NSLog(@"Invalid coordinate in [CPTPolarAxis drawTicksInContext:]");
        }

        startViewPoint = CPTAlignPointToUserSpace(context, startViewPoint);
        endViewPoint   = CPTAlignPointToUserSpace(context, endViewPoint);

        // Add tick line
        CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
        CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
    }
    // Stroke tick line
    [lineStyle strokePathInContext:context];
}

-(void)renderAsVectorInContext:(nonnull CGContextRef)context
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
            range = nil;
            range = [theVisibleAxisRange mutableCopy];
        }
        CPTAlignPointFunction alignmentFunction = CPTAlignPointToUserSpace;
        if ( theLineStyle ) {
            CGPoint startViewPoint = alignmentFunction(context, [self viewPointForCoordinateValue:range.location]);
            CGPoint endViewPoint   = alignmentFunction(context, [self viewPointForCoordinateValue:range.end]);
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
                    axisDirection = ( range.lengthDouble >= 0.0) ? CPTPointMake(1.0, 0.0) : CPTPointMake(-1.0, 0.0);
                    break;

                case CPTCoordinateY:
                    axisDirection = ( range.lengthDouble >= 0.0) ? CPTPointMake(0.0, 1.0) : CPTPointMake(0.0, -1.0);
                    break;
                    
                case CPTCoordinateZ:
                    axisDirection = ( range.lengthDouble >= 0.0) ? CPTPointMake(0.0, 1.0) : CPTPointMake(0.0, -1.0);
                    break;


                default:
                    break;
            }
        }

        if ( minCap ) {
            CGPoint viewPoint = alignmentFunction(context, [self viewPointForCoordinateValue:range.minLimit]);
            [minCap renderAsVectorInContext:context atPoint:viewPoint inDirection:CPTPointMake(-axisDirection.x, -axisDirection.y)];
        }
        
        if ( maxCap ) {
            CGPoint viewPoint = alignmentFunction(context, [self viewPointForCoordinateValue:range.maxLimit]);
            [maxCap renderAsVectorInContext:context atPoint:viewPoint inDirection:axisDirection];
        }
    }

//    [range release];
    range = nil;
}

/// @endcond

#pragma mark -
#pragma mark Grid Lines

/// @cond

-(void)drawGridLinesInContext:(nonnull CGContextRef)context isMajor:(BOOL)major
{
    CPTLineStyle *lineStyle = (major ? self.majorGridLineStyle : self.minorGridLineStyle);

    if ( lineStyle ) {
        [super renderAsVectorInContext:context];

        [self relabel];

        CPTPolarPlotSpace *thePlotSpace      = (CPTPolarPlotSpace*)self.plotSpace;
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

        CPTPlotArea *thePlotArea = self.plotArea;
        CGPoint originTransformed = [self convertPoint:self.frame.origin fromLayer:thePlotArea];
        
        NSDecimal centrePlotPoint[2];
        centrePlotPoint[0] = CPTDecimalFromDouble(0.0);
        centrePlotPoint[1] = CPTDecimalFromDouble(0.0);
        
        CGPoint centreViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:centrePlotPoint numberOfCoordinates:2];
        centreViewPoint.x += originTransformed.x;
        centreViewPoint.y += originTransformed.y;
        
        // Stroke grid lines
        [lineStyle setLineStyleInContext:context];
        
        CGFloat lineWidth = lineStyle.lineWidth;
        
        CPTAlignPointFunction alignmentFunction = NULL;
        if ( ( self.contentsScale > CPTFloat(1.0) ) && (round(lineWidth) == lineWidth) ) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace;
        }
        else {
            alignmentFunction = CPTAlignPointToUserSpace;
        }

        centreViewPoint   = CPTAlignPointToUserSpace(context, centreViewPoint);
        CGSize totalSize = self.graph.frame.size;
        double centreToTopLeft = sqrt(pow((double)centreViewPoint.x, 2.0) + pow((double)totalSize.height-(double)centreViewPoint.y, 2.0));
        double centreToTopRight = sqrt(pow((double)totalSize.width-(double)centreViewPoint.x, 2.0) + pow((double)totalSize.height-(double)centreViewPoint.y, 2.0));
        double centreToBtmRight = sqrt(pow((double)totalSize.width-(double)centreViewPoint.x, 2.0) + pow((double)centreViewPoint.y, 2.0));
        double centreToBtmLeft = sqrt(pow((double)centreViewPoint.x, 2.0) + pow((double)centreViewPoint.y, 2.0));
        
        double maxLength = MAX(centreToTopLeft, MAX(centreToTopRight, MAX(centreToBtmRight, centreToBtmLeft)));
        maxLength*= 2.0;
        
        NSDecimal startPlotPoint[2];
        
        if(selfCoordinate == CPTCoordinateX)
        {
            startPlotPoint[orthogonalCoordinate] = centrePlotPoint[CPTCoordinateY];
            CGContextBeginPath(context);               
            //CGContextSetStrokeColorWithColor(context, lineStyle.lineColor);
            
            NSMutableSet *mutableLocations = [NSMutableSet setWithSet:locations];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"doubleValue" ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            NSArray *sortedArraySet = [locations sortedArrayUsingDescriptors:sortDescriptors];
            double minDecimalNumber = [[sortedArraySet firstObject] doubleValue];
            double maxDecimalNumber = [[sortedArraySet lastObject] doubleValue];

            double intervalLength = major ? [self.majorIntervalLength doubleValue] : [self.majorIntervalLength doubleValue] / (double)(((CPTPolarPlotSpace*)self.plotSpace).majorScaleType == CPTScaleTypeLogModulus ? self.minorTicksPerInterval+2 : self.minorTicksPerInterval+1);
            double newNoLocations = 0;

            if(major)
            {
                double length = (totalSize.width < totalSize.height ? (double)totalSize.width : (double)totalSize.height);
                if(maxLength / length > 1.0) {
                    if ( ((CPTPolarPlotSpace*)self.plotSpace).majorScaleType == CPTScaleTypeLog ) {
                        newNoLocations = ceil((double)[locations count] * log10((maxLength / length))) + 1;
                    }
                    else if ( ((CPTPolarPlotSpace*)self.plotSpace).majorScaleType == CPTScaleTypeLogModulus ) {
                        newNoLocations = ceil((double)[locations count] * CPTLogModulus((maxLength / length))) + 1;
                    }
                    else {
                        newNoLocations = ceil((double)[locations count] * (maxLength / length)) + 1;
                    }
                }
            }
            else {
                newNoLocations = [self.alteredMajorTickLocations count] * self.minorTicksPerInterval;
            }

            double i = (double)[locations count];
            double increasingPower = ceil(log10(intervalLength));
            while(i < newNoLocations)
            {
                if ( ((CPTPolarPlotSpace*)self.plotSpace).majorScaleType == CPTScaleTypeLog || ((CPTPolarPlotSpace*)self.plotSpace).majorScaleType == CPTScaleTypeLogModulus ) {
                    if( fmod((maxDecimalNumber / intervalLength), 9) == 0.0 ) {
                        maxDecimalNumber+= intervalLength;
                        minDecimalNumber-= intervalLength;
                        increasingPower = ceil(log10(maxDecimalNumber));
                    }
                    intervalLength = pow(10.0, increasingPower);
                }
                maxDecimalNumber+=  intervalLength;
                minDecimalNumber-=  intervalLength;

                if(!major)
                {
                    if([self.alteredMajorTickLocations containsObject:[NSDecimalNumber numberWithDouble:minDecimalNumber]] || [self.alteredMajorTickLocations containsObject:[NSDecimalNumber numberWithDouble:maxDecimalNumber]])
                        continue;
                }
                [mutableLocations addObject:[NSDecimalNumber numberWithDouble:minDecimalNumber]];
                [mutableLocations addObject:[NSDecimalNumber numberWithDouble:maxDecimalNumber]];
                i+=2.0;
            }
            if(major) {
                self.alteredMajorTickLocations = [NSSet setWithSet:[mutableLocations copy]];
            }
            
            for ( NSDecimalNumber *location in mutableLocations )
            {
                NSDecimal locationDecimal = location.decimalValue;
                
                if ( labeledRange && ![labeledRange contains:locationDecimal] ) {
                    continue;
                }
           
                startPlotPoint[selfCoordinate] = locationDecimal;
                startPlotPoint[orthogonalCoordinate] = [[NSDecimalNumber numberWithDouble:0.0] decimalValue];
                // Start point
                CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
                startViewPoint.x += originTransformed.x;
                startViewPoint.y += originTransformed.y;
                
                // Align to pixels
                startViewPoint = alignmentFunction(context, startViewPoint);
                
                double diameter = 2.0 * (double)(startViewPoint.x - centreViewPoint.x);
                CGContextStrokeEllipseInRect(context, CGRectMake(-(CGFloat)0.5*(CGFloat)diameter+(CGFloat)centreViewPoint.x, -(CGFloat)0.5*(CGFloat)diameter+(CGFloat)centreViewPoint.y, (CGFloat)diameter, (CGFloat)diameter));
                
                CGContextStrokePath(context);
            }
        }
        else if(selfCoordinate == CPTCoordinateY)
            ;
        else if(selfCoordinate == CPTCoordinateZ)
        {
            CGContextBeginPath(context);
            //Base lines
            
            double maxSize = maxLength / 2.0;//orthogonalRange.lengthDouble;
            CGPoint endViewPoint = CGPointZero;
            double mvr = [self.majorIntervalLength doubleValue];
            if(((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees)
                mvr*= (M_PI/180.0);
                
            if(!major)
                mvr /= (self.minorTicksPerInterval + 1);
            int noRadialLines = (int)(2.0*M_PI / mvr);
            for (int i = 0; i < noRadialLines; i++)
            {
                
                double a = (mvr * (double)i) - M_PI_2;
                double x = maxSize * cos(a);
                double y = maxSize * sin(a);
                
                CGContextMoveToPoint(context, centreViewPoint.x, centreViewPoint.y);
                
                // End point
                endViewPoint.x = (CGFloat)x + originTransformed.x;
                endViewPoint.y = (CGFloat)y + originTransformed.y;
                
                // Align to pixels
                endViewPoint = CPTAlignPointToUserSpace(context, endViewPoint);
                
                CGContextAddLineToPoint(context, centreViewPoint.x + endViewPoint.x , centreViewPoint.y + endViewPoint.y);
                CGContextStrokePath(context);
            }
        }
        orthogonalRange = nil;
        labeledRange = nil;
    }
}

/// @endcond

#pragma mark -
#pragma mark Background Bands

/// @cond

-(NSUInteger)initialBandIndexForSortedLocations:(nonnull CPTNumberArray *)sortedLocations inRange:(nullable CPTMutablePlotRange *)range
{
    NSUInteger bandIndex = 0;

    NSNumber *bandAnchor = self.alternatingBandAnchor;
    NSUInteger bandCount = self.alternatingBandFills.count;

    if ( bandAnchor && (bandCount > 0)) {
        NSDecimal anchor = bandAnchor.decimalValue;

        CPTPlotRange *theVisibleRange = self.visibleRange;
        if ( theVisibleRange ) {
            [range intersectionPlotRange:theVisibleRange];
        }

        NSDecimal rangeStart;
        if ( range.lengthDouble >= 0.0 ) {
            rangeStart = range.minLimitDecimal;
        }
        else {
            rangeStart = range.maxLimitDecimal;
        }

        NSDecimal origin = self.labelingOrigin.decimalValue;
        NSDecimal offset = CPTDecimalSubtract(anchor, origin);
        NSDecimalRound(&offset, &offset, 0, NSRoundDown);

        const NSDecimal zero = CPTDecimalFromInteger(0);

        // Set starting coord--should be the smallest value >= rangeMin that is a whole multiple of majorInterval away from the alternatingBandAnchor
        NSDecimal coord         = zero;
        NSDecimal majorInterval = zero;

        switch ( self.labelingPolicy ) {
            case CPTAxisLabelingPolicyAutomatic:
            case CPTAxisLabelingPolicyEqualDivisions:
                if ( sortedLocations.count > 1 ) {
                    if ( range.lengthDouble >= 0.0 ) {
                        majorInterval = CPTDecimalSubtract(sortedLocations[1].decimalValue, sortedLocations[0].decimalValue);
                    }
                    else {
                        majorInterval = CPTDecimalSubtract(sortedLocations[0].decimalValue, sortedLocations[1].decimalValue);
                    }
                }
                break;

            case CPTAxisLabelingPolicyFixedInterval:
            {
                majorInterval = self.majorIntervalLength.decimalValue;
            }
            break;

            case CPTAxisLabelingPolicyLocationsProvided:
            case CPTAxisLabelingPolicyNone:
            {
                // user provided tick locations; they're not guaranteed to be evenly spaced, but band drawing always starts with the first location
                if ( range.lengthDouble >= 0.0 ) {
                    for ( NSNumber *location in sortedLocations ) {
                        if ( CPTDecimalLessThan(anchor, location.decimalValue)) {
                            break;
                        }

                        bandIndex++;
                    }
                }
                else {
                    for ( NSNumber *location in sortedLocations ) {
                        if ( CPTDecimalGreaterThanOrEqualTo(anchor, location.decimalValue)) {
                            break;
                        }

                        bandIndex++;
                    }
                }

                bandIndex = bandIndex % bandCount;
            }
            break;
        }

        if ( !CPTDecimalEquals(majorInterval, zero)) {
            coord = CPTDecimalDivide(CPTDecimalSubtract(rangeStart, origin), majorInterval);
            NSDecimalRound(&coord, &coord, 0, NSRoundUp);
            NSInteger stepCount = CPTDecimalIntegerValue(coord) + CPTDecimalIntegerValue(offset) + 1;

            if ( stepCount >= 0 ) {
                bandIndex = (NSUInteger)(stepCount % (NSInteger)bandCount);
            }
            else {
                bandIndex = (NSUInteger)(-stepCount % (NSInteger)bandCount);
            }
        }
    }

    return bandIndex;
}

-(void)drawBackgroundBandsInContext:(nonnull CGContextRef)context
{
    CPTFillArray *bandArray = self.alternatingBandFills;
    NSUInteger bandCount   = bandArray.count;
    
    if ( bandCount > 0 ) {
        CPTNumberArray *locations = [self.majorTickLocations allObjects];
        
        if ( locations.count > 0 ) {
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
                if ( CPTDecimalGreaterThanOrEqualTo(range.lengthDecimal, zero) ) {
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
                lastLocation = range.locationDecimal;
            }
            else {
                lastLocation = CPTDecimalNaN();
            }
            
            NSDecimal startPlotPoint[2];
            NSDecimal endPlotPoint[2];
            if ( orthogonalRange ) {
                startPlotPoint[orthogonalCoordinate] = orthogonalRange.locationDecimal;
                endPlotPoint[orthogonalCoordinate]   = orthogonalRange.endDecimal;
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
                        CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
                        
                        // End point
                        endPlotPoint[selfCoordinate] = lastLocation;
                        CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2];
                        
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
                endLocation = range.endDecimal;
            }
            else {
                endLocation = CPTDecimalNaN();
            }
            if ( !CPTDecimalEquals(lastLocation, endLocation) ) {
                CPTFill *bandFill = bandArray[bandIndex];
                
                if ( bandFill != null ) {
                    // Start point
                    startPlotPoint[selfCoordinate] = endLocation;
                    CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
                    
                    // End point
                    endPlotPoint[selfCoordinate] = lastLocation;
                    CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2];
                    
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

-(void)drawBackgroundLimitsInContext:(nonnull CGContextRef)context
{
    CPTLimitBandArray *limitArray = self.backgroundLimitBands;
    
    if ( limitArray.count > 0 ) {
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
        startPlotPoint[orthogonalCoordinate] = orthogonalRange.locationDecimal;
        endPlotPoint[orthogonalCoordinate]   = orthogonalRange.endDecimal;
        
        for ( CPTLimitBand *band in self.backgroundLimitBands ) {
            CPTFill *bandFill = band.fill;
            
            if ( bandFill ) {
                CPTMutablePlotRange *bandRange = [band.range mutableCopy];
                if ( bandRange ) {
                    [bandRange intersectionPlotRange:range];
                    
                    // Start point
                    startPlotPoint[selfCoordinate] = bandRange.locationDecimal;
                    CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
                    
                    // End point
                    endPlotPoint[selfCoordinate] = bandRange.endDecimal;
                    CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2];
                    
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
    CGPoint startViewPoint = [self viewPointForCoordinateValue:range.location];
    CGPoint endViewPoint   = [self viewPointForCoordinateValue:range.end];
    
    return [NSString stringWithFormat:@"<%@ with range: %@ viewCoordinates: %@ to %@>",
            [super description],
            range,
            CPTStringFromPoint(startViewPoint),
            CPTStringFromPoint(endViewPoint)];
}


/// @endcond

#pragma mark -
#pragma mark Ticks

/// @cond

-(CGFloat)tickOffset
{
    CGFloat offset = CPTFloat(0.0);
    
    switch ( self.tickDirection ) {
        case CPTSignNone:
            offset += self.majorTickLength * CPTFloat(0.5);
            break;
            
        case CPTSignPositive:
        case CPTSignNegative:
            offset += self.majorTickLength;
            break;
    }
    
    return offset;
}

/// @cond

#pragma mark -
#pragma mark Ticks

/// @cond


// Center title in the plot range by default
-(nonnull NSNumber *)defaultRadialLabelLocation
{
    if(self.coordinate != CPTCoordinateZ)
        return @0;
    
    NSNumber *location;
    
    CPTPlotSpace *thePlotSpace  = self.plotSpace;
    CPTCoordinate theCoordinate = self.coordinate;
    
    CPTPlotRange *axisRange = [thePlotSpace plotRangeForCoordinate:CPTCoordinateX];
    
    if ( axisRange ) {
        CPTScaleType scaleType = [thePlotSpace scaleTypeForCoordinate:theCoordinate];
        
        switch ( scaleType ) {
            case CPTScaleTypeLinear:
                location = [NSNumber numberWithDouble:[axisRange.midPoint doubleValue] + axisRange.lengthDouble / 2.0];
                break;
                
            case CPTScaleTypeLog:
            {
                double loc = axisRange.locationDouble;
                double end = axisRange.endDouble;
                
                if ( (loc > 0.0) && (end >= 0.0) ) {
                    location = @( pow(10.0, ( log10(loc) + log10(end) ) / 4.0) );
                }
                else {
                    location = [NSNumber numberWithDouble:[axisRange.midPoint doubleValue] + axisRange.lengthDouble / 2.0];
                }
            }
                break;
                
            case CPTScaleTypeLogModulus:
            {
                double loc = axisRange.locationDouble;
                double end = axisRange.endDouble;
                
                location = @( CPTInverseLogModulus( ( CPTLogModulus(loc) + CPTLogModulus(end) ) / 2.0 ) );
            }
                break;
                
            default:
                location = [NSNumber numberWithDouble:[axisRange.midPoint doubleValue] + axisRange.lengthDouble / 2.0];
                break;
        }
    }
    else {
        location = @0;
    }
    
    return location;
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setAxisConstraints:(nullable CPTConstraints *)newConstraints
{
    if ( ![axisConstraints isEqualToConstraint:newConstraints] ) {
        axisConstraints = newConstraints;
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}

//-(void)setOrthogonalPosition:(nullable NSNumber *)newPosition
//{
//    BOOL needsUpdate = YES;
//    
//    if ( newPosition ) {
//        needsUpdate = ![orthogonalPosition isEqualToNumber:newPosition];
//    }
//    
//    if ( needsUpdate ) {
//        orthogonalPosition = newPosition;
//        [self setNeedsDisplay];
//        [self setNeedsLayout];
//    }
//}

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
            case CPTCoordinateZ:
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

-(void)setRadialLabelLocation:(nullable NSNumber *)newLocation
{
    BOOL needsUpdate = YES;
    
    if ( newLocation ) {
        NSNumber *location = newLocation;
        needsUpdate = ![radialLabelLocation isEqualToNumber:location];
    }
    
    if ( needsUpdate ) {
        radialLabelLocation = newLocation;
        [self updateMajorTickLabels];
    }
}

-(nullable NSNumber *)radialLabelLocation
{
    if ( isnan(radialLabelLocation.doubleValue) ) {
        return self.defaultRadialLabelLocation;
    }
    else {
        return radialLabelLocation;
    }
}

/// @endcond

@end
