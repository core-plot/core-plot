#import "CPTPolarPlotSpace.h"

#import "CPTAnimation.h"
#import "CPTAnimationOperation.h"
#import "CPTAnimationPeriod.h"
#import "CPTAxisSet.h"
#import "CPTDebugQuickLook.h"
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
typedef NSMutableArray<CPTAnimationOperation *> *CPTMutableAnimationArray;

/// @cond
@interface CPTPolarPlotSpace() /*{
    @private
    // Added S.Wainwright 18/06/2020
    CPTPolarRadialAngleMode __radialAngleOption;
}*/

-(CGFloat)viewCoordinateForViewLength:(NSDecimal)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(NSDecimal)plotCoordinateForViewLength:(NSDecimal)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(NSDecimal)boundsLength;
-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;

-(CPTPlotRange *)constrainRange:(nonnull CPTPlotRange *)existingRange toGlobalRange:(nullable CPTPlotRange *)globalRange;
-(void)animateRangeForCoordinate:(CPTCoordinate)coordinate shift:(NSDecimal)shift momentumTime:(CGFloat)momentumTime speed:(CGFloat)speed acceleration:(CGFloat)acceleration;
-(CPTPlotRange *)shiftRange:(nonnull CPTPlotRange *)oldRange by:(NSDecimal)shift usingMomentum:(BOOL)momentum inGlobalRange:(nullable CPTPlotRange *)globalRange withDisplacement:(CGFloat *)displacement;

-(CGFloat)viewCoordinateForRange:(nullable CPTPlotRange *)range coordinate:(CPTCoordinate)coordinate direction:(BOOL)direction;

extern CGFloat CPTFirstPositiveRoot(CGFloat a, CGFloat b, CGFloat c);

@property (nonatomic, readwrite) BOOL isDragging;
@property (nonatomic, readwrite) CGPoint lastDragPoint;
@property (nonatomic, readwrite) CGPoint lastDisplacement;
@property (nonatomic, readwrite) NSTimeInterval lastDragTime;
@property (nonatomic, readwrite) NSTimeInterval lastDeltaTime;
@property (nonatomic, readwrite, retain, nonnull) CPTMutableAnimationArray animations;


@end

/// @endcond

#pragma mark -

/**
 *  @brief A plot space using a two-dimensional cartesian coordinate system.
 *
 *  The @ref majorRange and @ref minorRange determine the mapping between data coordinates
 *  and the screen coordinates in the plot area. The @quote{end} of a range is
 *  the location plus its length. Note that the length of a plot range can be negative, so
 *  the end point can have a lesser value than the starting location.
 *
 *  The global ranges constrain the values of the @ref majorRange and @ref minorRange.
 *  Whenever the global range is set (non-@nil), the corresponding plot
 *  range will be adjusted so that it fits in the global range. When a new
 *  range is set to the plot range, it will be adjusted as needed to fit
 *  in the global range. This is useful for constraining scrolling, for
 *  instance.
 **/
@implementation CPTPolarPlotSpace


/** @property CPTPolarRadialAngleMode
 *  @brief The angle used to calculate the X & Y position on polar plotspace.
 *  Default is #CPTPolarRadialAngleModeRadians.
 **/

@synthesize radialAngleOption;// = __radialAngleOption;

/** @property CPTPlotRange *majorRange
 *  @brief The range of the x coordinate. Defaults to a range with @link CPTPlotRange::location location @endlink zero (@num{0})
 *  and a @link CPTPlotRange::length length @endlink of one (@num{1}).
 *
 *  The @link CPTPlotRange::location location @endlink of the @ref majorRange
 *  defines the data coordinate associated with the left edge of the plot area.
 *  Similarly, the @link CPTPlotRange::end end @endlink of the @ref majorRange
 *  defines the data coordinate associated with the right edge of the plot area.
 **/
@synthesize majorRange;

/** @property CPTPlotRange *minorRange
 *  @brief The range of the y coordinate. Defaults to a range with @link CPTPlotRange::location location @endlink zero (@num{0})
 *  and a @link CPTPlotRange::length length @endlink of one (@num{1}).
 *
 *  The @link CPTPlotRange::location location @endlink of the @ref minorRange
 *  defines the data coordinate associated with the bottom edge of the plot area.
 *  Similarly, the @link CPTPlotRange::end end @endlink of the @ref minorRange
 *  defines the data coordinate associated with the top edge of the plot area.
 **/
@synthesize minorRange;

/** @property CPTPlotRange *radialRange
*  @brief The range of the z coordinate. Defaults to a range with @link CPTPlotRange::0 location @endlink 2π (@num{2π})
*  and a @link CPTPlotRange::length length @endlink of one (@num{2π}).
*
*  The @link CPTPlotRange::location location @endlink of the @ref radialRange
*  defines the data coordinate associated with the radial of the plot area.
*  Similarly, the @link CPTPlotRange::end end @endlink of the @ref radialRange
*  defines the data coordinate associated with the radial of the plot area.
**/
@synthesize radialRange;

/** @property CPTPlotRange *globalMajorRange
 *  @brief The global range of the x coordinate to which the @ref majorRange is constrained.
 *
 *  If non-@nil, the @ref majorRange and any changes to it will
 *  be adjusted so that it always fits within the @ref globalMajorRange.
 *  If @nil (the default), there is no constraint on x.
 **/
@synthesize globalMajorRange;

/** @property CPTPlotRange *globalMajorRange
 *  @brief The global range of the minor coordinate to which the @ref minorRange is constrained.
 *
 *  If non-@nil, the @ref minorRange and any changes to it will
 *  be adjusted so that it always fits within the @ref globalMinorRange.
 *  If @nil (the default), there is no constraint on minor.
 **/
@synthesize globalMinorRange;

/** @property CPTNumberArray *centrePosition
 *  @brief The centre of the gridlines.
 *
 **/
@synthesize centrePosition;

/** @property CPTScaleType majorScaleType
 *  @brief The scale type of the major coordinate. Defaults to #CPTScaleTypeLinear.
 **/
@synthesize majorScaleType;

/** @property CPTScaleType minorScaleType
 *  @brief The scale type of the minor coordinate. Defaults to #CPTScaleTypeLinear.
 **/
@synthesize minorScaleType;

/** @property CPTScaleType radialScaleType
 *  @brief The scale type of the theta coordinate. Always set to #CPTScaleTypeLinear.
 **/
@synthesize radialScaleType;

/** @property BOOL allowsMomentum
 *  @brief If @YES, plot space scrolling in any direction slows down gradually rather than stopping abruptly. Defaults to @NO.
 **/
@dynamic allowsMomentum;

/** @property BOOL allowsMomentumMajor
 *  @brief If @YES, plot space scrolling in the major-direction slows down gradually rather than stopping abruptly. Defaults to @NO.
 **/
@synthesize allowsMomentumMajor;

/** @property BOOL allowsMomentumMinor
 *  @brief If @YES, plot space scrolling in the minor-direction slows down gradually rather than stopping abruptly. Defaults to @NO.
 **/
@synthesize allowsMomentumMinor;

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

/** @property CGFloat minimumDisplacementToDrag
 *  @brief The minimum distance the interaction point must move before the event is considered a drag. Defaults to @num{2.0}.
 **/
@synthesize minimumDisplacementToDrag;

@dynamic isDragging;
@synthesize lastDragPoint;
@synthesize lastDisplacement;
@synthesize lastDragTime;
@synthesize lastDeltaTime;
@synthesize animations;


#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPolarPlotSpace object.
 *
 *  The initialized object will have the following properties:
 *  - @ref majorRange = [@num{0}, @num{1}]
 *  - @ref minorRange = [@num{0}, @num{1}]
 *  - @ref radialRange = [@num{0}, @num{2*M_PI}]
 *  - @ref globalMajorRange = @nil
 *  - @ref globalMinorRange = @nil
 *  - @ref majorScaleType = #CPTScaleTypeLinear
 *  - @ref minorScaleType = #CPTScaleTypeLinear
 *  - @ref radialScaleType = #CPTScaleTypeLinear
 *
 *  @return The initialized object.
 **/
