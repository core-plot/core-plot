#import "CPTAnimation.h"

#import "CPTAnimationOperation.h"
#import "CPTAnimationPeriod.h"
#import "_CPTAnimationTimingFunctions.h"

static const CGFloat kCPTAnimationFrameRate = CPTFloat(1.0 / 60.0); // 60 frames per second

static CPTAnimation *instance = nil;

/// @cond
@interface CPTAnimation()

@property (nonatomic, readwrite, assign) CGFloat timeOffset;
@property (nonatomic, readwrite, retain) NSMutableArray *animationOperations;
@property (nonatomic, readwrite, retain) NSMutableArray *runningAnimationOperations;
@property (nonatomic, readwrite, retain) NSMutableArray *expiredAnimationOperations;
@property (nonatomic, readwrite, retain) NSTimer *timer;

+(SEL)setterFromProperty:(NSString *)property;

-(CPTAnimationTimingFunction)timingFunctionForAnimationCurve:(CPTAnimationCurve)animationCurve;
-(void)update:(NSTimer *)theTimer;

@end
/// @endcond

#pragma mark -

/** @brief The controller for Core Plot animations.
 *
 *  Many Core Plot objects are subclasses of CALayer and can take advantage of all of the animation support
 *  provided by Core Animation. However, some objects, e.g., plot spaces, cannot be animated by Core Animation.
 *  It also does not support @ref NSDecimal properties that are common throughout Core Plot.
 *
 *  CPTAnimation provides animation support for all of these things. It can animate any property (of the supported data types)
 *  on objects of any class.
 **/
@implementation CPTAnimation

/** @property CGFloat timeOffset
 *  @brief The animation clock. This value is incremented for each frame while animations are running.
 **/
@synthesize timeOffset;

/** @property CPTAnimationCurve defaultAnimationCurve
 *  @brief The animation curve used when an animation operation specifies the #CPTAnimationCurveDefault animation curve.
 **/
@synthesize defaultAnimationCurve;

/** @internal
 *  @property NSMutableArray *animationOperations
 *
 *  @brief The list of animation operations currently running or waiting to run.
 **/
@synthesize animationOperations;

/** @internal
 *  @property NSMutableArray *runningAnimationOperations
 *  @brief The list of running animation operations.
 **/
@synthesize runningAnimationOperations;

/** @internal
 *  @property NSMutableArray *expiredAnimationOperations
 *  @brief The list of completed animation operations.
 *
 *  These operations are removed from @ref animationOperations and the list is cleared after every animation frame.
 **/
@synthesize expiredAnimationOperations;

/** @internal
 *  @property NSTimer *timer
 *  @brief The animation timer. Each tick of the timer corresponds to one animation frame.
 **/
@synthesize timer;

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTAnimation object.
 *
 *  This is the designated initializer. The initialized object will have the following properties:
 *  - @ref timeOffset = @num{0.0}
 *  - @ref defaultAnimationCurve = #CPTAnimationCurveLinear
 *
 *  @return The initialized object.
 **/
-(id)init
{
    if ( (self = [super init]) ) {
        animationOperations        = [[NSMutableArray alloc] init];
        runningAnimationOperations = [[NSMutableArray alloc] init];
        expiredAnimationOperations = [[NSMutableArray alloc] init];
        timer                      = nil;
        timeOffset                 = 0.0;
        defaultAnimationCurve      = CPTAnimationCurveLinear;
    }

    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    for ( CPTAnimationOperation *animationOperation in animationOperations ) {
        NSObject<CPTAnimationDelegate> *animationDelegate = animationOperation.delegate;

        if ( [animationDelegate respondsToSelector:@selector(animationCancelled:)] ) {
            [animationDelegate performSelector:@selector(animationCancelled:)
                                    withObject:animationOperation
                                    afterDelay:0];
        }
    }

    [animationOperations release];
    [runningAnimationOperations release];
    [expiredAnimationOperations release];

    [timer invalidate];
    [timer release];

    [super dealloc];
}

