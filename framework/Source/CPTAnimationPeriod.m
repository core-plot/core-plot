#import "CPTAnimationPeriod.h"

#import "CPTAnimationOperation.h"
#import "CPTPlotRange.h"
#import "NSNumberExtensions.h"
#import "_CPTAnimationCGFloatPeriod.h"
#import "_CPTAnimationCGPointPeriod.h"
#import "_CPTAnimationCGRectPeriod.h"
#import "_CPTAnimationCGSizePeriod.h"
#import "_CPTAnimationNSDecimalPeriod.h"
#import "_CPTAnimationPlotRangePeriod.h"

/// @cond
@interface CPTAnimationPeriod()

+(id)periodWithStartValue:(NSValue *)aStartValue endValue:(NSValue *)anEndValue duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;

-(id)initWithStartValue:(NSValue *)aStartValue endValue:(NSValue *)anEndValue duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;

@property (nonatomic, readwrite) CGFloat startOffset;

@end
/// @endcond

#pragma mark -

/** @brief Animation timing information and animated values.
 *
 *  The starting and ending values of the animation can be any of the following types
 *  wrapped in an NSValue instance:
 *  - @ref CGFloat
 *  - @ref CGPoint
 *  - @ref CGSize
 *  - @ref CGRect
 *  - @ref NSDecimal
 *  - @ref CPTPlotRange (NSValue wrapper not used)
 *  @note The starting and ending values must be the same type.
 **/
@implementation CPTAnimationPeriod

/** @property NSValue *startValue
 *  @brief The starting value of the animation.
 *
 *  If @nil or the encoded value is @NAN, the animation starts from the current value of the animated property.
 **/
@synthesize startValue;

/** @property NSValue *endValue
 *  @brief The ending value of the animation.
 **/
@synthesize endValue;

/** @property CGFloat duration
 *  @brief The duration of the animation, in seconds.
 **/
@synthesize duration;

/** @property CGFloat delay
 *  @brief The delay in seconds between the @ref startOffset and the time the animation will start.
 *  If @NAN, the animation will not start until the current value of the bound property is between @ref startValue and @ref endValue.
 **/
@synthesize delay;

/** @property CGFloat startOffset
 *  @brief The animation time clock offset when the receiver was created.
 **/
@synthesize startOffset;

#pragma mark -
#pragma mark Factory Methods

/// @cond

