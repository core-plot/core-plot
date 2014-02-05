#import "CPTXYPlotSpace.h"

#import "CPTAnimation.h"
#import "CPTAnimationOperation.h"
#import "CPTAnimationPeriod.h"
#import "CPTAxisSet.h"
#import "CPTExceptions.h"
#import "CPTGraph.h"
#import "CPTGraphHostingView.h"
#import "CPTMutablePlotRange.h"
#import "CPTPlot.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/// @cond
@interface CPTXYPlotSpace()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(NSDecimal)plotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;
-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange;
-(void)animateRangeForCoordinate:(CPTCoordinate)coordinate shift:(NSDecimal)shift momentumTime:(CGFloat)momentumTime speed:(CGFloat)speed acceleration:(CGFloat)acceleration;
-(CPTPlotRange *)shiftRange:(CPTPlotRange *)oldRange by:(NSDecimal)shift usingMomentum:(BOOL)momentum inGlobalRange:(CPTPlotRange *)globalRange withDisplacement:(CGFloat *)displacement;

-(CGFloat)viewCoordinateForRange:(CPTPlotRange *)range coordinate:(CPTCoordinate)coordinate direction:(BOOL)direction;

CGFloat firstPositiveRoot(CGFloat a, CGFloat b, CGFloat c);

@property (nonatomic, readwrite) BOOL isDragging;
@property (nonatomic, readwrite) CGPoint lastDragPoint;
@property (nonatomic, readwrite) CGPoint lastDisplacement;
@property (nonatomic, readwrite) NSTimeInterval lastDragTime;
@property (nonatomic, readwrite) NSTimeInterval lastDeltaTime;
@property (nonatomic, readwrite, retain) NSMutableArray *animations;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A plot space using a two-dimensional cartesian coordinate system.
 *
 *  The @ref xRange and @ref yRange determine the mapping between data coordinates
 *  and the screen coordinates in the plot area. The @quote{end} of a range is
 *  the location plus its length. Note that the length of a plot range can be negative, so
 *  the end point can have a lesser value than the starting location.
 *
 *  The global ranges constrain the values of the @ref xRange and @ref yRange.
 *  Whenever the global range is set (non-@nil), the corresponding plot
 *  range will be adjusted so that it fits in the global range. When a new
 *  range is set to the plot range, it will be adjusted as needed to fit
 *  in the global range. This is useful for constraining scrolling, for
 *  instance.
 **/
@implementation CPTXYPlotSpace

/** @property CPTPlotRange *xRange
 *  @brief The range of the x coordinate. Defaults to a range with @link CPTPlotRange::location location @endlink zero (@num{0})
 *  and a @link CPTPlotRange::length length @endlink of one (@num{1}).
 *
 *  The @link CPTPlotRange::location location @endlink of the @ref xRange
 *  defines the data coordinate associated with the left edge of the plot area.
 *  Similarly, the @link CPTPlotRange::end end @endlink of the @ref xRange
 *  defines the data coordinate associated with the right edge of the plot area.
 **/
@synthesize xRange;

/** @property CPTPlotRange *yRange
 *  @brief The range of the y coordinate. Defaults to a range with @link CPTPlotRange::location location @endlink zero (@num{0})
 *  and a @link CPTPlotRange::length length @endlink of one (@num{1}).
 *
 *  The @link CPTPlotRange::location location @endlink of the @ref yRange
 *  defines the data coordinate associated with the bottom edge of the plot area.
 *  Similarly, the @link CPTPlotRange::end end @endlink of the @ref yRange
 *  defines the data coordinate associated with the top edge of the plot area.
 **/
@synthesize yRange;

/** @property CPTPlotRange *globalXRange
 *  @brief The global range of the x coordinate to which the @ref xRange is constrained.
 *
 *  If non-@nil, the @ref xRange and any changes to it will
 *  be adjusted so that it always fits within the @ref globalXRange.
 *  If @nil (the default), there is no constraint on x.
 **/
@synthesize globalXRange;

/** @property CPTPlotRange *globalYRange
 *  @brief The global range of the y coordinate to which the @ref yRange is constrained.
 *
 *  If non-@nil, the @ref yRange and any changes to it will
 *  be adjusted so that it always fits within the @ref globalYRange.
 *  If @nil (the default), there is no constraint on y.
 **/
@synthesize globalYRange;

/** @property CPTScaleType xScaleType
 *  @brief The scale type of the x coordinate. Defaults to #CPTScaleTypeLinear.
 **/
@synthesize xScaleType;

/** @property CPTScaleType yScaleType
 *  @brief The scale type of the y coordinate. Defaults to #CPTScaleTypeLinear.
 **/
@synthesize yScaleType;

/** @property BOOL allowsMomentum
 *  @brief If @YES, plot space scrolling in any direction slows down gradually rather than stopping abruptly. Defaults to @NO.
 **/
@dynamic allowsMomentum;

/** @property BOOL allowsMomentumX
 *  @brief If @YES, plot space scrolling in the x-direction slows down gradually rather than stopping abruptly. Defaults to @NO.
 **/
@synthesize allowsMomentumX;

/** @property BOOL allowsMomentumY
 *  @brief If @YES, plot space scrolling in the y-direction slows down gradually rather than stopping abruptly. Defaults to @NO.
 **/
@synthesize allowsMomentumY;

/** @property CPTAnimationCurve momentumAnimationCurve
 *  @brief The animation curve used to stop the motion of the plot ranges when scrolling with momentum. Defaults to #CPTAnimationCurveQuadraticOut.
 **/
@synthesize momentumAnimationCurve;