-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        majorRange           = [[CPTPlotRange alloc] initWithLocation:@-1.0 length:@2.0];
        minorRange           = [[CPTPlotRange alloc] initWithLocation:@-1.0 length:@2.0];
        radialRange           = [[CPTPlotRange alloc] initWithLocation:@0.0 length:@(2.0*M_PI)];
        globalMajorRange  = nil;
        globalMinorRange  = nil;
        majorScaleType    = CPTScaleTypeLinear;
        minorScaleType    = CPTScaleTypeLinear;
        radialScaleType   = CPTScaleTypeLinear;
        centrePosition    = [CPTNumberArray arrayWithObjects: @0.0, @0.0, nil];
        radialAngleOption = CPTPolarRadialAngleModeRadians;
    
        lastDragPoint    = CGPointZero;
        lastDisplacement = CGPointZero;
        lastDragTime     = 0.0;
        lastDeltaTime    = 0.0;
        animations       = [[NSMutableArray alloc] init];
        
        allowsMomentumMajor           = NO;
        allowsMomentumMinor           = NO;
        momentumAnimationCurve    = CPTAnimationCurveQuadraticOut;
        bounceAnimationCurve      = CPTAnimationCurveQuadraticOut;
        momentumAcceleration      = 2000.0;
        bounceAcceleration        = 3000.0;
        minimumDisplacementToDrag = 2.0;
    }
    return self;
}

/// @}

///// @cond
//
//-(void)dealloc
//{
//    majorRange = nil;
//    minorRange = nil;
//    radialRange = nil;
//    globalMajorRange = nil;
//    globalMinorRange = nil;
//}
//
///// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeInteger:self.radialAngleOption forKey:@"CPTPolarPlotSpace.radialAngleOption"];
    [coder encodeObject:self.majorRange forKey:@"CPTPolarPlotSpace.majorRange"];
    [coder encodeObject:self.minorRange forKey:@"CPTPolarPlotSpace.minorRange"];
    [coder encodeObject:self.radialRange forKey:@"CPTPolarPlotSpace.radialRange"];
    [coder encodeObject:self.globalMajorRange forKey:@"CPTPolarPlotSpace.globalMajorRange"];
    [coder encodeObject:self.globalMinorRange forKey:@"CPTPolarPlotSpace.globalMinorRange"];
    [coder encodeObject:self.centrePosition forKey:@"CPTPolarPlotSpace.centrePosition"];
    [coder encodeInteger:self.majorScaleType forKey:@"CPTPolarPlotSpace.majorScaleType"];
    [coder encodeInteger:self.minorScaleType forKey:@"CPTPolarPlotSpace.minorScaleType"];
    [coder encodeInteger:self.radialScaleType forKey:@"CPTPolarPlotSpace.radialScaleType"];
    [coder encodeBool:self.allowsMomentumMajor forKey:@"CPTPolarPlotSpace.allowsMomentumMajor"];
    [coder encodeBool:self.allowsMomentumMinor forKey:@"CPTPolarPlotSpace.allowsMomentumMinor"];
    [coder encodeInteger:self.momentumAnimationCurve forKey:@"CPTPolarPlotSpace.momentumAnimationCurve"];
    [coder encodeInteger:self.bounceAnimationCurve forKey:@"CPTPolarPlotSpace.bounceAnimationCurve"];
    [coder encodeCGFloat:self.momentumAcceleration forKey:@"CPTPolarPlotSpace.momentumAcceleration"];
    [coder encodeCGFloat:self.bounceAcceleration forKey:@"CPTPolarPlotSpace.bounceAcceleration"];
    [coder encodeCGFloat:self.minimumDisplacementToDrag forKey:@"CPTPolarPlotSpace.minimumDisplacementToDrag"];
    
    // No need to archive these properties:
    // lastDragPoint
    // lastDisplacement
    // lastDragTime
    // lastDeltaTime
    // animations
}

