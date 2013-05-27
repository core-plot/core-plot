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
#import <tgmath.h>

static const CGFloat kCPTMomentumTime = CPTFloat(0.25); // Deceleration time in seconds for momentum scrolling
static const CGFloat kCPTBounceTime   = CPTFloat(0.5);  // Bounce-back time in seconds when scrolled past the global range

/// @cond
@interface CPTXYPlotSpace()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(NSDecimal)plotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;
-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange;
-(void)animateRange:(CPTPlotRange *)oldRange property:(NSString *)property globalRange:(CPTPlotRange *)globalRange shift:(NSDecimal)shift;
-(CPTPlotRange *)shiftRange:(CPTPlotRange *)oldRange by:(NSDecimal)shift inGlobalRange:(CPTPlotRange *)globalRange elastic:(BOOL)elastic withDisplacement:(CGFloat *)displacement;

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
 *  @brief If @YES, plot space scrolling slows down gradually rather than stopping abruptly. Defaults to @NO.
 **/
@synthesize allowsMomentum;

/** @property BOOL elasticGlobalXRange
 *  @brief If @YES, the plot space can scroll beyond the bounds set by the @ref globalXRange,
 *  and will bounce back to the @ref globalXRange when released. Defaults to @NO.
 **/
@synthesize elasticGlobalXRange;

/** @property BOOL elasticGlobalYRange
 *  @brief If @YES, the plot space can scroll beyond the bounds set by the @ref globalYRange,
 *  and will bounce back to the @ref globalYRange when released. Defaults to @NO.
 **/
@synthesize elasticGlobalYRange;

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
 *  - @ref elasticGlobalXRange = @NO
 *  - @ref elasticGlobalYRange = @NO
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

        allowsMomentum      = NO;
        elasticGlobalXRange = NO;
        elasticGlobalYRange = NO;
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
    [coder encodeBool:self.allowsMomentum forKey:@"CPTXYPlotSpace.allowsMomentum"];
    [coder encodeBool:self.elasticGlobalXRange forKey:@"CPTXYPlotSpace.elasticGlobalXRange"];
    [coder encodeBool:self.elasticGlobalYRange forKey:@"CPTXYPlotSpace.elasticGlobalYRange"];

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

        allowsMomentum      = [coder decodeBoolForKey:@"CPTXYPlotSpace.allowsMomentum"];
        elasticGlobalXRange = [coder decodeBoolForKey:@"CPTXYPlotSpace.elasticGlobalXRange"];
        elasticGlobalYRange = [coder decodeBoolForKey:@"CPTXYPlotSpace.elasticGlobalYRange"];

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

        if ( self.elasticGlobalXRange ) {
            constrainedRange = range;
        }
        else {
            constrainedRange = [self constrainRange:range toGlobalRange:self.globalXRange];
        }

        [xRange release];
        xRange = [constrainedRange copy];

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];

        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
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

-(void)setYRange:(CPTPlotRange *)range
{
    NSParameterAssert(range);

    if ( ![range isEqualToRange:yRange] ) {
        CPTPlotRange *constrainedRange;

        if ( self.elasticGlobalYRange ) {
            constrainedRange = range;
        }
        else {
            constrainedRange = [self constrainRange:range toGlobalRange:self.globalYRange];
        }

        [yRange release];
        yRange = [constrainedRange copy];

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];

        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
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

-(void)animateRange:(CPTPlotRange *)oldRange property:(NSString *)property globalRange:(CPTPlotRange *)globalRange shift:(NSDecimal)shift
{
    NSMutableArray *animationArray = self.animations;
    CPTAnimationOperation *op;

    CPTMutablePlotRange *newRange = [oldRange mutableCopy];

    BOOL hasShift = !CPTDecimalEquals( shift, CPTDecimalFromInteger(0) );

    if ( hasShift ) {
        newRange.location = CPTDecimalAdd(newRange.location, shift);

        op = [CPTAnimation animate:self
                          property:property
                     fromPlotRange:oldRange
                       toPlotRange:newRange
                          duration:kCPTMomentumTime
                    animationCurve:CPTAnimationCurveQuadraticOut
                          delegate:nil];
        [animationArray addObject:op];
    }

    if ( globalRange ) {
        CPTPlotRange *constrainedRange = [self constrainRange:newRange toGlobalRange:globalRange];

        if ( ![newRange isEqualToRange:constrainedRange] ) {
            op = [CPTAnimation animate:self
                              property:property
                         fromPlotRange:newRange
                           toPlotRange:constrainedRange
                              duration:kCPTBounceTime
                             withDelay:(hasShift ? kCPTMomentumTime:0.0)
                        animationCurve:CPTAnimationCurveElasticOut
                              delegate:nil];
            [animationArray addObject:op];
        }
    }
    [newRange release];
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

    CGFloat viewCoordinate = viewLength * CPTDecimalCGFloatValue(factor);

    return viewCoordinate;
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

// Plot area view point for plot point
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint
{
    CGSize layerSize;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return CGPointZero;
    }

    CGFloat viewX;
    CGFloat viewY;

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear :
            viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange plotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        case CPTScaleTypeLog:
        {
            double x = CPTDecimalDoubleValue(plotPoint[CPTCoordinateX]);
            viewX = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:x];
        }
        break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange plotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        case CPTScaleTypeLog:
        {
            double y = CPTDecimalDoubleValue(plotPoint[CPTCoordinateY]);
            viewY = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:y];
        }
        break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    return CPTPointMake(viewX, viewY);
}

-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint
{
    CGSize layerSize;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return CGPointZero;
    }

    CGFloat viewX;
    CGFloat viewY;

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        case CPTScaleTypeLog:
            viewX = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        case CPTScaleTypeLog:
            viewY = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    return CPTPointMake(viewX, viewY);
}