/** @property CPTAnimationCurve bounceAnimationCurve
 *  @brief The animation curve used to return the plot range back to the global range after scrolling. Defaults to #CPTAnimationCurveQuadraticOut.
 **/
@synthesize bounceAnimationCurve;

/** @property CGFloat momentumAcceleration
 *  @brief Deceleration in pixels/second^2 for momentum scrolling. Defaults to @num{2000.0}.
 **/
@synthesize momentumAcceleration;

/** @property CGFloat bounceAcceleration
 *  @brief Bounce-back acceleration in pixels/second^2 when scrolled past the global range. Defaults to @num{3000.0}.
 **/
@synthesize bounceAcceleration;

@synthesize isDragging;
@synthesize lastDragPoint;
@synthesize lastDisplacement;
@synthesize lastDragTime;
@synthesize lastDeltaTime;
@synthesize animations;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTXYPlotSpace object.
 *
 *  The initialized object will have the following properties:
 *  - @ref xRange = [@num{0}, @num{1}]
 *  - @ref yRange = [@num{0}, @num{1}]
 *  - @ref globalXRange = @nil
 *  - @ref globalYRange = @nil
 *  - @ref xScaleType = #CPTScaleTypeLinear
 *  - @ref yScaleType = #CPTScaleTypeLinear
 *  - @ref allowsMomentum = @NO
 *  - @ref allowsMomentumX = @NO
 *  - @ref allowsMomentumY = @NO
 *  - @ref momentumAnimationCurve = #CPTAnimationCurveQuadraticOut
 *  - @ref bounceAnimationCurve = #CPTAnimationCurveQuadraticOut
 *  - @ref momentumAcceleration = @num{2000.0}
 *  - @ref bounceAcceleration = @num{3000.0}
 *
 *  @return The initialized object.
 **/
-(id)init
{
    if ( (self = [super init]) ) {
        xRange           = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(1)];
        yRange           = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(1)];
        globalXRange     = nil;
        globalYRange     = nil;
        xScaleType       = CPTScaleTypeLinear;
        yScaleType       = CPTScaleTypeLinear;
        lastDragPoint    = CGPointZero;
        lastDisplacement = CGPointZero;
        lastDragTime     = 0.0;
        lastDeltaTime    = 0.0;
        isDragging       = NO;
        animations       = [[NSMutableArray alloc] init];

        allowsMomentumX        = NO;
        allowsMomentumY        = NO;
        momentumAnimationCurve = CPTAnimationCurveQuadraticOut;
        bounceAnimationCurve   = CPTAnimationCurveQuadraticOut;
        momentumAcceleration   = 2000.0;
        bounceAcceleration     = 3000.0;
    }
    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    [xRange release];
    [yRange release];
    [globalXRange release];
    [globalYRange release];
    [animations release];

    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.xRange forKey:@"CPTXYPlotSpace.xRange"];
    [coder encodeObject:self.yRange forKey:@"CPTXYPlotSpace.yRange"];
    [coder encodeObject:self.globalXRange forKey:@"CPTXYPlotSpace.globalXRange"];
    [coder encodeObject:self.globalYRange forKey:@"CPTXYPlotSpace.globalYRange"];
    [coder encodeInt:self.xScaleType forKey:@"CPTXYPlotSpace.xScaleType"];
    [coder encodeInt:self.yScaleType forKey:@"CPTXYPlotSpace.yScaleType"];
    [coder encodeBool:self.allowsMomentumX forKey:@"CPTXYPlotSpace.allowsMomentumX"];
    [coder encodeBool:self.allowsMomentumY forKey:@"CPTXYPlotSpace.allowsMomentumY"];
    [coder encodeInt:self.momentumAnimationCurve forKey:@"CPTXYPlotSpace.momentumAnimationCurve"];
    [coder encodeInt:self.bounceAnimationCurve forKey:@"CPTXYPlotSpace.bounceAnimationCurve"];
    [coder encodeCGFloat:self.momentumAcceleration forKey:@"CPTXYPlotSpace.momentumAcceleration"];
    [coder encodeCGFloat:self.bounceAcceleration forKey:@"CPTXYPlotSpace.bounceAcceleration"];

    // No need to archive these properties:
    // lastDragPoint
    // lastDisplacement
    // lastDragTime
    // lastDeltaTime
    // isDragging
    // animations
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        xRange       = [[coder decodeObjectForKey:@"CPTXYPlotSpace.xRange"] copy];
        yRange       = [[coder decodeObjectForKey:@"CPTXYPlotSpace.yRange"] copy];
        globalXRange = [[coder decodeObjectForKey:@"CPTXYPlotSpace.globalXRange"] copy];
        globalYRange = [[coder decodeObjectForKey:@"CPTXYPlotSpace.globalYRange"] copy];
        xScaleType   = (CPTScaleType)[coder decodeIntForKey : @"CPTXYPlotSpace.xScaleType"];
        yScaleType   = (CPTScaleType)[coder decodeIntForKey : @"CPTXYPlotSpace.yScaleType"];

        if ( [coder containsValueForKey:@"CPTXYPlotSpace.allowsMomentum"] ) {
            self.allowsMomentum = [coder decodeBoolForKey:@"CPTXYPlotSpace.allowsMomentum"];
        }
        else {
            allowsMomentumX = [coder decodeBoolForKey:@"CPTXYPlotSpace.allowsMomentumX"];
            allowsMomentumY = [coder decodeBoolForKey:@"CPTXYPlotSpace.allowsMomentumY"];
        }
        momentumAnimationCurve = (CPTAnimationCurve)[coder decodeIntForKey : @"CPTXYPlotSpace.momentumAnimationCurve"];
        bounceAnimationCurve   = (CPTAnimationCurve)[coder decodeIntForKey : @"CPTXYPlotSpace.bounceAnimationCurve"];
        momentumAcceleration   = [coder decodeCGFloatForKey:@"CPTXYPlotSpace.momentumAcceleration"];
        bounceAcceleration     = [coder decodeCGFloatForKey:@"CPTXYPlotSpace.bounceAcceleration"];

        lastDragPoint    = CGPointZero;
        lastDisplacement = CGPointZero;
        lastDragTime     = 0.0;
        lastDeltaTime    = 0.0;
        isDragging       = NO;
        animations       = [[NSMutableArray alloc] init];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Ranges