-(nullable instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        
        self.radialAngleOption                  = (CPTPolarRadialAngleMode)[coder decodeIntegerForKey:@"CPTPolarPlotSpace.radialAngleOption"];
        
        CPTPlotRange *range = [coder decodeObjectForKey:@"CPTPolarPlotSpace.majorRange"];
        if ( range ) {
            majorRange = [range copy];
        }
        range = [coder decodeObjectForKey:@"CPTPolarPlotSpace.minorRange"];
        if ( range ) {
            minorRange = [range copy];
        }
        range = [coder decodeObjectForKey:@"CPTPolarPlotSpace.radialRange"];
        if ( range ) {
            radialRange = [range copy];
        }
        globalMajorRange = [[coder decodeObjectForKey:@"CPTPolarPlotSpace.globalMajorRange"] copy];
        globalMinorRange = [[coder decodeObjectForKey:@"CPTPolarPlotSpace.globalMinorRange"] copy];
        centrePosition = [[coder decodeObjectForKey:@"CPTPolarPlotSpace.centrePosition"] copy];
        majorScaleType   = (CPTScaleType)[coder decodeIntegerForKey : @"CPTPolarPlotSpace.majorScaleType"];
        minorScaleType   = (CPTScaleType)[coder decodeIntegerForKey : @"CPTPolarPlotSpace.minorScaleType"];
        radialScaleType   = (CPTScaleType)[coder decodeIntForKey : @"CPTPolarPlotSpace.radialScaleType"];
        
        if ( [coder containsValueForKey:@"CPTPolarPlotSpace.allowsMomentum"] ) {
            self.allowsMomentum = [coder decodeBoolForKey:@"CPTPolarPlotSpace.allowsMomentum"];
        }
        else {
            allowsMomentumMajor = [coder decodeBoolForKey:@"CPTPolarPlotSpace.allowsMomentumMajor"];
            allowsMomentumMinor = [coder decodeBoolForKey:@"CPTPolarPlotSpace.allowsMomentumMinor"];
        }
        momentumAnimationCurve    = (CPTAnimationCurve)[coder decodeIntForKey : @"CPTPolarPlotSpace.momentumAnimationCurve"];
        bounceAnimationCurve      = (CPTAnimationCurve)[coder decodeIntForKey : @"CPTPolarPlotSpace.bounceAnimationCurve"];
        momentumAcceleration      = [coder decodeCGFloatForKey:@"CPTPolarPlotSpace.momentumAcceleration"];
        bounceAcceleration        = [coder decodeCGFloatForKey:@"CPTPolarPlotSpace.bounceAcceleration"];
        minimumDisplacementToDrag = [coder decodeCGFloatForKey:@"CPTPolarPlotSpace.minimumDisplacementToDrag"];
        
        lastDragPoint    = CGPointZero;
        lastDisplacement = CGPointZero;
        lastDragTime     = 0.0;
        lastDeltaTime    = 0.0;
        animations       = [[NSMutableArray alloc] init];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Ranges

/// @cond

-(void)setPlotRange:(nonnull CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    switch ( coordinate ) {
        case CPTCoordinateX:
            self.majorRange = newRange;
            break;

        case CPTCoordinateY:
            self.minorRange = newRange;
            break;
        
        case CPTCoordinateZ:
            self.radialRange = newRange;
            break;

        default:
            // invalid coordinate--do nothing
            break;
    }
}

-(nullable CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coordinate
{
    CPTPlotRange *theRange = nil;

    switch ( coordinate ) {
        case CPTCoordinateX:
            theRange = self.majorRange;
            break;

        case CPTCoordinateY:
            theRange = self.minorRange;
            break;
            
        case CPTCoordinateZ:
            theRange = self.radialRange;
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
            self.majorScaleType = newType;
            break;

        case CPTCoordinateY:
            self.minorScaleType = newType;
            break;
            
        case CPTCoordinateZ:
 //           self.radialScaleType = newType;
 //           break;

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
            theScaleType = self.majorScaleType;
            break;

        case CPTCoordinateY:
            theScaleType = self.minorScaleType;
            break;
            
        case CPTCoordinateZ:
            theScaleType = self.radialScaleType;
            break;

        default:
            // invalid coordinate
            break;
    }

    return theScaleType;
}

-(void)setMajorRange:(nonnull CPTPlotRange *)range
{
    NSParameterAssert(range);
    
    if ( ![range isEqualToRange:majorRange] ) {
        CPTPlotRange *constrainedRange;
        
        if ( self.allowsMomentumMajor ) {
            constrainedRange = range;
        }
        else {
            constrainedRange = [self constrainRange:range toGlobalRange:self.globalMajorRange];
        }
        
        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
        if ( [theDelegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
            constrainedRange = [theDelegate plotSpace:self willChangePlotRangeTo:constrainedRange forCoordinate:CPTCoordinateX];
        }
        
        if ( ![constrainedRange isEqualToRange:majorRange] ) {
            CGFloat displacement = self.lastDisplacement.x;
            BOOL isScrolling     = NO;
            
            if ( majorRange && constrainedRange ) {
                isScrolling = !CPTDecimalEquals(constrainedRange.locationDecimal, majorRange.locationDecimal) && CPTDecimalEquals(constrainedRange.lengthDecimal, majorRange.lengthDecimal);
                
                if ( isScrolling && ( displacement == CPTFloat(0.0) ) ) {
                    CPTGraph *theGraph    = self.graph;
                    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
                    
                    if ( plotArea ) {
                        NSDecimal rangeLength = constrainedRange.lengthDecimal;
                        
                        if ( !CPTDecimalEquals( rangeLength, CPTDecimalFromInteger(0) ) ) {
                            NSDecimal diff = CPTDecimalDivide(CPTDecimalSubtract(constrainedRange.locationDecimal, majorRange.locationDecimal), rangeLength);
                            
                            displacement = plotArea.bounds.size.width * CPTDecimalCGFloatValue(diff);
                        }
                    }
                }
            }
            
            majorRange = [constrainedRange copy];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                                object:self
                                                              userInfo:@{ CPTPlotSpaceCoordinateKey: @(CPTCoordinateX),
                                                                          CPTPlotSpaceScrollingKey: @(isScrolling),
                                                                          CPTPlotSpaceDisplacementKey: @(displacement) }
             ];
            
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

-(void)setMinorRange:(nonnull CPTPlotRange *)range
{
    NSParameterAssert(range);
    
    if ( ![range isEqualToRange:minorRange] ) {
        CPTPlotRange *constrainedRange;
        
        if ( self.allowsMomentumMinor ) {
            constrainedRange = range;
        }
        else {
            constrainedRange = [self constrainRange:range toGlobalRange:self.globalMinorRange];
        }
        
        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
        if ( [theDelegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
            constrainedRange = [theDelegate plotSpace:self willChangePlotRangeTo:constrainedRange forCoordinate:CPTCoordinateY];
        }
        
        if ( ![constrainedRange isEqualToRange:minorRange] ) {
            CGFloat displacement = self.lastDisplacement.y;
            BOOL isScrolling     = NO;
            
            if ( minorRange && constrainedRange ) {
                isScrolling = !CPTDecimalEquals(constrainedRange.locationDecimal, minorRange.locationDecimal) && CPTDecimalEquals(constrainedRange.lengthDecimal, minorRange.lengthDecimal);
                
                if ( isScrolling && ( displacement == CPTFloat(0.0) ) ) {
                    CPTGraph *theGraph    = self.graph;
                    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
                    
                    if ( plotArea ) {
                        NSDecimal rangeLength = constrainedRange.lengthDecimal;
                        
                        if ( !CPTDecimalEquals( rangeLength, CPTDecimalFromInteger(0) ) ) {
                            NSDecimal diff = CPTDecimalDivide(CPTDecimalSubtract(constrainedRange.locationDecimal, minorRange.locationDecimal), rangeLength);
                            
                            displacement = plotArea.bounds.size.height * CPTDecimalCGFloatValue(diff);
                        }
                    }
                }
            }
            
            minorRange = [constrainedRange copy];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                                object:self
                                                              userInfo:@{ CPTPlotSpaceCoordinateKey: @(CPTCoordinateY),
                                                                          CPTPlotSpaceScrollingKey: @(isScrolling),
                                                                          CPTPlotSpaceDisplacementKey: @(displacement) }
             ];
            
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

-(void)setRadialRange:(nonnull CPTPlotRange *)range
{
    NSParameterAssert(range);
    
    if ( ![range isEqualToRange:self.radialRange] ) {
//        CPTPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.radialRange];
//        self.radialRange = nil;
        radialRange = range;
//        self.radialRange = [constrainedRange copy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];
        
        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
        if ( [theDelegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
            [theDelegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateZ];
        }
        
        CPTGraph *theGraph = self.graph;
        if ( theGraph ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                object:theGraph];
        }
    }
}

-(nonnull CPTPlotRange *)constrainRange:(nonnull CPTPlotRange *)existingRange toGlobalRange:(nullable CPTPlotRange *)globalRange
{
    if ( !globalRange ) {
        return existingRange;
    }
    if ( !existingRange ) {
        return nil;
    }
    
    CPTPlotRange *theGlobalRange = globalRange;
    
    if ( CPTDecimalGreaterThanOrEqualTo(existingRange.lengthDecimal, globalRange.lengthDecimal) ) {
        return [theGlobalRange copy];
    }
    else {
        CPTMutablePlotRange *newRange = [existingRange mutableCopy];
        [newRange shiftEndToFitInRange:theGlobalRange];
        [newRange shiftLocationToFitInRange:theGlobalRange];
        return newRange;
    }
}

-(void)setGlobalMajorRange:(nullable CPTPlotRange *)newRange
{
    if ( ![newRange isEqualToRange:globalMajorRange] ) {
        globalMajorRange = [newRange copy];
        self.majorRange  = [self constrainRange:self.majorRange toGlobalRange:globalMajorRange];
    }
}

-(void)setGlobalMinorRange:(nullable CPTPlotRange *)newRange
{
    if ( ![newRange isEqualToRange:globalMinorRange] ) {
        globalMinorRange = [newRange copy];
        self.minorRange  = [self constrainRange:self.minorRange toGlobalRange:globalMinorRange];
    }
}

-(void)animateRangeForCoordinate:(CPTCoordinate)coordinate shift:(NSDecimal)shift momentumTime:(CGFloat)momentumTime speed:(CGFloat)speed acceleration:(CGFloat)acceleration
{
    CPTMutableAnimationArray animationArray = self.animations;
    CPTAnimationOperation *op;
    
    NSString *property        = nil;
    CPTPlotRange *oldRange    = nil;
    CPTPlotRange *globalRange = nil;
    
    switch ( coordinate ) {
        case CPTCoordinateX:
            property    = @"majorRange";
            oldRange    = self.majorRange;
            globalRange = self.globalMajorRange;
            break;
            
        case CPTCoordinateY:
            property    = @"minorRange";
            oldRange    = self.minorRange;
            globalRange = self.globalMinorRange;
            break;
            
        default:
            break;
    }
    
    CPTMutablePlotRange *newRange = [oldRange mutableCopy];
    
    CGFloat bounceDelay = CPTFloat(0.0);
    NSDecimal zero      = CPTDecimalFromInteger(0);
    BOOL hasShift       = !CPTDecimalEquals(shift, zero);
    
    if ( hasShift && property != nil ) {
        newRange.locationDecimal = CPTDecimalAdd(newRange.locationDecimal, shift);
        
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
            BOOL direction = ( CPTDecimalGreaterThan(shift, zero) && CPTDecimalGreaterThan(oldRange.lengthDecimal, zero) ) ||
            ( CPTDecimalLessThan(shift, zero) && CPTDecimalLessThan(oldRange.lengthDecimal, zero) );
            
            // decelerate at the global range
            if ( hasShift ) {
                CGFloat brakingDelay = CPTFloat(NAN);
                
                if ( [globalRange containsRange:oldRange] ) {
                    // momentum started inside the global range; coast until we hit the global range
                    CGFloat globalPoint = [self viewCoordinateForRange:globalRange coordinate:coordinate direction:direction];
                    CGFloat oldPoint    = [self viewCoordinateForRange:oldRange coordinate:coordinate direction:direction];
                    
                    CGFloat brakingOffset = globalPoint - oldPoint;
                    brakingDelay = CPTFirstPositiveRoot(acceleration, speed, brakingOffset);
                    
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
                        
                        NSDecimal brakingShift = CPTDecimalSubtract(newPoint[coordinate], direction ? globalRange.endDecimal : globalRange.locationDecimal);
                        
                        [newRange shiftEndToFitInRange:globalRange];
                        [newRange shiftLocationToFitInRange:globalRange];
                        newRange.locationDecimal = CPTDecimalAdd(newRange.locationDecimal, brakingShift);
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
                    
                    newRange = [oldRange mutableCopy];
                    
                    newRange.locationDecimal = CPTDecimalAdd(newRange.locationDecimal, shift);
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
}

-(CGFloat)viewCoordinateForRange:(nullable CPTPlotRange *)range coordinate:(CPTCoordinate)coordinate direction:(BOOL)direction
{
    CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(coordinate);
    
    NSDecimal point[2];
    
    point[coordinate]           = (direction ? range.maxLimitDecimal : range.minLimitDecimal);
    point[orthogonalCoordinate] = CPTDecimalFromInteger(1);
    
    CGPoint viewPoint       = [self plotAreaViewPointForPlotPoint:point numberOfCoordinates:2];
    CGFloat pointCoordinate = CPTFloat(NAN);
    
    switch ( coordinate ) {
        case CPTCoordinateX:
            pointCoordinate = viewPoint.x;
            break;
            
        case CPTCoordinateY:
            pointCoordinate = viewPoint.y;
            break;
            
        default:
            break;
    }
    
    return pointCoordinate;
}

-(void)scaleToFitPlots:(nullable CPTPlotArray*)plots
{
    if ( plots.count == 0 ) {
        return;
    }
    
    // Determine union of ranges
    CPTMutablePlotRange *unionMajorRange = nil;
    CPTMutablePlotRange *unionMinorRange = nil;
    
    for ( CPTPlot *plot in plots ) {
        CPTPlotRange *currentMajorRange = [plot plotRangeForCoordinate:CPTCoordinateX];
        CPTPlotRange *currentMinorRange = [plot plotRangeForCoordinate:CPTCoordinateY];
        if ( !unionMajorRange ) {
            unionMajorRange = [currentMajorRange mutableCopy];
        }
        if ( !unionMinorRange ) {
            unionMinorRange = [currentMinorRange mutableCopy];
        }
        
        [unionMajorRange unionPlotRange:currentMajorRange];
        [unionMinorRange unionPlotRange:currentMinorRange];
    }
    
    // Set range
    NSDecimal zero = CPTDecimalFromInteger(0);
    if ( unionMajorRange ) {
        if ( CPTDecimalEquals(unionMajorRange.lengthDecimal, zero) ) {
            [unionMajorRange unionPlotRange:self.majorRange];
        }
        self.majorRange = unionMajorRange;
    }
    if ( unionMinorRange ) {
        if ( CPTDecimalEquals(unionMinorRange.lengthDecimal, zero) ) {
            [unionMinorRange unionPlotRange:self.minorRange];
        }
        self.minorRange = unionMinorRange;
    }
}


-(void)scaleToFitEntirePlots:(nullable CPTPlotArray *)plots
{
    if ( plots.count == 0 ) {
        return;
    }
    
    // Determine union of ranges
    CPTMutablePlotRange *unionMajorRange = nil;
    CPTMutablePlotRange *unionMinorRange = nil;
    for ( CPTPlot *plot in plots ) {
        CPTPlotRange *currentMajorRange = [plot plotRangeEnclosingCoordinate:CPTCoordinateX];
        CPTPlotRange *currentMinorRange = [plot plotRangeEnclosingCoordinate:CPTCoordinateY];
        if ( !unionMajorRange ) {
            unionMajorRange = [currentMajorRange mutableCopy];
        }
        if ( !unionMinorRange ) {
            unionMinorRange = [currentMinorRange mutableCopy];
        }
        
        [unionMajorRange unionPlotRange:currentMajorRange];
        [unionMinorRange unionPlotRange:currentMinorRange];
    }
    
    // Set range
    NSDecimal zero = CPTDecimalFromInteger(0);
    if ( unionMajorRange ) {
        if ( CPTDecimalEquals(unionMajorRange.lengthDecimal, zero) ) {
            [unionMajorRange unionPlotRange:self.majorRange];
        }
        self.majorRange = unionMajorRange;
    }
    if ( unionMinorRange ) {
        if ( CPTDecimalEquals(unionMinorRange.lengthDecimal, zero) ) {
            [unionMinorRange unionPlotRange:self.minorRange];
        }
        self.minorRange = unionMinorRange;
    }
}


-(void)setMajorScaleType:(CPTScaleType)newScaleType
{
    if ( newScaleType != majorScaleType ) {
        majorScaleType = newScaleType;

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];

        CPTGraph *theGraph = self.graph;
        if ( theGraph ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                object:theGraph];
        }
    }
}

-(void)setMinorScaleType:(CPTScaleType)newScaleType
{
    if ( newScaleType != minorScaleType ) {
        minorScaleType = newScaleType;

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
-(CGFloat)viewCoordinateForViewLength:(NSDecimal)viewLength linearPlotRange:(nonnull CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord
{
    if ( !range ) {
        return CPTFloat(0.0);
    }
    
    NSDecimal factor = CPTDecimalDivide(CPTDecimalSubtract(plotCoord, range.locationDecimal), range.lengthDecimal);
    if ( NSDecimalIsNotANumber(&factor) ) {
        factor = CPTDecimalFromInteger(0);
    }
    
    NSDecimal viewCoordinate = CPTDecimalMultiply(viewLength, factor);
    
    return CPTDecimalCGFloatValue(viewCoordinate);
}

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(nonnull CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord
{
    if ( !range || (range.lengthDouble == 0.0) ) {
        return CPTFloat(0.0);
    }
    return viewLength * (CGFloat)( (plotCoord - range.locationDouble) / range.lengthDouble );
}

-(NSDecimal)plotCoordinateForViewLength:(NSDecimal)viewLength linearPlotRange:(nonnull CPTPlotRange *)range boundsLength:(NSDecimal)boundsLength
{
    const NSDecimal zero = CPTDecimalFromInteger(0);
    
    if ( CPTDecimalEquals(boundsLength, zero) ) {
        return zero;
    }
    
    NSDecimal location = range.locationDecimal;
    NSDecimal length   = range.lengthDecimal;
    
    NSDecimal coordinate;
    NSDecimalDivide(&coordinate, &viewLength, &boundsLength, NSRoundPlain);
    NSDecimalMultiply(&coordinate, &coordinate, &length, NSRoundPlain);
    NSDecimalAdd(&coordinate, &coordinate, &location, NSRoundPlain);
    
    return coordinate;
}

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(nonnull CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
    if ( boundsLength == (CGFloat)0.0 ) {
        return 0.0;
    }
    
    double coordinate = (double)(viewLength / boundsLength);
    coordinate *= range.lengthDouble;
    coordinate += range.locationDouble;
    
    return coordinate;
}

// Log (only one version since there are no transcendental functions for NSDecimal)
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(nonnull CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord
{
//    if ( (range.minLimitDouble <= 0.0) || (range.maxLimitDouble <= 0.0) || (plotCoord <= 0.0) ) {
//        return CPTFloat(0.0);
//    }
//
//    double logLoc   = log10(range.locationDouble);
//    double logCoord = log10(plotCoord);
//    double logEnd   = log10(range.endDouble);
//
//    return viewLength * (CGFloat)( (logCoord - logLoc) / (logEnd - logLoc) );
    double centre = 0.0;
    if( [self.centrePosition[0] doubleValue] == 0.0 && [self.centrePosition[1] doubleValue] == 0.0) {
        centre = MIN(pow(10, floor(log10(range.maxLimitDouble))-2.0), pow(10, floor(log10(range.minLimitDouble))-2.0)); // middle is centre ie log
    }
    else {
        centre = MIN([self.centrePosition[0] doubleValue], [self.centrePosition[1] doubleValue]);
    }
    double logEnd = 0.0;
    double logLoc = log10(centre);
    if (plotCoord < 0.0) {
        logEnd   = log10(fabs(range.minLimitDouble));
    }
    else {
        logEnd   = log10(fabs(range.maxLimitDouble));
    }
    
    CGFloat apportion = 0.0;
    if (range.midPointDouble < 0.0) {
        apportion = viewLength * (CGFloat)((range.midPointDouble - range.minLimitDouble) / range.lengthDouble);
    }
    else {
        apportion = viewLength * (CGFloat)((range.maxLimitDouble - range.midPointDouble) / range.lengthDouble);
    }
    if (plotCoord == 0.0 || isnan(plotCoord)) {
        return CPTFloat(apportion);
    }
    else {
        double logCoord = log10(fabs(plotCoord));
        return apportion * (CGFloat)( (logCoord - logLoc) / (logEnd - logLoc) );
    }
}

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(nonnull CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
//    if ( boundsLength == (CGFloat)0.0 ) {
//        return 0.0;
//    }
//
//    double logLoc = log10(range.locationDouble);
//    double logEnd = log10(range.endDouble);
//
//    double coordinate = (double)viewLength * (logEnd - logLoc) / (double)boundsLength + logLoc;
//
//    return pow(10.0, coordinate);
    double middle = (range.minLimitDouble + range.maxLimitDouble) / 2.0;
    double centre = 0.0;
    if( [self.centrePosition[0] doubleValue] == 0.0 && [self.centrePosition[1] doubleValue] == 0.0) {
        centre = MIN(pow(10, floor(log10(range.maxLimitDouble))-2.0), pow(10, floor(log10(range.minLimitDouble))-2.0)); // middle is centre ie log
    }
    else {
        centre = MIN([self.centrePosition[0] doubleValue], [self.centrePosition[1] doubleValue]);
    }
    double logEnd = 0.0;
    double logLoc = log10(centre);
    if (boundsLength < 0.0) {
        logEnd   = log10(fabs(range.minLimitDouble));
    }
    else {
        logEnd   = log10(fabs(range.maxLimitDouble));
    }
    
    CGFloat apportion = 0.0;
    if (middle < 0.0) {
        apportion = viewLength * (CGFloat)((middle - range.minLimitDouble) / range.lengthDouble);
    }
    else {
        apportion = viewLength * (CGFloat)((range.maxLimitDouble - middle) / range.lengthDouble);
    }
    if (boundsLength == 0.0 || isnan(boundsLength)) {
        return (double)apportion;
    }
    else {
        return pow(10, (double)(apportion * (CGFloat)( (logEnd - logLoc) / ((double)boundsLength + logLoc) )));
    }
}

// Log-modulus (only one version since there are no transcendental functions for NSDecimal)
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logModulusPlotRange:(nonnull CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord
{
    if ( !range ) {
        return CPTFloat(0.0);
    }
    
    double logLoc   = CPTLogModulus(range.locationDouble);
    double logCoord = CPTLogModulus(plotCoord);
    double logEnd   = CPTLogModulus(range.endDouble);

    return viewLength * (CGFloat)( (logCoord - logLoc) / (logEnd - logLoc) );
}

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logModulusPlotRange:(nonnull CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
    if ( boundsLength == (CGFloat)0.0 ) {
        return 0.0;
    }
    
    double logLoc     = CPTLogModulus(range.locationDouble);
    double logEnd     = CPTLogModulus(range.endDouble);
    double coordinate = (double)viewLength * (logEnd - logLoc) / (double)boundsLength + logLoc;
    
    return CPTInverseLogModulus(coordinate);
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
-(CGPoint)plotAreaViewPointForPlotPoint:(nonnull CPTNumberArray*)plotPoint
{
    CGPoint viewPoint = [super plotAreaViewPointForPlotPoint:plotPoint];
    
    CGSize layerSize;
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    
    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return viewPoint;
    }
    
    CPTPlotRange *dominantRange = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorRange : self.minorRange;
    CPTScaleType dominantScaleType = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorScaleType : self.minorScaleType;
    
    switch ( dominantScaleType ) {
        case CPTScaleTypeLinear:
        case CPTScaleTypeCategory:
            viewPoint.x = [self viewCoordinateForViewLength:plotArea.widthDecimal linearPlotRange:dominantRange plotCoordinateValue:[plotPoint[CPTCoordinateX] decimalValue]];
            viewPoint.y = [self viewCoordinateForViewLength:plotArea.heightDecimal linearPlotRange:dominantRange plotCoordinateValue:[plotPoint[CPTCoordinateY] decimalValue]];
            break;
            
        case CPTScaleTypeLog:
        {
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:dominantRange doublePrecisionPlotCoordinateValue:[plotPoint[CPTCoordinateX] doubleValue]];
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:dominantRange doublePrecisionPlotCoordinateValue:[plotPoint[CPTCoordinateY] doubleValue]];
        }
            break;
            
        case CPTScaleTypeLogModulus:
        {
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logModulusPlotRange:dominantRange doublePrecisionPlotCoordinateValue:[plotPoint[CPTCoordinateX] doubleValue]];
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logModulusPlotRange:dominantRange doublePrecisionPlotCoordinateValue:[plotPoint[CPTCoordinateY] doubleValue]];
        }
            break;
            
        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
    }
    
//    switch ( self.majorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            viewPoint.x = [self viewCoordinateForViewLength:plotArea.widthDecimal linearPlotRange:self.majorRange plotCoordinateValue:[plotPoint[CPTCoordinateX] decimalValue]];
//            break;
//            
//        case CPTScaleTypeLog:
//        {
//            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.majorRange doublePrecisionPlotCoordinateValue:[plotPoint[CPTCoordinateX] doubleValue]];
//        }
//            break;
//            
//        case CPTScaleTypeLogModulus:
//        {
//            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logModulusPlotRange:self.majorRange doublePrecisionPlotCoordinateValue:[plotPoint[CPTCoordinateX] doubleValue]];
//        }
//            break;
//            
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
//    
//    switch ( self.minorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            viewPoint.y = [self viewCoordinateForViewLength:plotArea.heightDecimal linearPlotRange:self.minorRange plotCoordinateValue:[plotPoint[CPTCoordinateY] decimalValue]];
//            break;
//            
//        case CPTScaleTypeLog:
//        {
//            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.minorRange doublePrecisionPlotCoordinateValue:[plotPoint[CPTCoordinateY] doubleValue]];
//        }
//            break;
//            
//        case CPTScaleTypeLogModulus:
//        {
//            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logModulusPlotRange:self.minorRange doublePrecisionPlotCoordinateValue:[plotPoint[CPTCoordinateY] doubleValue]];
//        }
//            break;
//            
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
    
    return viewPoint;
}

-(CGPoint)plotAreaViewPointForPlotPoint:(nonnull NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count
{
    CGPoint viewPoint = [super plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:count];
    
    CGSize layerSize;
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    
    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return viewPoint;
    }
    
    CPTPlotRange *dominantRange = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorRange : self.minorRange;
    CPTScaleType dominantScaleType = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorScaleType : self.minorScaleType;
    
    switch ( dominantScaleType ) {
        case CPTScaleTypeLinear:
        case CPTScaleTypeCategory:
            viewPoint.x = [self viewCoordinateForViewLength:plotArea.widthDecimal linearPlotRange:dominantRange plotCoordinateValue:plotPoint[CPTCoordinateX]];
            viewPoint.y = [self viewCoordinateForViewLength:plotArea.heightDecimal linearPlotRange:dominantRange plotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;
            
        case CPTScaleTypeLog:
        {
            double x = CPTDecimalDoubleValue(plotPoint[CPTCoordinateX]);
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:dominantRange doublePrecisionPlotCoordinateValue:x];
            double y = CPTDecimalDoubleValue(plotPoint[CPTCoordinateY]);
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:dominantRange doublePrecisionPlotCoordinateValue:y];
        }
            break;
            
        case CPTScaleTypeLogModulus:
        {
            double x = CPTDecimalDoubleValue(plotPoint[CPTCoordinateX]);
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logModulusPlotRange:dominantRange doublePrecisionPlotCoordinateValue:x];
            double y = CPTDecimalDoubleValue(plotPoint[CPTCoordinateY]);
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logModulusPlotRange:dominantRange doublePrecisionPlotCoordinateValue:y];
        }
            break;
            
        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
    }
    
//    switch ( self.majorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            viewPoint.x = [self viewCoordinateForViewLength:plotArea.widthDecimal linearPlotRange:self.majorRange plotCoordinateValue:plotPoint[CPTCoordinateX]];
//            break;
//
//        case CPTScaleTypeLog:
//        {
//            double x = CPTDecimalDoubleValue(plotPoint[CPTCoordinateX]);
//            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.majorRange doublePrecisionPlotCoordinateValue:x];
//        }
//            break;
//
//        case CPTScaleTypeLogModulus:
//        {
//            double x = CPTDecimalDoubleValue(plotPoint[CPTCoordinateX]);
//            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logModulusPlotRange:self.majorRange doublePrecisionPlotCoordinateValue:x];
//        }
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
//
//    switch ( self.minorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            viewPoint.y = [self viewCoordinateForViewLength:plotArea.heightDecimal linearPlotRange:self.minorRange plotCoordinateValue:plotPoint[CPTCoordinateY]];
//            break;
//
//        case CPTScaleTypeLog:
//        {
//            double y = CPTDecimalDoubleValue(plotPoint[CPTCoordinateY]);
//            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.minorRange doublePrecisionPlotCoordinateValue:y];
//        }
//            break;
//
//        case CPTScaleTypeLogModulus:
//        {
//            double y = CPTDecimalDoubleValue(plotPoint[CPTCoordinateY]);
//            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logModulusPlotRange:self.minorRange doublePrecisionPlotCoordinateValue:y];
//        }
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
    
    return viewPoint;
}

-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(nonnull double *)plotPoint numberOfCoordinates:(NSUInteger)count
{
    CGPoint viewPoint = [super plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:count];
    
    CGSize layerSize;
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    
    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return viewPoint;
    }
    
    CPTPlotRange *dominantRange = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorRange : self.minorRange;
    CPTScaleType dominantScaleType = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorScaleType : self.minorScaleType;
    
    switch ( dominantScaleType ) {
        case CPTScaleTypeLinear:
        case CPTScaleTypeCategory:
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:dominantRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:dominantRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;
            
        case CPTScaleTypeLog:
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:dominantRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:dominantRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;
            
        case CPTScaleTypeLogModulus:
            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logModulusPlotRange:dominantRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logModulusPlotRange:dominantRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;
            
        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }
//    switch ( self.majorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.majorRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
//            break;
//
//        case CPTScaleTypeLog:
//            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.majorRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
//            break;
//
//        case CPTScaleTypeLogModulus:
//            viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logModulusPlotRange:self.majorRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
//    }
//
//    switch ( self.minorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.minorRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
//            break;
//
//        case CPTScaleTypeLog:
//            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.minorRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
//            break;
//
//        case CPTScaleTypeLogModulus:
//            viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logModulusPlotRange:self.minorRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
    
    return viewPoint;
}

// Plot point for view point
-(nullable CPTNumberArray*)plotPointForPlotAreaViewPoint:(CGPoint)point
{
    CPTMutableNumberArray *plotPoint = [[super plotPointForPlotAreaViewPoint:point] mutableCopy];
    
    CGSize boundsSize;
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    
    if ( plotArea ) {
        boundsSize = plotArea.bounds.size;
    }
    else {
        return @[@0, @0];
    }
    
    if ( !plotPoint ) {
        plotPoint = [NSMutableArray arrayWithCapacity:self.numberOfCoordinates];
    }
    
    CPTPlotRange *dominantRange = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorRange : self.minorRange;
    CPTScaleType dominantScaleType = self.majorRange.lengthDouble > self.minorRange.lengthDouble ?  self.majorScaleType : self.minorScaleType;
    
    switch ( dominantScaleType ) {
        case CPTScaleTypeLinear:
        case CPTScaleTypeCategory:
            plotPoint[CPTCoordinateX] = [NSDecimalNumber decimalNumberWithDecimal:[self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.x) linearPlotRange:dominantRange boundsLength:plotArea.widthDecimal]];
            plotPoint[CPTCoordinateY] = [NSDecimalNumber decimalNumberWithDecimal:[self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.y) linearPlotRange:dominantRange boundsLength:plotArea.heightDecimal]];
            break;
            
        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateX] = @([self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:dominantRange boundsLength:boundsSize.width]);
            plotPoint[CPTCoordinateY] = @([self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:dominantRange boundsLength:boundsSize.height]);
            break;
            
        case CPTScaleTypeLogModulus:
            plotPoint[CPTCoordinateX] = @([self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:dominantRange boundsLength:boundsSize.width]);
            plotPoint[CPTCoordinateY] = @([self doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:dominantRange boundsLength:boundsSize.height]);
            break;
            
        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
    }
    
//    switch ( self.majorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            plotPoint[CPTCoordinateX] = [NSDecimalNumber decimalNumberWithDecimal:[self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.x) linearPlotRange:self.majorRange boundsLength:plotArea.widthDecimal]];
//            break;
//
//        case CPTScaleTypeLog:
//            plotPoint[CPTCoordinateX] = @([self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.majorRange boundsLength:boundsSize.width]);
//            break;
//
//        case CPTScaleTypeLogModulus:
//            plotPoint[CPTCoordinateX] = @([self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:self.majorRange boundsLength:boundsSize.width]);
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
//
//    switch ( self.minorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            plotPoint[CPTCoordinateY] = [NSDecimalNumber decimalNumberWithDecimal:[self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.y) linearPlotRange:self.minorRange boundsLength:plotArea.heightDecimal]];
//            break;
//
//        case CPTScaleTypeLog:
//            plotPoint[CPTCoordinateY] = @([self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.minorRange boundsLength:boundsSize.height]);
//            break;
//
//        case CPTScaleTypeLogModulus:
//            plotPoint[CPTCoordinateY] = @([self doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:self.minorRange boundsLength:boundsSize.height]);
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
    
    return plotPoint;
}

-(void)plotPoint:(nonnull NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point
{
    [super plotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:point];
    
    CGSize boundsSize;
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    
    if ( plotArea ) {
        boundsSize = plotArea.bounds.size;
    }
    else {
        NSDecimal zero = CPTDecimalFromInteger(0);
        plotPoint[CPTCoordinateX] = zero;
        plotPoint[CPTCoordinateY] = zero;
        return;
    }
    
    CPTPlotRange *dominantRange = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorRange : self.minorRange;
    CPTScaleType dominantScaleType = self.majorRange.lengthDouble > self.minorRange.lengthDouble ?  self.majorScaleType : self.minorScaleType;
    
    switch ( dominantScaleType ) {
        case CPTScaleTypeLinear:
        case CPTScaleTypeCategory:
            plotPoint[CPTCoordinateX] = [self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.x) linearPlotRange:dominantRange boundsLength:plotArea.widthDecimal];
            plotPoint[CPTCoordinateY] = [self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.y) linearPlotRange:dominantRange boundsLength:plotArea.heightDecimal];
            break;
            
        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateX] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:dominantRange boundsLength:boundsSize.width]);
            plotPoint[CPTCoordinateY] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:dominantRange boundsLength:boundsSize.height]);
            break;
            
        case CPTScaleTypeLogModulus:
            plotPoint[CPTCoordinateX] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:dominantRange boundsLength:boundsSize.width]);
            plotPoint[CPTCoordinateY] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:dominantRange boundsLength:boundsSize.height]);
            break;
            
        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
    }
    
