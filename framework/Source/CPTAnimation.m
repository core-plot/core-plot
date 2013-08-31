#import "CPTAnimation.h"

#import "CPTAnimationOperation.h"
#import "CPTAnimationPeriod.h"
#import "_CPTAnimationTimingFunctions.h"

static const CGFloat kCPTAnimationFrameRate = CPTFloat(1.0 / 60.0); // 60 frames per second

/// @cond
@interface CPTAnimation()

@property (nonatomic, readwrite, assign) CGFloat timeOffset;
@property (nonatomic, readwrite, strong) NSMutableArray *animationOperations;
@property (nonatomic, readwrite, strong) NSMutableArray *runningAnimationOperations;
@property (nonatomic, readwrite, strong) NSMutableArray *cancelledAnimationOperations;
@property (nonatomic, readwrite) dispatch_source_t timer;
@property (nonatomic, readwrite) dispatch_queue_t animationQueue;

+(SEL)setterFromProperty:(NSString *)property;

-(CPTAnimationTimingFunction)timingFunctionForAnimationCurve:(CPTAnimationCurve)animationCurve;

-(void)startTimer;
-(void)cancelTimer;
-(void)update;

dispatch_source_t CreateDispatchTimer(CGFloat interval, dispatch_queue_t queue, dispatch_block_t block);

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
 *  @property NSMutableArray *cancelledAnimationOperations
 *  @brief The list of completed animation operations.
 *
 *  These operations are removed from @ref animationOperations and the list is cleared after every animation frame.
 **/
@synthesize cancelledAnimationOperations;

/** @internal
 *  @property dispatch_source_t timer
 *  @brief The animation timer. Each tick of the timer corresponds to one animation frame.
 **/
@synthesize timer;

/** @internal
 *  @property dispatch_queue_t animationQueue;
 *  @brief The serial dispatch queue used to synchronize animation updates.
 **/
@synthesize animationQueue;

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
        animationOperations          = [[NSMutableArray alloc] init];
        runningAnimationOperations   = [[NSMutableArray alloc] init];
        cancelledAnimationOperations = [[NSMutableArray alloc] init];
        timer                        = NULL;
        timeOffset                   = 0.0;
        defaultAnimationCurve        = CPTAnimationCurveLinear;

        animationQueue = dispatch_queue_create("CorePlot.CPTAnimation.animationQueue", NULL);
    }

    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    [self cancelTimer];

    dispatch_release(animationQueue);

    NSArray *runModes = @[NSRunLoopCommonModes];

    for ( CPTAnimationOperation *animationOperation in animationOperations ) {
        NSObject<CPTAnimationDelegate> *animationDelegate = animationOperation.delegate;

        if ( [animationDelegate respondsToSelector:@selector(animationCancelled:)] ) {
            [animationDelegate performSelectorOnMainThread:@selector(animationCancelled:)
                                                withObject:animationOperation
                                             waitUntilDone:NO
                                                     modes:runModes];
        }
    }
}

/// @endcond

#pragma mark -

/** @brief A shared CPTAnimation instance responsible for scheduling and executing animations.
 *  @return The shared CPTAnimation instance.
 **/
+(CPTAnimation *)sharedInstance
{
    static dispatch_once_t once;
    static CPTAnimation *shared;

    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    }

                 );

    return shared;
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

    [[CPTAnimation sharedInstance] performSelectorOnMainThread:@selector(addAnimationOperation:)
                                                    withObject:animationOperation
                                                 waitUntilDone:NO
                                                         modes:@[NSRunLoopCommonModes]];

    return animationOperation;
}

/// @cond

+(SEL)setterFromProperty:(NSString *)property
{
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", [property stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                                        withString:[[property substringToIndex:1] capitalizedString]]]);
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
        dispatch_async(self.animationQueue, ^{
            NSMutableArray *theAnimationOperations = self.animationOperations;

            for ( CPTAnimationOperation *operation in theAnimationOperations ) {
                if ( operation.boundObject == animationOperation.boundObject ) {
                    if ( (operation.boundGetter == animationOperation.boundGetter) && (operation.boundSetter == animationOperation.boundSetter) ) {
                        [self removeAnimationOperation:operation];
                        break;
                    }
                }
            }

            [theAnimationOperations addObject:animationOperation];

            if ( !self.timer ) {
                [self startTimer];
            }
        }

                      );
    }
    return animationOperation;
}

/** @brief Removes an animation operation from the animation queue.
 *  @param animationOperation The animation operation to remove.
 **/
-(void)removeAnimationOperation:(CPTAnimationOperation *)animationOperation
{
    if ( animationOperation ) {
        dispatch_async(self.animationQueue, ^{
            [self.cancelledAnimationOperations addObject:animationOperation];
        }

                      );
    }
}

/** @brief Removes all animation operations from the animation queue.
**/
-(void)removeAllAnimationOperations
{
    dispatch_async(self.animationQueue, ^{
        [self.cancelledAnimationOperations addObjectsFromArray:self.animationOperations];
    }

                  );
}

#pragma mark -

/// @cond