/// @cond

-(void)setPlotRange:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    switch ( coordinate ) {
        case CPTCoordinateX:
            self.xRange = newRange;
            break;

        case CPTCoordinateY:
            self.yRange = newRange;
            break;

        default:
            // invalid coordinate--do nothing
            break;
    }
}

-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coordinate
{
    CPTPlotRange *theRange = nil;

    switch ( coordinate ) {
        case CPTCoordinateX:
            theRange = self.xRange;
            break;

        case CPTCoordinateY:
            theRange = self.yRange;
            break;

        default:
            // invalid coordinate
            break;
    }

    return theRange;
}

-(void)setScaleType:(CPTScaleType)newType forCoordinate:(CPTCoordinate)coordinate
{
    switch ( coordinate ) {
        case CPTCoordinateX:
            self.xScaleType = newType;
            break;

        case CPTCoordinateY:
            self.yScaleType = newType;
            break;

        default:
            // invalid coordinate--do nothing
            break;
    }
}

-(CPTScaleType)scaleTypeForCoordinate:(CPTCoordinate)coordinate
{
    CPTScaleType theScaleType = CPTScaleTypeLinear;

    switch ( coordinate ) {
        case CPTCoordinateX:
            theScaleType = self.xScaleType;
            break;

        case CPTCoordinateY:
            theScaleType = self.yScaleType;
            break;

        default:
            // invalid coordinate
            break;
    }

    return theScaleType;
}

-(void)setXRange:(CPTPlotRange *)range
{
    NSParameterAssert(range);

    if ( ![range isEqualToRange:xRange] ) {
        CPTPlotRange *constrainedRange;

        if ( self.allowsMomentumX ) {
            constrainedRange = range;
        }
        else {
            constrainedRange = [self constrainRange:range toGlobalRange:self.globalXRange];
        }

        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
        if ( [theDelegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
            constrainedRange = [theDelegate plotSpace:self willChangePlotRangeTo:constrainedRange forCoordinate:CPTCoordinateX];
        }

        if ( ![constrainedRange isEqualToRange:xRange] ) {
            [xRange release];
            xRange = [constrainedRange copy];

            [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                                object:self];

            if ( [theDelegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
                [theDelegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateX];
            }

            CPTGraph *theGraph = self.graph;
            if ( theGraph ) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                    object:theGraph];
            }
        }
    }
}

-(void)setYRange:(CPTPlotRange *)range
{
    NSParameterAssert(range);

    if ( ![range isEqualToRange:yRange] ) {
        CPTPlotRange *constrainedRange;

        if ( self.allowsMomentumY ) {
            constrainedRange = range;
        }
        else {
            constrainedRange = [self constrainRange:range toGlobalRange:self.globalYRange];
        }

        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
        if ( [theDelegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
            constrainedRange = [theDelegate plotSpace:self willChangePlotRangeTo:constrainedRange forCoordinate:CPTCoordinateY];
        }

        if ( ![constrainedRange isEqualToRange:yRange] ) {
            [yRange release];
            yRange = [constrainedRange copy];

            [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                                object:self];

            if ( [theDelegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
                [theDelegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateY];
            }

            CPTGraph *theGraph = self.graph;
            if ( theGraph ) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                    object:theGraph];
            }
        }
    }
}

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange
{
    if ( !globalRange ) {
        return existingRange;
    }
    if ( !existingRange ) {
        return nil;
    }

    if ( CPTDecimalGreaterThanOrEqualTo(existingRange.length, globalRange.length) ) {
        return [[globalRange copy] autorelease];
    }
    else {
        CPTMutablePlotRange *newRange = [[existingRange mutableCopy] autorelease];
        [newRange shiftEndToFitInRange:globalRange];
        [newRange shiftLocationToFitInRange:globalRange];
        return newRange;
    }
}