//    switch ( self.majorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            plotPoint[CPTCoordinateX] = [self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.x) linearPlotRange:self.majorRange boundsLength:plotArea.widthDecimal];
//            break;
//
//        case CPTScaleTypeLog:
//            plotPoint[CPTCoordinateX] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.majorRange boundsLength:boundsSize.width]);
//            break;
//
//        case CPTScaleTypeLogModulus:
//            plotPoint[CPTCoordinateX] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:self.majorRange boundsLength:boundsSize.width]);
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
//
//    switch ( self.minorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            plotPoint[CPTCoordinateY] = [self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.y) linearPlotRange:self.minorRange boundsLength:plotArea.heightDecimal];
//            break;
//
//        case CPTScaleTypeLog:
//            plotPoint[CPTCoordinateY] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.minorRange boundsLength:boundsSize.height]);
//            break;
//
//        case CPTScaleTypeLogModulus:
//            plotPoint[CPTCoordinateY] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:self.minorRange boundsLength:boundsSize.height]);
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
}

-(void)doublePrecisionPlotPoint:(nonnull double *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point
{
    [super doublePrecisionPlotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:point];
    
    CGSize boundsSize;
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    
    if ( plotArea ) {
        boundsSize = plotArea.bounds.size;
    }
    else {
        plotPoint[CPTCoordinateX] = 0.0;
        plotPoint[CPTCoordinateY] = 0.0;
        return;
    }
    
    CPTPlotRange *dominantRange = self.majorRange.lengthDouble > self.minorRange.lengthDouble ? self.majorRange : self.minorRange;
    CPTScaleType dominantScaleType = self.majorRange.lengthDouble > self.minorRange.lengthDouble ?  self.majorScaleType : self.minorScaleType;
    
    switch ( dominantScaleType ) {
        case CPTScaleTypeLinear:
        case CPTScaleTypeCategory:
            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x linearPlotRange:dominantRange boundsLength:boundsSize.width];
            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y linearPlotRange:dominantRange boundsLength:boundsSize.height];
            break;
            
        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:dominantRange boundsLength:boundsSize.width];
            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:dominantRange boundsLength:boundsSize.height];
            break;
            
        case CPTScaleTypeLogModulus:
            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:dominantRange boundsLength:boundsSize.width];
            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:dominantRange boundsLength:boundsSize.height];
            break;
            
        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
    }
    