-(void)update
{
    self.timeOffset += kCPTAnimationFrameRate;

    NSMutableArray *theAnimationOperations = self.animationOperations;
    NSMutableArray *runningOperations      = self.runningAnimationOperations;
    NSMutableArray *expiredOperations      = [[NSMutableArray alloc] init];

    CGFloat currentTime = self.timeOffset;
    Class valueClass    = [NSValue class];
    NSArray *runModes   = @[NSRunLoopCommonModes];

    // Remove any cancelled animation operations
    NSMutableArray *cancelledOperations = self.cancelledAnimationOperations;

    for ( CPTAnimationOperation *animationOperation in cancelledOperations ) {
        [runningOperations removeObjectIdenticalTo:animationOperation];
        [theAnimationOperations removeObjectIdenticalTo:animationOperation];

        NSObject<CPTAnimationDelegate> *animationDelegate = animationOperation.delegate;

        if ( [animationDelegate respondsToSelector:@selector(animationCancelled:)] ) {
            [animationDelegate performSelectorOnMainThread:@selector(animationCancelled:)
                                                withObject:animationOperation
                                             waitUntilDone:NO
                                                     modes:runModes];
        }
    }

    [cancelledOperations removeAllObjects];

    // Update all waiting and running animation operations
    for ( CPTAnimationOperation *animationOperation in theAnimationOperations ) {
        NSObject<CPTAnimationDelegate> *animationDelegate = animationOperation.delegate;

        CPTAnimationPeriod *period = animationOperation.period;

        CGFloat duration  = period.duration;
        CGFloat startTime = period.startOffset + period.delay;
        CGFloat endTime   = startTime + duration;

        if ( currentTime > endTime ) {
            [expiredOperations addObject:animationOperation];

            if ( [animationDelegate respondsToSelector:@selector(animationDidFinish:)] ) {
                [animationDelegate performSelectorOnMainThread:@selector(animationDidFinish:)
                                                    withObject:animationOperation
                                                 waitUntilDone:NO
                                                         modes:runModes];
            }
        }
        else if ( currentTime >= startTime ) {
            id boundObject = animationOperation.boundObject;

            CPTAnimationTimingFunction timingFunction = [self timingFunctionForAnimationCurve:animationOperation.animationCurve];

            if ( boundObject && timingFunction ) {
                if ( ![runningOperations containsObject:animationOperation] ) {
                    [runningOperations addObject:animationOperation];

                    if ( [animationDelegate respondsToSelector:@selector(animationDidStart:)] ) {
                        [animationDelegate performSelectorOnMainThread:@selector(animationDidStart:)
                                                            withObject:animationOperation
                                                         waitUntilDone:NO
                                                                 modes:runModes];
                    }
                }
                CGFloat progress = timingFunction(currentTime - startTime, duration);

                id tweenedValue = [period tweenedValueForProgress:progress];
                SEL boundSetter = animationOperation.boundSetter;

                @try {
                    if ( [animationDelegate respondsToSelector:@selector(animationWillUpdate:)] ) {
                        [animationDelegate performSelectorOnMainThread:@selector(animationWillUpdate:)
                                                            withObject:animationOperation
                                                         waitUntilDone:NO
                                                                 modes:runModes];
                    }

                    if ( [tweenedValue isKindOfClass:valueClass] ) {
                        NSValue *value = (NSValue *)tweenedValue;

                        NSUInteger bufferSize = 0;
                        NSGetSizeAndAlignment(value.objCType, &bufferSize, NULL);

                        void *buffer = malloc(bufferSize);
                        [tweenedValue getValue:buffer];

                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[boundObject class] instanceMethodSignatureForSelector:boundSetter]];
                        [invocation setTarget:boundObject];
                        [invocation setSelector:boundSetter];
                        [invocation setArgument:buffer atIndex:2];

                        [invocation performSelectorOnMainThread:@selector(invoke)
                                                     withObject:nil
                                                  waitUntilDone:NO
                                                          modes:runModes];

                        free(buffer);
                    }
                    else {
                        [boundObject performSelectorOnMainThread:boundSetter
                                                      withObject:tweenedValue
                                                   waitUntilDone:NO
                                                           modes:runModes];
                    }

                    if ( [animationDelegate respondsToSelector:@selector(animationDidUpdate:)] ) {
                        [animationDelegate performSelectorOnMainThread:@selector(animationDidUpdate:)
                                                            withObject:animationOperation
                                                         waitUntilDone:NO
                                                                 modes:runModes];
                    }
                }
                @catch ( NSException *exception ) {
#pragma unused(exception)
                    // something went wrong; don't run this operation any more
                    [expiredOperations addObject:animationOperation];

                    if ( [animationDelegate respondsToSelector:@selector(animationCancelled:)] ) {
                        [animationDelegate performSelectorOnMainThread:@selector(animationCancelled:)
                                                            withObject:animationOperation
                                                         waitUntilDone:NO
                                                                 modes:runModes];
                    }
                }
            }
        }
    }

    for ( CPTAnimationOperation *animationOperation in expiredOperations ) {
        [runningOperations removeObjectIdenticalTo:animationOperation];
        [theAnimationOperations removeObjectIdenticalTo:animationOperation];
    }

    if ( theAnimationOperations.count == 0 ) {
        [self cancelTimer];
    }
}

-(void)startTimer
{
    self.timer = CreateDispatchTimer(kCPTAnimationFrameRate, self.animationQueue, ^{
        [self update];
    }

                                    );
}

-(void)cancelTimer
{
    dispatch_source_t theTimer = self.timer;

    if ( theTimer ) {
        dispatch_source_cancel(theTimer);
        dispatch_release(theTimer);
        self.timer = NULL;
    }
}

dispatch_source_t CreateDispatchTimer(CGFloat interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t newTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    if ( newTimer ) {
        dispatch_source_set_timer(newTimer, dispatch_time(DISPATCH_TIME_NOW, 0), (uint64_t)(interval * NSEC_PER_SEC), 0);
        dispatch_source_set_event_handler(newTimer, block);
        dispatch_resume(newTimer);
    }
    return newTimer;
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
    return [NSString stringWithFormat:@"<%@ timeOffset: %g; %lu active and %lu running operations>",
            [super description],
            self.timeOffset,
            (unsigned long)self.animationOperations.count,
            (unsigned long)self.runningAnimationOperations.count];
}

/// @endcond

@end