-(void)animateRangeForCoordinate:(CPTCoordinate)coordinate shift:(NSDecimal)shift momentumTime:(CGFloat)momentumTime speed:(CGFloat)speed acceleration:(CGFloat)acceleration
{
    NSMutableArray *animationArray = self.animations;
    CPTAnimationOperation *op;

    NSString *property        = nil;
    CPTPlotRange *oldRange    = nil;
    CPTPlotRange *globalRange = nil;

    switch ( coordinate ) {
        case CPTCoordinateX:
            property    = @"xRange";
            oldRange    = self.xRange;
            globalRange = self.globalXRange;
            break;

        case CPTCoordinateY:
            property    = @"yRange";
            oldRange    = self.yRange;
            globalRange = self.globalYRange;
            break;

        default:
            break;
    }

    CPTMutablePlotRange *newRange = [oldRange mutableCopy];

    CGFloat bounceDelay = CPTFloat(0.0);
    NSDecimal zero      = CPTDecimalFromInteger(0);
    BOOL hasShift       = !CPTDecimalEquals(shift, zero);

    if ( hasShift ) {
        newRange.location = CPTDecimalAdd(newRange.location, shift);

        op = [CPTAnimation animate:self
                          property:property
                     fromPlotRange:oldRange
                       toPlotRange:newRange
                          duration:momentumTime
                    animationCurve:self.momentumAnimationCurve
                          delegate:self];
        [animationArray addObject:op];

        bounceDelay = momentumTime;
    }

    if ( globalRange ) {
        CPTPlotRange *constrainedRange = [self constrainRange:newRange toGlobalRange:globalRange];

        if ( ![newRange isEqualToRange:constrainedRange] && ![globalRange containsRange:newRange] ) {
            BOOL direction = ( CPTDecimalGreaterThan(shift, zero) && CPTDecimalGreaterThan(oldRange.length, zero) ) ||
                             ( CPTDecimalLessThan(shift, zero) && CPTDecimalLessThan(oldRange.length, zero) );

            // decelerate at the global range
            if ( hasShift ) {
                CGFloat brakingDelay = CPTFloat(NAN);

                if ( [globalRange containsRange:oldRange] ) {
                    // momentum started inside the global range; coast until we hit the global range
                    CGFloat globalPoint = [self viewCoordinateForRange:globalRange coordinate:coordinate direction:direction];
                    CGFloat oldPoint    = [self viewCoordinateForRange:oldRange coordinate:coordinate direction:direction];

                    CGFloat brakingOffset = globalPoint - oldPoint;
                    brakingDelay = firstPositiveRoot(acceleration, speed, brakingOffset);

                    if ( !isnan(brakingDelay) ) {
                        speed -= brakingDelay * acceleration;

                        // slow down quickly
                        while ( momentumTime > CPTFloat(0.1) ) {
                            acceleration *= CPTFloat(2.0);
                            momentumTime  = speed / (CPTFloat(2.0) * acceleration);
                        }

                        CGFloat distanceTraveled = speed * momentumTime - CPTFloat(0.5) * acceleration * momentumTime * momentumTime;
                        CGFloat brakingLength    = globalPoint - distanceTraveled;

                        CGPoint brakingPoint = CGPointZero;
                        switch ( coordinate ) {
                            case CPTCoordinateX:
                                brakingPoint = CPTPointMake(brakingLength, 0.0);
                                break;

                            case CPTCoordinateY:
                                brakingPoint = CPTPointMake(0.0, brakingLength);
                                break;

                            default:
                                break;
                        }

                        NSDecimal newPoint[2];
                        [self plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:brakingPoint];

                        NSDecimal brakingShift = CPTDecimalSubtract(newPoint[coordinate], direction ? globalRange.end : globalRange.location);

                        [newRange shiftEndToFitInRange:globalRange];
                        [newRange shiftLocationToFitInRange:globalRange];
                        newRange.location = CPTDecimalAdd(newRange.location, brakingShift);
                    }
                }
                else {
                    // momentum started outside the global range
                    brakingDelay = CPTFloat(0.0);

                    // slow down quickly
                    while ( momentumTime > CPTFloat(0.1) ) {
                        momentumTime *= CPTFloat(0.5);

                        shift = CPTDecimalDivide( shift, CPTDecimalFromInteger(2) );
                    }

                    [newRange release];
                    newRange = [oldRange mutableCopy];

                    newRange.location = CPTDecimalAdd(newRange.location, shift);
                }

                if ( !isnan(brakingDelay) ) {
                    op = [CPTAnimation animate:self
                                      property:property
                                 fromPlotRange:constrainedRange
                                   toPlotRange:newRange
                                      duration:momentumTime
                                     withDelay:brakingDelay
                                animationCurve:self.momentumAnimationCurve
                                      delegate:self];
                    [animationArray addObject:op];

                    bounceDelay = momentumTime + brakingDelay;
                }
            }

            // bounce back to the global range
            CGFloat newPoint         = [self viewCoordinateForRange:newRange coordinate:coordinate direction:!direction];
            CGFloat constrainedPoint = [self viewCoordinateForRange:constrainedRange coordinate:coordinate direction:!direction];

            CGFloat offset = constrainedPoint - newPoint;

            CGFloat bounceTime = sqrt(ABS(offset) / self.bounceAcceleration);

            op = [CPTAnimation animate:self
                              property:property
                         fromPlotRange:newRange
                           toPlotRange:constrainedRange
                              duration:bounceTime
                             withDelay:bounceDelay
                        animationCurve:self.bounceAnimationCurve
                              delegate:self];
            [animationArray addObject:op];
        }
    }

    [newRange release];
}

-(CGFloat)viewCoordinateForRange:(CPTPlotRange *)range coordinate:(CPTCoordinate)coordinate direction:(BOOL)direction
{
    CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(coordinate);

    NSDecimal point[2];

    point[coordinate]           = (direction ? range.maxLimit : range.minLimit);
    point[orthogonalCoordinate] = CPTDecimalFromInteger(1);

    CGPoint viewPoint = [self plotAreaViewPointForPlotPoint:point numberOfCoordinates:2];

    switch ( coordinate ) {
        case CPTCoordinateX:
            return viewPoint.x;

            break;

        case CPTCoordinateY:
            return viewPoint.y;

            break;

        default:
            return CPTFloat(NAN);

            break;
    }
}

// return NAN if no positive roots
CGFloat firstPositiveRoot(CGFloat a, CGFloat b, CGFloat c)
{
    CGFloat root = CPTFloat(NAN);

    CGFloat discriminant = sqrt(b * b - CPTFloat(4.0) * a * c);

    CGFloat root1 = (-b + discriminant) / (CPTFloat(2.0) * a);
    CGFloat root2 = (-b - discriminant) / (CPTFloat(2.0) * a);

    if ( !isnan(root1) && !isnan(root2) ) {
        if ( root1 >= CPTFloat(0.0) ) {
            root = root1;
        }
        if ( ( root2 >= CPTFloat(0.0) ) && ( isnan(root) || (root2 < root) ) ) {
            root = root2;
        }
    }

    return root;
}