/** @internal
 *  @brief Creates and returns a new CPTAnimationPeriod instance initialized with the provided start and end values and duration.
 *  @param aStartValue The starting value. If @nil, the animation starts from the current value of the animated property.
 *  @param anEndValue The ending value.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
+(id)periodWithStartValue:(NSValue *)aStartValue endValue:(NSValue *)anEndValue duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    return [[[self alloc] initWithStartValue:aStartValue endValue:anEndValue duration:aDuration withDelay:aDelay] autorelease];
}

/// @endcond

/**
 *  @brief Creates and returns a new CPTAnimationPeriod instance initialized with the provided start and end values and duration.
 *  @param aStart The starting value. If @NAN, the animation starts from the current value of the animated property.
 *  @param anEnd The ending value.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
+(id)periodWithStart:(CGFloat)aStart end:(CGFloat)anEnd duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    NSNumber *start = isnan(aStart) ? nil : [NSNumber numberWithCGFloat:aStart];

    return [_CPTAnimationCGFloatPeriod periodWithStartValue:start
                                                   endValue:[NSNumber numberWithCGFloat:anEnd]
                                                   duration:aDuration
                                                  withDelay:aDelay];
}

/**
 *  @brief Creates and returns a new CPTAnimationPeriod instance initialized with the provided start and end points and duration.
 *  @param aStartPoint The starting point. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param anEndPoint The ending point.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
+(id)periodWithStartPoint:(CGPoint)aStartPoint endPoint:(CGPoint)anEndPoint duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    NSValue *start = nil;

    if ( !isnan(aStartPoint.x) && !isnan(aStartPoint.y) ) {
        start = [NSValue valueWithBytes:&aStartPoint objCType:@encode(CGPoint)];
    }

    return [_CPTAnimationCGPointPeriod periodWithStartValue:start
                                                   endValue:[NSValue valueWithBytes:&anEndPoint objCType:@encode(CGPoint)]
                                                   duration:aDuration
                                                  withDelay:aDelay];
}

/**
 *  @brief Creates and returns a new CPTAnimationPeriod instance initialized with the provided start and end sizes and duration.
 *  @param aStartSize The starting size. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param anEndSize The ending size.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
+(id)periodWithStartSize:(CGSize)aStartSize endSize:(CGSize)anEndSize duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    NSValue *start = nil;

    if ( !isnan(aStartSize.width) && !isnan(aStartSize.height) ) {
        start = [NSValue valueWithBytes:&aStartSize objCType:@encode(CGSize)];
    }

    return [_CPTAnimationCGSizePeriod periodWithStartValue:start
                                                  endValue:[NSValue valueWithBytes:&anEndSize objCType:@encode(CGSize)]
                                                  duration:aDuration
                                                 withDelay:aDelay];
}

/**
 *  @brief Creates and returns a new CPTAnimationPeriod instance initialized with the provided start and end rectangles and duration.
 *  @param aStartRect The starting rectangle. If @ref CGRectNull or any field is @NAN, the animation starts from the current value of the animated property.
 *  @param anEndRect The ending rectangle.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
+(id)periodWithStartRect:(CGRect)aStartRect endRect:(CGRect)anEndRect duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    NSValue *start = nil;

    if ( !CGRectEqualToRect(aStartRect, CGRectNull) && !isnan(aStartRect.origin.x) && !isnan(aStartRect.origin.y) && !isnan(aStartRect.size.width) && !isnan(aStartRect.size.height) ) {
        start = [NSValue valueWithBytes:&aStartRect objCType:@encode(CGRect)];
    }

    return [_CPTAnimationCGRectPeriod periodWithStartValue:start
                                                  endValue:[NSValue valueWithBytes:&anEndRect objCType:@encode(CGRect)]
                                                  duration:aDuration
                                                 withDelay:aDelay];
}

/**
 *  @brief Creates and returns a new CPTAnimationPeriod instance initialized with the provided start and end values and duration.
 *  @param aStartDecimal The starting value. If @NAN, the animation starts from the current value of the animated property.
 *  @param anEndDecimal The ending value.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
+(id)periodWithStartDecimal:(NSDecimal)aStartDecimal endDecimal:(NSDecimal)anEndDecimal duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    NSDecimalNumber *start = NSDecimalIsNotANumber(&aStartDecimal) ? nil : [NSDecimalNumber decimalNumberWithDecimal:aStartDecimal];

    return [_CPTAnimationNSDecimalPeriod periodWithStartValue:start
                                                     endValue:[NSDecimalNumber decimalNumberWithDecimal:anEndDecimal]
                                                     duration:aDuration
                                                    withDelay:aDelay];
}

/**
 *  @brief Creates and returns a new CPTAnimationPeriod instance initialized with the provided start and end plot ranges and duration.
 *  @param aStartPlotRange The starting plot range. If @nil or any component of the range is @NAN, the animation starts from the current value of the animated property.
 *  @param anEndPlotRange The ending plot range.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
+(id)periodWithStartPlotRange:(CPTPlotRange *)aStartPlotRange endPlotRange:(CPTPlotRange *)anEndPlotRange duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    if ( isnan(aStartPlotRange.locationDouble) || isnan(aStartPlotRange.lengthDouble) ) {
        aStartPlotRange = nil;
    }

    return [_CPTAnimationPlotRangePeriod periodWithStartValue:(NSValue *)aStartPlotRange
                                                     endValue:(NSValue *)anEndPlotRange
                                                     duration:aDuration
                                                    withDelay:aDelay];
}

/// @cond

/** @internal
 *  @brief Initializes a newly allocated CPTAnimationPeriod object with the provided start and end values and duration.
 *
 *  This is the designated initializer. The initialized object will have the following properties:
 *  - @ref startValue = @par{aStartValue}
 *  - @ref endValue = @par{anEndValue}
 *  - @ref duration = @par{aDuration}
 *  - @ref delay = @par{aDelay}
 *  - @ref startOffset = The animation time clock offset when this method is called.
 *
 *  @param aStartValue The starting value. If @nil, the animation starts from the current value of the animated property.
 *  @param anEndValue The ending value.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
-(id)initWithStartValue:(NSValue *)aStartValue endValue:(NSValue *)anEndValue duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    if ( (self = [super init]) ) {
        startValue  = [aStartValue copy];
        endValue    = [anEndValue copy];
        duration    = aDuration;
        delay       = aDelay;
        startOffset = [CPTAnimation sharedInstance].timeOffset;
    }

    return self;
}

/// @endcond

/**
 *  @brief Initializes a newly allocated CPTAnimationPeriod object with the provided start and end values and duration.
 *  @param aStart The starting value. If @NAN, the animation starts from the current value of the animated property.
 *  @param anEnd The ending value.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
-(id)initWithStart:(CGFloat)aStart end:(CGFloat)anEnd duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    [self release];

    NSNumber *start = isnan(aStart) ? nil : [NSNumber numberWithCGFloat:aStart];

    self = [(_CPTAnimationCGFloatPeriod *)[_CPTAnimationCGFloatPeriod alloc] initWithStartValue : start
            endValue :[NSNumber numberWithCGFloat:anEnd]
            duration : aDuration
            withDelay : aDelay];

    return self;
}

/**
 *  @brief Initializes a newly allocated CPTAnimationPeriod object with the provided start and end points and duration.
 *  @param aStartPoint The starting point. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param anEndPoint The ending point.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
-(id)initWithStartPoint:(CGPoint)aStartPoint endPoint:(CGPoint)anEndPoint duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    [self release];

    NSValue *start = nil;

    if ( !isnan(aStartPoint.x) && !isnan(aStartPoint.y) ) {
        start = [NSValue valueWithBytes:&aStartPoint objCType:@encode(CGPoint)];
    }

    self = [(_CPTAnimationCGPointPeriod *)[_CPTAnimationCGPointPeriod alloc] initWithStartValue : start
            endValue :[NSValue valueWithBytes:&anEndPoint objCType:@encode(CGPoint)]
            duration : aDuration
            withDelay : aDelay];

    return self;
}

/**
 *  @brief Initializes a newly allocated CPTAnimationPeriod object with the provided start and end sizes and duration.
 *  @param aStartSize The starting size. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param anEndSize The ending size.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
-(id)initWithStartSize:(CGSize)aStartSize endSize:(CGSize)anEndSize duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    [self release];

    NSValue *start = nil;

    if ( !isnan(aStartSize.width) && !isnan(aStartSize.height) ) {
        start = [NSValue valueWithBytes:&aStartSize objCType:@encode(CGSize)];
    }

    self = [(_CPTAnimationCGSizePeriod *)[_CPTAnimationCGSizePeriod alloc] initWithStartValue : start
            endValue :[NSValue valueWithBytes:&anEndSize objCType:@encode(CGSize)]
            duration : aDuration
            withDelay : aDelay];

    return self;
}

/**
 *  @brief Initializes a newly allocated CPTAnimationPeriod object with the provided start and end rectangles and duration.
 *  @param aStartRect The starting rectangle. If @ref CGRectNull or any field is @NAN, the animation starts from the current value of the animated property.
 *  @param anEndRect The ending rectangle.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
-(id)initWithStartRect:(CGRect)aStartRect endRect:(CGRect)anEndRect duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    [self release];

    NSValue *start = nil;

    if ( !CGRectEqualToRect(aStartRect, CGRectNull) && !isnan(aStartRect.origin.x) && !isnan(aStartRect.origin.y) && !isnan(aStartRect.size.width) && !isnan(aStartRect.size.height) ) {
        start = [NSValue valueWithBytes:&aStartRect objCType:@encode(CGRect)];
    }

    self = [(_CPTAnimationCGRectPeriod *)[_CPTAnimationCGRectPeriod alloc] initWithStartValue : start
            endValue :[NSValue valueWithBytes:&anEndRect objCType:@encode(CGRect)]
            duration : aDuration
            withDelay : aDelay];

    return self;
}

/**
 *  @brief Initializes a newly allocated CPTAnimationPeriod object with the provided start and end values and duration.
 *  @param aStartDecimal The starting value. If @NAN, the animation starts from the current value of the animated property.
 *  @param anEndDecimal The ending value.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
-(id)initWithStartDecimal:(NSDecimal)aStartDecimal endDecimal:(NSDecimal)anEndDecimal duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    [self release];

    NSDecimalNumber *start = NSDecimalIsNotANumber(&aStartDecimal) ? nil : [NSDecimalNumber decimalNumberWithDecimal:aStartDecimal];

    self = [(_CPTAnimationNSDecimalPeriod *)[_CPTAnimationNSDecimalPeriod alloc] initWithStartValue : start
            endValue :[NSDecimalNumber decimalNumberWithDecimal:anEndDecimal]
            duration : aDuration
            withDelay : aDelay];

    return self;
}

/**
 *  @brief Initializes a newly allocated CPTAnimationPeriod object with the provided start and end plot ranges and duration.
 *  @param aStartPlotRange The starting plot range. If @nil or any component of the range is @NAN, the animation starts from the current value of the animated property.
 *  @param anEndPlotRange The ending plot range.
 *  @param aDuration The animation duration in seconds.
 *  @param aDelay The starting delay in seconds.
 *  @return The initialized object.
 **/