/// @endcond

#pragma mark -

/** @brief A shared CPTAnimation instance responsible for scheduling and executing animations.
 *  @return The shared CPTAnimation instance.
 **/
+(CPTAnimation *)sharedInstance
{
    if ( !instance ) {
        instance = [[CPTAnimation alloc] init];
    }
    return instance;
}

#pragma mark -

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param period The animation period.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property period:(CPTAnimationPeriod *)period animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate
{
    CPTAnimationOperation *animationOperation = [[CPTAnimationOperation alloc] init];

    animationOperation.period         = period;
    animationOperation.animationCurve = animationCurve;
    animationOperation.delegate       = delegate;

    if ( object ) {
        animationOperation.boundObject = object;
        animationOperation.boundGetter = NSSelectorFromString(property);
        animationOperation.boundSetter = [CPTAnimation setterFromProperty:property];

        if ( ![object respondsToSelector:animationOperation.boundGetter] || ![object respondsToSelector:animationOperation.boundSetter] ) {
            animationOperation.boundObject = nil;
            animationOperation.boundGetter = NULL;
            animationOperation.boundSetter = NULL;
        }
    }

    [[CPTAnimation sharedInstance] performSelector:@selector(addAnimationOperation:) withObject:animationOperation afterDelay:0];

    return [animationOperation autorelease];
}

/// @cond

+(SEL)setterFromProperty:(NSString *)property
{
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", [property stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[property substringToIndex:1] capitalizedString]]]);
}

/// @endcond

#pragma mark -

/** @brief Adds an animation operation to the animation queue.
 *  @param animationOperation The animation operation to add.
 *  @return The queued animation operation.
 **/