-(void)setGlobalXRange:(CPTPlotRange *)newRange
{
    if ( ![newRange isEqualToRange:globalXRange] ) {
        [globalXRange release];
        globalXRange = [newRange copy];
        self.xRange  = [self constrainRange:self.xRange toGlobalRange:globalXRange];
    }
}

-(void)setGlobalYRange:(CPTPlotRange *)newRange
{
    if ( ![newRange isEqualToRange:globalYRange] ) {
        [globalYRange release];
        globalYRange = [newRange copy];
        self.yRange  = [self constrainRange:self.yRange toGlobalRange:globalYRange];
    }
}

-(void)scaleToFitPlots:(NSArray *)plots
{
    if ( plots.count == 0 ) {
        return;
    }

    // Determine union of ranges
    CPTMutablePlotRange *unionXRange = nil;
    CPTMutablePlotRange *unionYRange = nil;
    for ( CPTPlot *plot in plots ) {
        CPTPlotRange *currentXRange = [plot plotRangeForCoordinate:CPTCoordinateX];
        CPTPlotRange *currentYRange = [plot plotRangeForCoordinate:CPTCoordinateY];
        if ( !unionXRange ) {
            unionXRange = [currentXRange mutableCopy];
        }
        if ( !unionYRange ) {
            unionYRange = [currentYRange mutableCopy];
        }
        [unionXRange unionPlotRange:currentXRange];
        [unionYRange unionPlotRange:currentYRange];
    }

    // Set range
    NSDecimal zero = CPTDecimalFromInteger(0);
    if ( unionXRange ) {
        if ( CPTDecimalEquals(unionXRange.length, zero) ) {
            [unionXRange unionPlotRange:self.xRange];
        }
        self.xRange = unionXRange;
    }
    if ( unionYRange ) {
        if ( CPTDecimalEquals(unionYRange.length, zero) ) {
            [unionYRange unionPlotRange:self.yRange];
        }
        self.yRange = unionYRange;
    }

    [unionXRange release];
    [unionYRange release];
}

-(void)setXScaleType:(CPTScaleType)newScaleType
{
    if ( newScaleType != xScaleType ) {
        xScaleType = newScaleType;

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];

        CPTGraph *theGraph = self.graph;
        if ( theGraph ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                object:theGraph];
        }
    }
}

-(void)setYScaleType:(CPTScaleType)newScaleType
{
    if ( newScaleType != yScaleType ) {
        yScaleType = newScaleType;

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];
        CPTGraph *theGraph = self.graph;
        if ( theGraph ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                object:theGraph];
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Point Conversion (private utilities)

/// @cond

// Linear
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord
{
    if ( !range ) {
        return CPTFloat(0.0);
    }

    NSDecimal factor = CPTDecimalDivide(CPTDecimalSubtract(plotCoord, range.location), range.length);
    if ( NSDecimalIsNotANumber(&factor) ) {
        factor = CPTDecimalFromInteger(0);
    }

    NSDecimal viewCoordinate = CPTDecimalMultiply(CPTDecimalFromCGFloat(viewLength), factor);

    return CPTDecimalCGFloatValue(viewCoordinate);
}

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord
{
    if ( !range || (range.lengthDouble == 0.0) ) {
        return CPTFloat(0.0);
    }
    return viewLength * (CGFloat)( (plotCoord - range.locationDouble) / range.lengthDouble );
}

-(NSDecimal)plotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
    if ( boundsLength == 0.0 ) {
        return CPTDecimalFromInteger(0);
    }

    NSDecimal vLength = CPTDecimalFromDouble(viewLength);
    NSDecimal bLength = CPTDecimalFromDouble(boundsLength);

    NSDecimal location = range.location;
    NSDecimal length   = range.length;

    NSDecimal coordinate;
    NSDecimalDivide(&coordinate, &vLength, &bLength, NSRoundPlain);
    NSDecimalMultiply(&coordinate, &coordinate, &(length), NSRoundPlain);
    NSDecimalAdd(&coordinate, &coordinate, &(location), NSRoundPlain);

    return coordinate;
}

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
    if ( boundsLength == 0.0 ) {
        return 0.0;
    }

    double coordinate = viewLength / boundsLength;
    coordinate *= range.lengthDouble;
    coordinate += range.locationDouble;

    return coordinate;
}

// Log (only one version since there are no transcendental functions for NSDecimal)
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord
{
    if ( (range.minLimitDouble <= 0.0) || (range.maxLimitDouble <= 0.0) || (plotCoord <= 0.0) ) {
        return CPTFloat(0.0);
    }

    double logLoc   = log10(range.locationDouble);
    double logCoord = log10(plotCoord);
    double logEnd   = log10(range.endDouble);

    return viewLength * (CGFloat)( (logCoord - logLoc) / (logEnd - logLoc) );
}

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
    if ( boundsLength == 0.0 ) {
        return 0.0;
    }

    double logLoc = log10(range.locationDouble);
    double logEnd = log10(range.endDouble);

    double coordinate = viewLength * (logEnd - logLoc) / boundsLength + logLoc;

    return pow(10.0, coordinate);
}

/// @endcond

#pragma mark -
#pragma mark Point Conversion

/// @cond

-(NSUInteger)numberOfCoordinates
{
    return 2;
}