//    switch ( self.majorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x linearPlotRange:self.majorRange boundsLength:boundsSize.width];
//            break;
//
//        case CPTScaleTypeLog:
//            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.majorRange boundsLength:boundsSize.width];
//            break;
//
//        case CPTScaleTypeLogModulus:
//            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:self.majorRange boundsLength:boundsSize.width];
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
//    }
//
//    switch ( self.minorScaleType ) {
//        case CPTScaleTypeLinear:
//        case CPTScaleTypeCategory:
//            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y linearPlotRange:self.minorRange boundsLength:boundsSize.height];
//            break;
//
//        case CPTScaleTypeLog:
//            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.minorRange boundsLength:boundsSize.height];
//            break;
//
//        case CPTScaleTypeLogModulus:
//            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:self.minorRange boundsLength:boundsSize.height];
//            break;
//
//        default:
//            [NSException raise:CPTException format:@"Scale type not supported in CPTPolarPlotSpace"];
//    }
}

// Plot area view point for event
-(CGPoint)plotAreaViewPointForEvent:(nonnull CPTNativeEvent *)event
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
-(CPTNumberArray*)plotPointForEvent:(nonnull CPTNativeEvent *)event
{
    return [self plotPointForPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
}

-(void)plotPoint:(nonnull NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(nonnull CPTNativeEvent *)event
{
    [self plotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
}

-(void)doublePrecisionPlotPoint:(nonnull double *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(nonnull CPTNativeEvent *)event
{
    [self doublePrecisionPlotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
}

/// @endcond

#pragma mark -
#pragma mark Scaling

/// @cond

-(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)plotAreaPoint
{
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    
    if ( !plotArea || ((double)interactionScale <= 1.e-6) ) {
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
    CPTPlotRange *oldRangeX = self.majorRange;
    CPTPlotRange *oldRangeY = self.minorRange;
    
    // Lengths are scaled by the pinch gesture inverse proportional
    NSDecimal newLengthX = CPTDecimalDivide(oldRangeX.lengthDecimal, decimalScale);
    NSDecimal newLengthY = CPTDecimalDivide(oldRangeY.lengthDecimal, decimalScale);
    
    // New locations
    NSDecimal newLocationX;
    if ( CPTDecimalGreaterThanOrEqualTo( oldRangeX.lengthDecimal, CPTDecimalFromInteger(0) ) ) {
        NSDecimal oldFirstLengthX = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateX], oldRangeX.minLimitDecimal); // x - minX
        NSDecimal newFirstLengthX = CPTDecimalDivide(oldFirstLengthX, decimalScale);                                     // (x - minX) / scale
        newLocationX = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateX], newFirstLengthX);
    }
    else {
        NSDecimal oldSecondLengthX = CPTDecimalSubtract(oldRangeX.maxLimitDecimal, plotInteractionPoint[0]); // maxX - x
        NSDecimal newSecondLengthX = CPTDecimalDivide(oldSecondLengthX, decimalScale);                       // (maxX - x) / scale
        newLocationX = CPTDecimalAdd(plotInteractionPoint[CPTCoordinateX], newSecondLengthX);
    }
    
    NSDecimal newLocationY;
    if ( CPTDecimalGreaterThanOrEqualTo( oldRangeY.lengthDecimal, CPTDecimalFromInteger(0) ) ) {
        NSDecimal oldFirstLengthY = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateY], oldRangeY.minLimitDecimal); // y - minY
        NSDecimal newFirstLengthY = CPTDecimalDivide(oldFirstLengthY, decimalScale);                                     // (y - minY) / scale
        newLocationY = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateY], newFirstLengthY);
    }
    else {
        NSDecimal oldSecondLengthY = CPTDecimalSubtract(oldRangeY.maxLimitDecimal, plotInteractionPoint[1]); // maxY - y
        NSDecimal newSecondLengthY = CPTDecimalDivide(oldSecondLengthY, decimalScale);                       // (maxY - y) / scale
        newLocationY = CPTDecimalAdd(plotInteractionPoint[CPTCoordinateY], newSecondLengthY);
    }
    
    // New ranges
    CPTPlotRange *newRangeX = [[CPTPlotRange alloc] initWithLocationDecimal:newLocationX lengthDecimal:newLengthX];
    CPTPlotRange *newRangeY = [[CPTPlotRange alloc] initWithLocationDecimal:newLocationY lengthDecimal:newLengthY];
    
    BOOL oldMomentum = self.allowsMomentumMajor;
    self.allowsMomentumMajor = NO;
    self.majorRange          = newRangeX;
    self.allowsMomentumMajor = oldMomentum;
    
    oldMomentum          = self.allowsMomentumMinor;
    self.allowsMomentumMinor = NO;
    self.minorRange          = newRangeY;
    self.allowsMomentumMinor = oldMomentum;
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
-(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    self.isDragging = NO;
    
    BOOL handledByDelegate = [super pointingDeviceDownEvent:event atPoint:interactionPoint];
    if ( handledByDelegate ) {
        return YES;
    }
    
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    if ( !self.allowsUserInteraction || !plotArea ) {
        return NO;
    }
    
    CGPoint pointInPlotArea = [theGraph convertPoint:interactionPoint toLayer:plotArea];
    if ( [plotArea containsPoint:pointInPlotArea] ) {
        // Handle event
        self.lastDragPoint    = pointInPlotArea;
        self.lastDisplacement = CGPointZero;
        self.lastDragTime     = event.timestamp;
        self.lastDeltaTime    = 0.0;
        
        // Clear any previous animations
        CPTMutableAnimationArray animationArray = self.animations;
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
-(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = [super pointingDeviceUpEvent:event atPoint:interactionPoint];
    
    if ( handledByDelegate ) {
        return YES;
    }
    
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
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
                CGPoint pointInPlotArea = [theGraph convertPoint:interactionPoint toLayer:plotArea];
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
                
                if ( self.allowsMomentumMajor ) {
                    shiftX = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
                }
                if ( self.allowsMomentumMinor ) {
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
 *  Otherwise, if a drag operation commences or is in progress, the @ref majorRange
 *  and @ref minorRange are shifted to follow the drag and
 *  this method returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];
    
    if ( handledByDelegate ) {
        return YES;
    }
    
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    if ( !self.allowsUserInteraction || !plotArea ) {
        return NO;
    }
    
    CGPoint lastDraggedPoint = self.lastDragPoint;
    CGPoint pointInPlotArea  = [theGraph convertPoint:interactionPoint toLayer:plotArea];
    CGPoint displacement     = CPTPointMake(pointInPlotArea.x - lastDraggedPoint.x, pointInPlotArea.y - lastDraggedPoint.y);
    
    if ( !self.isDragging ) {
        // Have we started dragging, i.e., has the interactionPoint moved sufficiently to indicate a drag has started?
        CGFloat displacedBy = sqrt(displacement.x * displacement.x + displacement.y * displacement.y);
        self.isDragging = (displacedBy > self.minimumDisplacementToDrag);
    }
    
    if ( self.isDragging ) {
        CGPoint pointToUse = pointInPlotArea;
        
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
        CPTPlotRange *newRangeX = [self shiftRange:self.majorRange
                                                by:shiftX
                                     usingMomentum:self.allowsMomentumMajor
                                     inGlobalRange:self.globalMajorRange
                                  withDisplacement:&displacement.x];
        
        // Y range
        NSDecimal shiftY        = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
        CPTPlotRange *newRangeY = [self shiftRange:self.minorRange
                                                by:shiftY
                                     usingMomentum:self.allowsMomentumMinor
                                     inGlobalRange:self.globalMinorRange
                                  withDisplacement:&displacement.y];
        
        self.lastDragPoint    = pointInPlotArea;
        self.lastDisplacement = displacement;
        
        NSTimeInterval currentTime = event.timestamp;
        self.lastDeltaTime = currentTime - self.lastDragTime;
        self.lastDragTime  = currentTime;
        
        self.majorRange = newRangeX;
        self.minorRange = newRangeY;
        
        return YES;
    }
    
    return NO;
}

-(nullable CPTPlotRange *)shiftRange:(nonnull CPTPlotRange *)oldRange by:(NSDecimal)shift usingMomentum:(BOOL)momentum inGlobalRange:(nullable CPTPlotRange *)globalRange withDisplacement:(CGFloat *)displacement
{
    CPTMutablePlotRange *newRange = [oldRange mutableCopy];
    
    newRange.locationDecimal = CPTDecimalAdd(newRange.locationDecimal, shift);
    
    if ( globalRange ) {
        CPTPlotRange *constrainedRange = [self constrainRange:newRange toGlobalRange:globalRange];
        
        if ( momentum ) {
            if ( ![newRange isEqualToRange:constrainedRange] ) {
                // reduce the shift as we get farther outside the global range
                NSDecimal rangeLength = newRange.lengthDecimal;
                
                if ( !CPTDecimalEquals( rangeLength, CPTDecimalFromInteger(0) ) ) {
                    NSDecimal diff = CPTDecimalDivide(CPTDecimalSubtract(constrainedRange.locationDecimal, newRange.locationDecimal), rangeLength);
                    diff = CPTDecimalMax( CPTDecimalMin( CPTDecimalMultiply( diff, CPTDecimalFromDouble(2.5) ), CPTDecimalFromInteger(1) ), CPTDecimalFromInteger(-1) );
                    
                    newRange.locationDecimal = CPTDecimalSubtract( newRange.locationDecimal, CPTDecimalMultiply( shift, CPTDecimalAbs(diff) ) );
                    
                    *displacement = *displacement * ( CPTFloat(1.0) - ABS( CPTDecimalCGFloatValue(diff) ) );
                }
            }
        }
        else {
            newRange = (CPTMutablePlotRange *)constrainedRange;
        }
    }
    
    return newRange;
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

/**
 *  @brief Informs the receiver that the user has moved the scroll wheel.
 *
 *
 *  If the receiver does not have a @ref delegate,
 *  this method always returns @NO. Otherwise, the
 *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint: -plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint: @endlink
 *  delegate method is called. If it returns @NO, this method returns @YES
 *  to indicate that the event has been handled and no further processing should occur.
 *
 *  @param event The OS event.
 *  @param fromPoint The starting coordinates of the interaction.
 *  @param toPoint The ending coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)scrollWheelEvent:(nonnullCPTNativeEvent *)event fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    BOOL handledByDelegate = [super scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint];
    
    if ( handledByDelegate ) {
        return YES;
    }
    
    CPTGraph *theGraph    = self.graph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    if ( !self.allowsUserInteraction || !plotArea ) {
        return NO;
    }
    
    CGPoint fromPointInPlotArea = [theGraph convertPoint:fromPoint toLayer:plotArea];
    CGPoint toPointInPlotArea   = [theGraph convertPoint:toPoint toLayer:plotArea];
    CGPoint displacement        = CPTPointMake(toPointInPlotArea.x - fromPointInPlotArea.x, toPointInPlotArea.y - fromPointInPlotArea.y);
    CGPoint pointToUse          = toPointInPlotArea;
    
    id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
    
    // Allow delegate to override
    if ( [theDelegate respondsToSelector:@selector(plotSpace:willDisplaceBy:)] ) {
        displacement = [theDelegate plotSpace:self willDisplaceBy:displacement];
        pointToUse   = CPTPointMake(fromPointInPlotArea.x + displacement.x, fromPointInPlotArea.y + displacement.y);
    }
    
    NSDecimal lastPoint[2], newPoint[2];
    [self plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:fromPointInPlotArea];
    [self plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointToUse];
    
    // X range
    NSDecimal shiftX        = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
    CPTPlotRange *newRangeX = [self shiftRange:self.majorRange
                                            by:shiftX
                                 usingMomentum:NO
                                 inGlobalRange:self.globalMajorRange
                              withDisplacement:&displacement.x];
    
    // Y range
    NSDecimal shiftY        = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
    CPTPlotRange *newRangeY = [self shiftRange:self.minorRange
                                            by:shiftY
                                 usingMomentum:NO
                                 inGlobalRange:self.globalMinorRange
                              withDisplacement:&displacement.y];
    
    self.majorRange = newRangeX;
    self.minorRange = newRangeY;
    
    return YES;
}
#endif

/// @}

/**
 *  @brief Reset the dragging state and cancel any active animations.
 **/
-(void)cancelAnimations
{
    self.isDragging = NO;
    for ( CPTAnimationOperation *op in self.animations ) {
        [[CPTAnimation sharedInstance] removeAnimationOperation:op];
    }
}

/// @}

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setAllowsMomentum:(BOOL)newMomentum
{
    self.allowsMomentumMajor = newMomentum;
    self.allowsMomentumMinor = newMomentum;
}

-(BOOL)allowsMomentum
{
    return self.allowsMomentumMajor || self.allowsMomentumMinor;
}

// Added S.Wainwright 18/06/2020

-(void)setRadialAngleOption:(CPTPolarRadialAngleMode)newOption
{
    radialAngleOption = newOption;
    if(newOption == CPTPolarRadialAngleModeDegrees) {
        self.radialRange = [[CPTPlotRange alloc] initWithLocation:@0.0 length:@360.0];
    }
    else {
        self.radialRange = [[CPTPlotRange alloc] initWithLocation:@0.0 length:@(2.0 * M_PI)];
    }
}

-(CPTPolarRadialAngleMode)getRadialAngleOption
{
    return self.radialAngleOption;
}

/// @endcond

#pragma mark -
#pragma mark Animation Delegate

/// @cond

-(void)animationDidFinish:(nonnull CPTAnimationOperation *)operation
{
    [self.animations removeObjectIdenticalTo:operation];
}

/// @endcond

#pragma mark -
#pragma mark Debugging

/// @cond

-(nullable id)debugQuickLookObject
{
    // Plot space
    NSString *plotAreaDesc = [super debugQuickLookObject];
    
    // X-range
    NSString *majorScaleTypeDesc = nil;
    
    switch ( self.majorScaleType ) {
        case CPTScaleTypeLinear:
            majorScaleTypeDesc = @"CPTScaleTypeLinear";
            break;
            
        case CPTScaleTypeLog:
            majorScaleTypeDesc = @"CPTScaleTypeLog";
            break;
            
        case CPTScaleTypeLogModulus:
            majorScaleTypeDesc = @"CPTScaleTypeLogModulus";
            break;
            
        case CPTScaleTypeAngular:
            majorScaleTypeDesc = @"CPTScaleTypeAngular";
            break;
            
        case CPTScaleTypeDateTime:
            majorScaleTypeDesc = @"CPTScaleTypeDateTime";
            break;
            
        case CPTScaleTypeCategory:
            majorScaleTypeDesc = @"CPTScaleTypeCategory";
            break;
    }
    
    NSString *majorRangeDesc = [NSString stringWithFormat:@"majorRange:\n%@\nglobalMajorRange:\n%@\nmajorScaleType: %@",
                            [self.majorRange debugQuickLookObject],
                            [self.globalMajorRange debugQuickLookObject],
                            majorScaleTypeDesc];
    
    // Y-range
    NSString *minorScaleTypeDesc = nil;
    
    switch ( self.minorScaleType ) {
        case CPTScaleTypeLinear:
            minorScaleTypeDesc = @"CPTScaleTypeLinear";
            break;
            
        case CPTScaleTypeLog:
            minorScaleTypeDesc = @"CPTScaleTypeLog";
            break;
            
        case CPTScaleTypeLogModulus:
            minorScaleTypeDesc = @"CPTScaleTypeLogModulus";
            break;
            
        case CPTScaleTypeAngular:
            minorScaleTypeDesc = @"CPTScaleTypeAngular";
            break;
            
        case CPTScaleTypeDateTime:
            minorScaleTypeDesc = @"CPTScaleTypeDateTime";
            break;
            
        case CPTScaleTypeCategory:
            minorScaleTypeDesc = @"CPTScaleTypeCategory";
            break;
    }
    
    NSString *minorRangeDesc = [NSString stringWithFormat:@"minorRange:\n%@\nglobalMinorRange:\n%@\nminorScaleType: %@",
                            [self.minorRange debugQuickLookObject],
                            [self.globalMinorRange debugQuickLookObject],
                            minorScaleTypeDesc];
    
    NSString *radialRangeDesc = [NSString stringWithFormat:@"radialRange:\n%@\nradialScaleType: %@",
                                [self.radialRange debugQuickLookObject],
                                @"CPTScaleTypeLinear"];
    
    return [NSString stringWithFormat:@"%@\n\nMajor:\n%@\n\nMinor:\n%@\n\nTheta:\%@", plotAreaDesc, majorRangeDesc, minorRangeDesc, radialRangeDesc];
}

/// @endcond

@end