-(CPTAnimationOperation *)addAnimationOperation:(CPTAnimationOperation *)animationOperation
{
    if ( animationOperation ) {
        [self.animationOperations addObject:animationOperation];

        if ( !self.timer ) {
            self.timer = [NSTimer timerWithTimeInterval:kCPTAnimationFrameRate target:self selector:@selector(update:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
    }

    return animationOperation;
}

/** @brief Removes an animation operation from the animation queue.
 *  @param animationOperation The animation operation to remove.
 **/
-(void)removeAnimationOperation:(CPTAnimationOperation *)animationOperation
{
    if ( animationOperation ) {
        NSMutableArray *theAnimationOperations = self.animationOperations;

        if ( [theAnimationOperations containsObject:animationOperation] ) {
            [self.expiredAnimationOperations addObject:animationOperation];
            [theAnimationOperations removeObject:animationOperation];
        }
    }
}

/** @brief Removes all animation operations from the animation queue.
**/
-(void)removeAllAnimationOperations
{
    NSMutableArray *theAnimationOperations = self.animationOperations;

    [self.expiredAnimationOperations addObjectsFromArray:theAnimationOperations];
    [theAnimationOperations removeAllObjects];
}

#pragma mark -

/// @cond

-(void)update:(NSTimer *)theTimer
{
    self.timeOffset += kCPTAnimationFrameRate;

    NSMutableArray *theAnimationOperations = self.animationOperations;
    NSMutableArray *runningOperations      = self.runningAnimationOperations;
    NSMutableArray *expiredOperations      = self.expiredAnimationOperations;

    CGFloat currentTime = self.timeOffset;
    Class valueClass    = [NSValue class];

    for ( CPTAnimationOperation *animationOperation in theAnimationOperations ) {
        NSObject<CPTAnimationDelegate> *animationDelegate = animationOperation.delegate;

        CPTAnimationPeriod *period = animationOperation.period;

        CGFloat duration  = period.duration;
        CGFloat startTime = period.startOffset + period.delay;
        CGFloat endTime   = startTime + duration;

        if ( currentTime > endTime ) {
            [expiredOperations addObject:animationOperation];

            if ( [animationDelegate respondsToSelector:@selector(animationDidFinish:)] ) {
                [animationDelegate performSelector:@selector(animationDidFinish:)
                                        withObject:animationOperation
                                        afterDelay:0];
            }
        }
        else if ( currentTime >= startTime ) {
            id boundObject = animationOperation.boundObject;

            CPTAnimationTimingFunction timingFunction = [self timingFunctionForAnimationCurve:animationOperation.animationCurve];

            if ( boundObject && timingFunction ) {
                if ( ![runningOperations containsObject:animationOperation] ) {
                    [runningOperations addObject:animationOperation];

                    if ( [animationDelegate respondsToSelector:@selector(animationDidStart:)] ) {
                        [animationDelegate performSelector:@selector(animationDidStart:)
                                                withObject:animationOperation
                                                afterDelay:0];
                    }
                }

                CGFloat progress = timingFunction(currentTime - startTime, duration);

                NSValue *tweenedValue = [period tweenedValueForProgress:progress];
                SEL boundSetter       = animationOperation.boundSetter;

                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[boundObject class] instanceMethodSignatureForSelector:boundSetter]];
                [invocation setTarget:boundObject];
                [invocation setSelector:boundSetter];

                if ( [tweenedValue isKindOfClass:valueClass] ) {
                    NSUInteger bufferSize = 0;
                    NSGetSizeAndAlignment(tweenedValue.objCType, &bufferSize, NULL);

                    void *buffer = malloc(bufferSize);
                    [tweenedValue getValue:buffer];

                    [invocation setArgument:buffer atIndex:2];

                    free(buffer);
                }
                else {
                    [invocation setArgument:&tweenedValue atIndex:2];
                }

                @try {
                    if ( [animationDelegate respondsToSelector:@selector(animationWillUpdate:)] ) {
                        [animationDelegate performSelector:@selector(animationWillUpdate:)
                                                withObject:animationOperation
                                                afterDelay:0];
                    }

                    [invocation invoke];

                    if ( [animationDelegate respondsToSelector:@selector(animationDidUpdate:)] ) {
                        [animationDelegate performSelector:@selector(animationDidUpdate:)
                                                withObject:animationOperation
                                                afterDelay:0];
                    }
                }
                @catch ( NSException *exception ) {
                    // something went wrong; don't run this operation any more
                    [expiredOperations addObject:animationOperation];

                    if ( [animationDelegate respondsToSelector:@selector(animationCancelled:)] ) {
                        [animationDelegate performSelector:@selector(animationCancelled:)
                                                withObject:animationOperation
                                                afterDelay:0];
                    }
                }
            }
        }
    }

    for ( CPTAnimationOperation *animationOperation in expiredOperations ) {
        [runningOperations removeObjectIdenticalTo:animationOperation];
        [theAnimationOperations removeObjectIdenticalTo:animationOperation];
    }

    [expiredOperations removeAllObjects];

    if ( theAnimationOperations.count == 0 ) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

/// @endcond

#pragma mark -

/// @cond

-(CPTAnimationTimingFunction)timingFunctionForAnimationCurve:(CPTAnimationCurve)animationCurve
{
    CPTAnimationTimingFunction timingFunction;

    if ( animationCurve == CPTAnimationCurveDefault ) {
        animationCurve = self.defaultAnimationCurve;
    }

    switch ( animationCurve ) {
        case CPTAnimationCurveLinear:
            timingFunction = CPTAnimationTimingFunctionLinear;
            break;

        case CPTAnimationCurveBackIn:
            timingFunction = CPTAnimationTimingFunctionBackIn;
            break;

        case CPTAnimationCurveBackOut:
            timingFunction = CPTAnimationTimingFunctionBackOut;
            break;

        case CPTAnimationCurveBackInOut:
            timingFunction = CPTAnimationTimingFunctionBackInOut;
            break;

        case CPTAnimationCurveBounceIn:
            timingFunction = CPTAnimationTimingFunctionBounceIn;
            break;

        case CPTAnimationCurveBounceOut:
            timingFunction = CPTAnimationTimingFunctionBounceOut;
            break;

        case CPTAnimationCurveBounceInOut:
            timingFunction = CPTAnimationTimingFunctionBounceInOut;
            break;

        case CPTAnimationCurveCircularIn:
            timingFunction = CPTAnimationTimingFunctionCircularIn;
            break;

        case CPTAnimationCurveCircularOut:
            timingFunction = CPTAnimationTimingFunctionCircularOut;
            break;

        case CPTAnimationCurveCircularInOut:
            timingFunction = CPTAnimationTimingFunctionCircularInOut;
            break;

        case CPTAnimationCurveElasticIn:
            timingFunction = CPTAnimationTimingFunctionElasticIn;
            break;

        case CPTAnimationCurveElasticOut:
            timingFunction = CPTAnimationTimingFunctionElasticOut;
            break;

        case CPTAnimationCurveElasticInOut:
            timingFunction = CPTAnimationTimingFunctionElasticInOut;
            break;

        case CPTAnimationCurveExponentialIn:
            timingFunction = CPTAnimationTimingFunctionExponentialIn;
            break;

        case CPTAnimationCurveExponentialOut:
            timingFunction = CPTAnimationTimingFunctionExponentialOut;
            break;

        case CPTAnimationCurveExponentialInOut:
            timingFunction = CPTAnimationTimingFunctionExponentialInOut;
            break;

        case CPTAnimationCurveSinusoidalIn:
            timingFunction = CPTAnimationTimingFunctionSinusoidalIn;
            break;

        case CPTAnimationCurveSinusoidalOut:
            timingFunction = CPTAnimationTimingFunctionSinusoidalOut;
            break;

        case CPTAnimationCurveSinusoidalInOut:
            timingFunction = CPTAnimationTimingFunctionSinusoidalInOut;
            break;

        case CPTAnimationCurveCubicIn:
            timingFunction = CPTAnimationTimingFunctionCubicIn;
            break;

        case CPTAnimationCurveCubicOut:
            timingFunction = CPTAnimationTimingFunctionCubicOut;
            break;

        case CPTAnimationCurveCubicInOut:
            timingFunction = CPTAnimationTimingFunctionCubicInOut;
            break;

        case CPTAnimationCurveQuadraticIn:
            timingFunction = CPTAnimationTimingFunctionQuadraticIn;
            break;

        case CPTAnimationCurveQuadraticOut:
            timingFunction = CPTAnimationTimingFunctionQuadraticOut;
            break;

        case CPTAnimationCurveQuadraticInOut:
            timingFunction = CPTAnimationTimingFunctionQuadraticInOut;
            break;

        case CPTAnimationCurveQuarticIn:
            timingFunction = CPTAnimationTimingFunctionQuarticIn;
            break;

        case CPTAnimationCurveQuarticOut:
            timingFunction = CPTAnimationTimingFunctionQuarticOut;
            break;

        case CPTAnimationCurveQuarticInOut:
            timingFunction = CPTAnimationTimingFunctionQuarticInOut;
            break;

        case CPTAnimationCurveQuinticIn:
            timingFunction = CPTAnimationTimingFunctionQuinticIn;
            break;

        case CPTAnimationCurveQuinticOut:
            timingFunction = CPTAnimationTimingFunctionQuinticOut;
            break;

        case CPTAnimationCurveQuinticInOut:
            timingFunction = CPTAnimationTimingFunctionQuinticInOut;
            break;

        default:
            timingFunction = NULL;
    }

    return timingFunction;
}

/// @endcond

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ timeOffset: %g; %u active and %u expired operations>", [super description], self.timeOffset, (unsigned)self.animationOperations.count, (unsigned)self.expiredAnimationOperations.count];
}

/// @endcond

@end