// Plot area view point for plot point
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count
{
    CGPoint viewPoint = [super plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:count];

    CGSize layerSize;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return viewPoint;
    }

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange plotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        case CPTScaleTypeLog:
        {
            double x = CPTDecimalDoubleValue(plotPoint[CPTCoordinateX]);
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:x];
        }
        break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange plotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        case CPTScaleTypeLog:
        {
            double y = CPTDecimalDoubleValue(plotPoint[CPTCoordinateY]);
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:y];
        }
        break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    return viewPoint;
}

-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count
{
    CGPoint viewPoint = [super plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:count];

    CGSize layerSize;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return viewPoint;
    }

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        case CPTScaleTypeLog:
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        case CPTScaleTypeLog:
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    return viewPoint;
}

// Plot point for view point
-(void)plotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point
{
    [super plotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:point];

    CGSize boundsSize;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        boundsSize = plotArea.bounds.size;
    }
    else {
        NSDecimal zero = CPTDecimalFromInteger(0);
        plotPoint[CPTCoordinateX] = zero;
        plotPoint[CPTCoordinateY] = zero;
        return;
    }

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            plotPoint[CPTCoordinateX] = [self plotCoordinateForViewLength:point.x linearPlotRange:self.xRange boundsLength:boundsSize.width];
            break;

        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateX] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.xRange boundsLength:boundsSize.width]);
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            plotPoint[CPTCoordinateY] = [self plotCoordinateForViewLength:point.y linearPlotRange:self.yRange boundsLength:boundsSize.height];
            break;

        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateY] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.yRange boundsLength:boundsSize.height]);
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }
}

-(void)doublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point
{
    [super doublePrecisionPlotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:point];

    CGSize boundsSize;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        boundsSize = plotArea.bounds.size;
    }
    else {
        plotPoint[CPTCoordinateX] = 0.0;
        plotPoint[CPTCoordinateY] = 0.0;
        return;
    }

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x linearPlotRange:self.xRange boundsLength:boundsSize.width];
            break;

        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.xRange boundsLength:boundsSize.width];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y linearPlotRange:self.yRange boundsLength:boundsSize.height];
            break;

        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.yRange boundsLength:boundsSize.height];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }
}

// Plot area view point for event
-(CGPoint)plotAreaViewPointForEvent:(CPTNativeEvent *)event
{
    CGPoint plotAreaViewPoint = CGPointZero;

    CPTGraph *theGraph                  = self.graph;
    CPTGraphHostingView *theHostingView = theGraph.hostingView;
    CPTPlotArea *thePlotArea            = theGraph.plotAreaFrame.plotArea;

    if ( theHostingView && thePlotArea ) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGPoint interactionPoint = [[[event touchesForView:theHostingView] anyObject] locationInView:theHostingView];
        if ( theHostingView.collapsesLayers ) {
            interactionPoint.y = theHostingView.frame.size.height - interactionPoint.y;
            plotAreaViewPoint  = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        }
        else {
            plotAreaViewPoint = [theHostingView.layer convertPoint:interactionPoint toLayer:thePlotArea];
        }
#else
        CGPoint interactionPoint = NSPointToCGPoint([theHostingView convertPoint:[event locationInWindow] fromView:nil]);
        plotAreaViewPoint = [theHostingView.layer convertPoint:interactionPoint toLayer:thePlotArea];
#endif
    }

    return plotAreaViewPoint;
}

// Plot point for event
-(void)plotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(CPTNativeEvent *)event
{
    [self plotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
}

-(void)doublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(CPTNativeEvent *)event
{
    [self doublePrecisionPlotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
}

/// @endcond

#pragma mark -
#pragma mark Scaling

/// @cond

-(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)plotAreaPoint
{
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( !plotArea || (interactionScale <= 1.e-6) ) {
        return;
    }
    if ( ![plotArea containsPoint:plotAreaPoint] ) {
        return;
    }

    // Ask the delegate if it is OK
    id<CPTPlotSpaceDelegate> theDelegate = self.delegate;

    BOOL shouldScale = YES;
    if ( [theDelegate respondsToSelector:@selector(plotSpace:shouldScaleBy:aboutPoint:)] ) {
        shouldScale = [theDelegate plotSpace:self shouldScaleBy:interactionScale aboutPoint:plotAreaPoint];
    }
    if ( !shouldScale ) {
        return;
    }

    // Determine point in plot coordinates
    NSDecimal const decimalScale = CPTDecimalFromCGFloat(interactionScale);
    NSDecimal plotInteractionPoint[2];
    [self plotPoint:plotInteractionPoint numberOfCoordinates:2 forPlotAreaViewPoint:plotAreaPoint];

    // Cache old ranges
    CPTPlotRange *oldRangeX = self.xRange;
    CPTPlotRange *oldRangeY = self.yRange;

    // Lengths are scaled by the pinch gesture inverse proportional
    NSDecimal newLengthX = CPTDecimalDivide(oldRangeX.length, decimalScale);
    NSDecimal newLengthY = CPTDecimalDivide(oldRangeY.length, decimalScale);

    // New locations
    NSDecimal newLocationX;
    if ( CPTDecimalGreaterThanOrEqualTo( oldRangeX.length, CPTDecimalFromInteger(0) ) ) {
        NSDecimal oldFirstLengthX = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateX], oldRangeX.minLimit); // x - minX
        NSDecimal newFirstLengthX = CPTDecimalDivide(oldFirstLengthX, decimalScale);                              // (x - minX) / scale
        newLocationX = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateX], newFirstLengthX);
    }
    else {
        NSDecimal oldSecondLengthX = CPTDecimalSubtract(oldRangeX.maxLimit, plotInteractionPoint[0]); // maxX - x
        NSDecimal newSecondLengthX = CPTDecimalDivide(oldSecondLengthX, decimalScale);                // (maxX - x) / scale
        newLocationX = CPTDecimalAdd(plotInteractionPoint[CPTCoordinateX], newSecondLengthX);
    }

    NSDecimal newLocationY;
    if ( CPTDecimalGreaterThanOrEqualTo( oldRangeY.length, CPTDecimalFromInteger(0) ) ) {
        NSDecimal oldFirstLengthY = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateY], oldRangeY.minLimit); // y - minY
        NSDecimal newFirstLengthY = CPTDecimalDivide(oldFirstLengthY, decimalScale);                              // (y - minY) / scale
        newLocationY = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateY], newFirstLengthY);
    }
    else {
        NSDecimal oldSecondLengthY = CPTDecimalSubtract(oldRangeY.maxLimit, plotInteractionPoint[1]); // maxY - y
        NSDecimal newSecondLengthY = CPTDecimalDivide(oldSecondLengthY, decimalScale);                // (maxY - y) / scale
        newLocationY = CPTDecimalAdd(plotInteractionPoint[CPTCoordinateY], newSecondLengthY);
    }

    // New ranges
    CPTPlotRange *newRangeX = [[[CPTPlotRange alloc] initWithLocation:newLocationX length:newLengthX] autorelease];
    CPTPlotRange *newRangeY = [[[CPTPlotRange alloc] initWithLocation:newLocationY length:newLengthY] autorelease];

    BOOL oldMomentum = self.allowsMomentumX;
    self.allowsMomentumX = NO;
    self.xRange          = newRangeX;
    self.allowsMomentumX = oldMomentum;

    oldMomentum          = self.allowsMomentumY;
    self.allowsMomentumY = NO;
    self.yRange          = newRangeY;
    self.allowsMomentumY = oldMomentum;
}