-(id)initWithStartPlotRange:(CPTPlotRange *)aStartPlotRange endPlotRange:(CPTPlotRange *)anEndPlotRange duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay
{
    [self release];

    if ( isnan(aStartPlotRange.locationDouble) || isnan(aStartPlotRange.lengthDouble) ) {
        aStartPlotRange = nil;
    }

    self = [(_CPTAnimationPlotRangePeriod *)[_CPTAnimationPlotRangePeriod alloc] initWithStartValue : (NSValue *)aStartPlotRange
            endValue : (NSValue *)anEndPlotRange
            duration : aDuration
            withDelay : aDelay];

    return self;
}

/// @cond

/** @brief Initializes a newly allocated CPTAnimationPeriod object with no start or end values and a @par{duration} and @par{delay} of zero (@num{0}).
 *  @return The initialized object.
 **/
-(id)init
{
    return [self initWithStartValue:nil endValue:nil duration:CPTFloat(0.0) withDelay:CPTFloat(0.0)];
}

/// @endcond

#pragma mark -
#pragma mark Abstract Methods

/**
 *  @brief Initialize the start value from the property getter.
 *  @param boundObject The object to update for each animation frame.
 *  @param boundGetter The getter method for the property to update.
 **/
-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    [NSException raise:NSGenericException
                format:@"The -initializeStartValue method must be implemented by CPTAnimationPeriod subclasses."];
}