// Plot point for view point
-(void)plotPoint:(NSDecimal *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
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

-(void)doublePrecisionPlotPoint:(double *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
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
            plotAreaViewPoint.x = interactionPoint.x;
            plotAreaViewPoint.y = theHostingView.frame.size.height - interactionPoint.y;
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
-(void)plotPoint:(NSDecimal *)plotPoint forEvent:(CPTNativeEvent *)event
{
    [self plotPoint:plotPoint forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
}

-(void)doublePrecisionPlotPoint:(double *)plotPoint forEvent:(CPTNativeEvent *)event
{
    [self doublePrecisionPlotPoint:plotPoint forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
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
    [self plotPoint:plotInteractionPoint forPlotAreaViewPoint:plotAreaPoint];

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

    // Delegate may still veto/modify the range
    if ( [theDelegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
        newRangeX = [theDelegate plotSpace:self willChangePlotRangeTo:newRangeX forCoordinate:CPTCoordinateX];
        newRangeY = [theDelegate plotSpace:self willChangePlotRangeTo:newRangeY forCoordinate:CPTCoordinateY];
    }

    BOOL oldElasticGlobalXRange = self.elasticGlobalXRange;
    BOOL oldElasticGlobalYRange = self.elasticGlobalYRange;
    self.elasticGlobalXRange = NO;
    self.elasticGlobalYRange = NO;

    self.xRange = newRangeX;
    self.yRange = newRangeY;

    self.elasticGlobalXRange = oldElasticGlobalXRange;
    self.elasticGlobalYRange = oldElasticGlobalYRange;
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
        for ( CPTAnimationOperation *op in self.animations ) {
            [[CPTAnimation sharedInstance] removeAnimationOperation:op];
        }

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

        if ( self.allowsMomentum ) {
            NSTimeInterval deltaT = event.timestamp - self.lastDragTime;
            if ( deltaT > 0.0 ) {
                CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:plotArea];
                CGPoint displacement    = self.lastDisplacement;

                CGFloat speed            = sqrt(displacement.x * displacement.x + displacement.y * displacement.y) / CPTFloat(self.lastDeltaTime);
                CGFloat acceleration     = speed / kCPTMomentumTime;
                CGFloat distanceTraveled = speed * kCPTMomentumTime - CPTFloat(0.5) * acceleration * kCPTMomentumTime * kCPTMomentumTime;
                distanceTraveled = MAX( distanceTraveled, CPTFloat(0.0) );
                CGFloat theta = atan2(displacement.y, displacement.x);

                NSDecimal lastPoint[2], newPoint[2];
                [self plotPoint:lastPoint forPlotAreaViewPoint:pointInPlotArea];
                [self plotPoint:newPoint forPlotAreaViewPoint:CGPointMake( pointInPlotArea.x + distanceTraveled * cos(theta), pointInPlotArea.y + distanceTraveled * sin(theta) )];

                // X range
                NSDecimal shiftX = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
                [self animateRange:self.xRange property:@"xRange" globalRange:self.globalXRange shift:shiftX];

                // Y range
                NSDecimal shiftY = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
                [self animateRange:self.yRange property:@"yRange" globalRange:self.globalYRange shift:shiftY];
            }
        }
        else {
            [self animateRange:self.xRange property:@"xRange" globalRange:self.globalXRange shift:CPTDecimalFromInteger(0)];
            [self animateRange:self.yRange property:@"yRange" globalRange:self.globalYRange shift:CPTDecimalFromInteger(0)];
        }

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
        [self plotPoint:lastPoint forPlotAreaViewPoint:lastDraggedPoint];
        [self plotPoint:newPoint forPlotAreaViewPoint:pointToUse];

        // X range
        NSLog(@"X");
        NSDecimal shiftX        = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
        CPTPlotRange *newRangeX = [self  shiftRange:self.xRange
                                                 by:shiftX
                                      inGlobalRange:self.globalXRange
                                            elastic:self.elasticGlobalXRange
                                   withDisplacement:&displacement.x];

        // Y range
        NSLog(@"Y");
        NSDecimal shiftY        = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
        CPTPlotRange *newRangeY = [self  shiftRange:self.yRange
                                                 by:shiftY
                                      inGlobalRange:self.globalYRange
                                            elastic:self.elasticGlobalYRange
                                   withDisplacement:&displacement.y];

        // Delegate override
        if ( [theDelegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
            self.xRange = [theDelegate plotSpace:self willChangePlotRangeTo:newRangeX forCoordinate:CPTCoordinateX];
            self.yRange = [theDelegate plotSpace:self willChangePlotRangeTo:newRangeY forCoordinate:CPTCoordinateY];
        }
        else {
            self.xRange = newRangeX;
            self.yRange = newRangeY;
        }

        self.lastDragPoint    = pointInPlotArea;
        self.lastDisplacement = displacement;

        NSTimeInterval currentTime = event.timestamp;
        self.lastDeltaTime = currentTime - self.lastDragTime;
        self.lastDragTime  = currentTime;

        return YES;
    }

    return NO;
}

-(CPTPlotRange *)shiftRange:(CPTPlotRange *)oldRange by:(NSDecimal)shift inGlobalRange:(CPTPlotRange *)globalRange elastic:(BOOL)elastic withDisplacement:(CGFloat *)displacement
{
    CPTMutablePlotRange *newRange = [oldRange mutableCopy];

    newRange.location = CPTDecimalAdd(newRange.location, shift);

    if ( globalRange ) {
        CPTPlotRange *constrainedRange = [self constrainRange:newRange toGlobalRange:globalRange];

        if ( elastic ) {
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

@end