/// @endcond

#pragma mark -
#pragma mark Interaction

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly touched the screen. @endif
 *
 *
 *  If the receiver has a @ref delegate and the delegate handles the event,
 *  this method always returns @YES.
 *  If @ref allowsUserInteraction is @NO
 *  or the graph does not have a @link CPTPlotAreaFrame::plotArea plotArea @endlink layer,
 *  this method always returns @NO.
 *  Otherwise, if the @par{interactionPoint} is within the bounds of the
 *  @link CPTPlotAreaFrame::plotArea plotArea @endlink, a drag operation starts and
 *  this method returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = [super pointingDeviceDownEvent:event atPoint:interactionPoint];

    if ( handledByDelegate ) {
        self.isDragging = NO;
        return YES;
    }

    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;
    if ( !self.allowsUserInteraction || !plotArea ) {
        return NO;
    }

    CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:plotArea];
    if ( [plotArea containsPoint:pointInPlotArea] ) {
        // Handle event
        self.lastDragPoint    = pointInPlotArea;
        self.lastDisplacement = CGPointZero;
        self.lastDragTime     = event.timestamp;
        self.lastDeltaTime    = 0.0;
        self.isDragging       = YES;

        // Clear any previous animations
        NSMutableArray *animationArray = self.animations;
        for ( CPTAnimationOperation *op in animationArray ) {
            [[CPTAnimation sharedInstance] removeAnimationOperation:op];
        }
        [animationArray removeAllObjects];

        return YES;
    }

    return NO;
}

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly released the mouse button. @endif
 *  @if iOSOnly lifted their finger off the screen. @endif
 *
 *
 *  If the receiver has a @ref delegate and the delegate handles the event,
 *  this method always returns @YES.
 *  If @ref allowsUserInteraction is @NO
 *  or the graph does not have a @link CPTPlotAreaFrame::plotArea plotArea @endlink layer,
 *  this method always returns @NO.
 *  Otherwise, if a drag operation is in progress, it ends and
 *  this method returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = [super pointingDeviceUpEvent:event atPoint:interactionPoint];

    if ( handledByDelegate ) {
        return YES;
    }

    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;
    if ( !self.allowsUserInteraction || !plotArea ) {
        return NO;
    }

    if ( self.isDragging ) {
        self.isDragging = NO;

        CGFloat acceleration = CPTFloat(0.0);
        CGFloat speed        = CPTFloat(0.0);
        CGFloat momentumTime = CPTFloat(0.0);

        NSDecimal shiftX = CPTDecimalFromInteger(0);
        NSDecimal shiftY = CPTDecimalFromInteger(0);

        CGFloat scaleX = CPTFloat(0.0);
        CGFloat scaleY = CPTFloat(0.0);

        if ( self.allowsMomentum ) {
            NSTimeInterval deltaT     = event.timestamp - self.lastDragTime;
            NSTimeInterval lastDeltaT = self.lastDeltaTime;

            if ( (deltaT > 0.0) && (deltaT < 0.05) && (lastDeltaT > 0.0) ) {
                CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:plotArea];
                CGPoint displacement    = self.lastDisplacement;

                acceleration = self.momentumAcceleration;
                speed        = sqrt(displacement.x * displacement.x + displacement.y * displacement.y) / CPTFloat(lastDeltaT);
                momentumTime = speed / (CPTFloat(2.0) * acceleration);
                CGFloat distanceTraveled = speed * momentumTime - CPTFloat(0.5) * acceleration * momentumTime * momentumTime;
                distanceTraveled = MAX( distanceTraveled, CPTFloat(0.0) );

                CGFloat theta = atan2(displacement.y, displacement.x);
                scaleX = cos(theta);
                scaleY = sin(theta);

                NSDecimal lastPoint[2], newPoint[2];
                [self plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointInPlotArea];
                [self plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:CGPointMake(pointInPlotArea.x + distanceTraveled * scaleX,
                                                                                                pointInPlotArea.y + distanceTraveled * scaleY)];

                if ( self.allowsMomentumX ) {
                    shiftX = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
                }
                if ( self.allowsMomentumY ) {
                    shiftY = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
                }
            }
        }

        // X range
        [self animateRangeForCoordinate:CPTCoordinateX
                                  shift:shiftX
                           momentumTime:momentumTime
                                  speed:speed * scaleX
                           acceleration:acceleration * scaleX];

        // Y range
        [self animateRangeForCoordinate:CPTCoordinateY
                                  shift:shiftY
                           momentumTime:momentumTime
                                  speed:speed * scaleY
                           acceleration:acceleration * scaleY];

        return YES;
    }

    return NO;
}