/** @brief Calculates a value between @link CPTAnimationPeriod::startValue startValue @endlink and @link CPTAnimationPeriod::endValue endValue @endlink.
 *
 *  A @par{progress} value of zero (@num{0}) returns the @link CPTAnimationPeriod::startValue startValue @endlink and
 *  a value of one (@num{1}) returns the @link CPTAnimationPeriod::endValue endValue @endlink.
 *
 *  @param progress The fraction of the animation progress.
 *  @return The computed value.
 **/
-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    [NSException raise:NSGenericException
                format:@"The -tweenedValueForProgress: method must be implemented by CPTAnimationPeriod subclasses."];
    return nil;
}

/**
 *  @brief Determines if the current value of the bound property is between the start and end value.
 *  @param boundObject The object to update for each animation frame.
 *  @param boundGetter The getter method for the property to update.
 *  @return @YES if the current value of the bound property is between the start and end value.
 **/
-(BOOL)canStartWithValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    [NSException raise:NSGenericException
                format:@"The -canStartWithValueFromObject:propertyGetter: method must be implemented by CPTAnimationPeriod subclasses."];
    return NO;
}

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ from: %@; to: %@; duration: %g, delay: %g>", [super description], self.startValue, self.endValue, self.duration, self.delay];
}

-(void)dealloc
{
    [startValue release];
    [endValue release];
    [super dealloc];
}

/// @endcond

@end

#pragma mark -

@implementation CPTAnimation(CPTAnimationPeriodAdditions)

// CGFloat

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting value for the animation. If @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending value for the animation.
 *  @param duration The duration of the animation.
 *  @param delay The starting delay of the animation in seconds.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStart:from
                                                                 end:to
                                                            duration:duration
                                                           withDelay:delay];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting value for the animation. If @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending value for the animation.
 *  @param duration The duration of the animation.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStart:from
                                                                 end:to
                                                            duration:duration
                                                           withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting value for the animation. If @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending value for the animation.
 *  @param duration The duration of the animation.
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStart:from
                                                                 end:to
                                                            duration:duration
                                                           withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:CPTAnimationCurveDefault
                  delegate:nil];
}