/**
 *  @brief Informs the receiver that the user has moved
 *  @if MacOnly the mouse with the button pressed. @endif
 *  @if iOSOnly their finger while touching the screen. @endif
 *
 *
 *  If the receiver has a @ref delegate and the delegate handles the event,
 *  this method always returns @YES.
 *  If @ref allowsUserInteraction is @NO
 *  or the graph does not have a @link CPTPlotAreaFrame::plotArea plotArea @endlink layer,
 *  this method always returns @NO.
 *  Otherwise, if a drag operation is in progress, the @ref xRange
 *  and @ref yRange are shifted to follow the drag and
 *  this method returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];

    if ( handledByDelegate ) {
        return YES;
    }

    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;
    if ( !self.allowsUserInteraction || !plotArea ) {
        return NO;
    }

    if ( self.isDragging ) {
        CGPoint lastDraggedPoint = self.lastDragPoint;

        CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:plotArea];
        CGPoint displacement    = CPTPointMake(pointInPlotArea.x - lastDraggedPoint.x, pointInPlotArea.y - lastDraggedPoint.y);
        CGPoint pointToUse      = pointInPlotArea;

        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;

        // Allow delegate to override
        if ( [theDelegate respondsToSelector:@selector(plotSpace:willDisplaceBy:)] ) {
            displacement = [theDelegate plotSpace:self willDisplaceBy:displacement];
            pointToUse   = CPTPointMake(lastDraggedPoint.x + displacement.x, lastDraggedPoint.y + displacement.y);
        }

        NSDecimal lastPoint[2], newPoint[2];
        [self plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:lastDraggedPoint];
        [self plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointToUse];

        // X range
        NSDecimal shiftX        = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
        CPTPlotRange *newRangeX = [self shiftRange:self.xRange
                                                 by:shiftX
                                      usingMomentum:self.allowsMomentumX
                                      inGlobalRange:self.globalXRange
                                   withDisplacement:&displacement.x];

        // Y range
        NSDecimal shiftY        = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
        CPTPlotRange *newRangeY = [self shiftRange:self.yRange
                                                 by:shiftY
                                      usingMomentum:self.allowsMomentumY
                                      inGlobalRange:self.globalYRange
                                   withDisplacement:&displacement.y];

        self.xRange = newRangeX;
        self.yRange = newRangeY;

        self.lastDragPoint    = pointInPlotArea;
        self.lastDisplacement = displacement;

        NSTimeInterval currentTime = event.timestamp;
        self.lastDeltaTime = currentTime - self.lastDragTime;
        self.lastDragTime  = currentTime;

        return YES;
    }

    return NO;
}

-(CPTPlotRange *)shiftRange:(CPTPlotRange *)oldRange by:(NSDecimal)shift usingMomentum:(BOOL)momentum inGlobalRange:(CPTPlotRange *)globalRange withDisplacement:(CGFloat *)displacement
{
    CPTMutablePlotRange *newRange = [oldRange mutableCopy];

    newRange.location = CPTDecimalAdd(newRange.location, shift);

    if ( globalRange ) {
        CPTPlotRange *constrainedRange = [self constrainRange:newRange toGlobalRange:globalRange];

        if ( momentum ) {
            if ( ![newRange isEqualToRange:constrainedRange] ) {
                // reduce the shift as we get farther outside the global range
                NSDecimal rangeLength = newRange.length;

                if ( !CPTDecimalEquals( rangeLength, CPTDecimalFromInteger(0) ) ) {
                    NSDecimal diff = CPTDecimalDivide(CPTDecimalSubtract(constrainedRange.location, newRange.location), rangeLength);
                    diff = CPTDecimalMax( CPTDecimalMin( CPTDecimalMultiply( diff, CPTDecimalFromDouble(2.5) ), CPTDecimalFromInteger(1) ), CPTDecimalFromInteger(-1) );

                    newRange.location = CPTDecimalSubtract( newRange.location, CPTDecimalMultiply( shift, CPTDecimalAbs(diff) ) );

                    *displacement = *displacement * ( CPTFloat(1.0) - ABS( CPTDecimalCGFloatValue(diff) ) );
                }
            }
        }
        else {
            [constrainedRange retain];
            [newRange release];
            newRange = (CPTMutablePlotRange *)constrainedRange;
        }
    }

    return [newRange autorelease];
}

/// @}

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setAllowsMomentum:(BOOL)newMomentum
{
    self.allowsMomentumX = newMomentum;
    self.allowsMomentumY = newMomentum;
}

-(BOOL)allowsMomentum
{
    return self.allowsMomentumX || self.allowsMomentumY;
}

/// @endcond

#pragma mark -
#pragma mark Animation Delegate

/// @cond

-(void)animationDidFinish:(CPTAnimationOperation *)operation
{
    [self.animations removeObjectIdenticalTo:operation];
}

/// @endcond

@end