// CGPoint

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting point for the animation. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending point for the animation.
 *  @param duration The duration of the animation.
 *  @param delay The starting delay of the animation in seconds.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartPoint:from
                                                                 endPoint:to
                                                                 duration:duration
                                                                withDelay:delay];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting point for the animation. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending point for the animation.
 *  @param duration The duration of the animation.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartPoint:from
                                                                 endPoint:to
                                                                 duration:duration
                                                                withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting point for the animation. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending point for the animation.
 *  @param duration The duration of the animation.
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartPoint:from
                                                                 endPoint:to
                                                                 duration:duration
                                                                withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:CPTAnimationCurveDefault
                  delegate:nil];
}

// CGSize

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting size for the animation. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending size for the animation.
 *  @param duration The duration of the animation.
 *  @param delay The starting delay of the animation in seconds.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartSize:from
                                                                 endSize:to
                                                                duration:duration
                                                               withDelay:delay];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting size for the animation. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending size for the animation.
 *  @param duration The duration of the animation.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartSize:from
                                                                 endSize:to
                                                                duration:duration
                                                               withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting size for the animation. If either coordinate is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending size for the animation.
 *  @param duration The duration of the animation.
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartSize:from
                                                                 endSize:to
                                                                duration:duration
                                                               withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:CPTAnimationCurveDefault
                  delegate:nil];
}

// CGRect

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting rectangle for the animation. If @ref CGRectNull or any field is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending rectangle for the animation.
 *  @param duration The duration of the animation.
 *  @param delay The starting delay of the animation in seconds.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartRect:from
                                                                 endRect:to
                                                                duration:duration
                                                               withDelay:delay];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting rectangle for the animation. If @ref CGRectNull or any field is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending rectangle for the animation.
 *  @param duration The duration of the animation.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartRect:from
                                                                 endRect:to
                                                                duration:duration
                                                               withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting rectangle for the animation. If @ref CGRectNull or any field is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending rectangle for the animation.
 *  @param duration The duration of the animation.
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartRect:from
                                                                 endRect:to
                                                                duration:duration
                                                               withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:CPTAnimationCurveDefault
                  delegate:nil];
}

// NSDecimal

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting value for the animation. If @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending value for the animation.
 *  @param duration The duration of the animation.
 *  @param delay The starting delay of the animation in seconds.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartDecimal:from
                                                                 endDecimal:to
                                                                   duration:duration
                                                                  withDelay:delay];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting value for the animation. If @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending value for the animation.
 *  @param duration The duration of the animation.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartDecimal:from
                                                                 endDecimal:to
                                                                   duration:duration
                                                                  withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting value for the animation. If @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending value for the animation.
 *  @param duration The duration of the animation.
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartDecimal:from
                                                                 endDecimal:to
                                                                   duration:duration
                                                                  withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:CPTAnimationCurveDefault
                  delegate:nil];
}

// CPTPlotRange

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting plot range for the animation. If @nil or any component of the range is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending plot range for the animation.
 *  @param duration The duration of the animation.
 *  @param delay The starting delay of the animation in seconds.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartPlotRange:from
                                                                 endPlotRange:to
                                                                     duration:duration
                                                                    withDelay:delay];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting plot range for the animation. If @nil or any component of the range is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending plot range for the animation.
 *  @param duration The duration of the animation.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartPlotRange:from
                                                                 endPlotRange:to
                                                                     duration:duration
                                                                    withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:animationCurve
                  delegate:delegate
    ];
}

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param from The starting plot range for the animation. If @nil or any component of the range is @NAN, the animation starts from the current value of the animated property.
 *  @param to The ending plot range for the animation.
 *  @param duration The duration of the animation.
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration
{
    CPTAnimationPeriod *period = [CPTAnimationPeriod periodWithStartPlotRange:from
                                                                 endPlotRange:to
                                                                     duration:duration
                                                                    withDelay:CPTFloat(0.0)];

    return [self animate:object
                  property:property
                    period:period
            animationCurve:CPTAnimationCurveDefault
                  delegate:nil];
}

@end
