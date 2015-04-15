#import "CPTAnimation.h"

#import "CPTAnimationOperation.h"
#import "CPTAnimationPeriod.h"
#import "CPTDefinitions.h"
#import "_CPTAnimationTimingFunctions.h"

static const CGFloat kCPTAnimationFrameRate = CPTFloat(1.0 / 60.0); // 60 frames per second

static NSString *const CPTAnimationOperationKey = @"CPTAnimationOperationKey";
static NSString *const CPTAnimationValueKey     = @"CPTAnimationValueKey";
static NSString *const CPTAnimationStartedKey   = @"CPTAnimationStartedKey";
static NSString *const CPTAnimationFinishedKey  = @"CPTAnimationFinishedKey";

/// @cond
@interface CPTAnimation()

@property (nonatomic, readwrite, assign) CGFloat timeOffset;
@property (nonatomic, readwrite, strong) NSMutableArray *animationOperations;
@property (nonatomic, readwrite, strong) NSMutableArray *runningAnimationOperations;
@property (nonatomic, readwrite) dispatch_source_t timer;
@property (nonatomic, readwrite) dispatch_queue_t animationQueue;

+(SEL)setterFromProperty:(NSString *)property;

-(CPTAnimationTimingFunction)timingFunctionForAnimationCurve:(CPTAnimationCurve)animationCurve;
-(void)updateOnMainThreadWithParameters:(NSDictionary *)parameters;

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
 *  @property dispatch_source_t timer
 *  @brief The animation timer. Each tick of the timer corresponds to one animation frame.
 **/
@synthesize timer;

#pragma mark - Init/Dealloc

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
-(instancetype)init
{
    if ( (self = [super init]) ) {
        animationOperations        = [[NSMutableArray alloc] init];
        runningAnimationOperations = [[NSMutableArray alloc] init];
        timer                      = NULL;
        timeOffset                 = CPTFloat(0.0);
        defaultAnimationCurve      = CPTAnimationCurveLinear;

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
    dispatch_queue_t mainQueue = dispatch_get_main_queue();

    for ( CPTAnimationOperation *animationOperation in animationOperations ) {
        id<CPTAnimationDelegate> animationDelegate = animationOperation.delegate;

        if ( [animationDelegate respondsToSelector:@selector(animationCancelled:)] ) {
            dispatch_async(mainQueue, ^{
                [animationDelegate animationCancelled:animationOperation];
            });
        }
    }
}

/// @endcond

#pragma mark - Animation Controller Instance

/** @brief A shared CPTAnimation instance responsible for scheduling and executing animations.
 *  @return The shared CPTAnimation instance.
 **/
+(instancetype)sharedInstance
{
    static dispatch_once_t once = 0;
    static CPTAnimation *shared;

    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });

    return shared;
}

#pragma mark - Property Animation

/** @brief Creates an animation operation with the given properties and adds it to the animation queue.
 *  @param object The object to animate.
 *  @param property The name of the property of @par{object} to animate. The property must have both getter and setter methods.
 *  @param period The animation period.
 *  @param animationCurve The animation curve used to animate the new operation.
 *  @param delegate The animation delegate (can be @nil).
 *  @return The queued animation operation.
 **/
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property period:(CPTAnimationPeriod *)period animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate
{
    CPTAnimationOperation *animationOperation = [[CPTAnimationOperation alloc] init];

    animationOperation.period         = period;
    animationOperation.animationCurve = animationCurve;
    animationOperation.delegate       = delegate;

    if ( object ) {
        animationOperation.boundObject = object;
        animationOperation.boundGetter = NSSelectorFromString(property);
        animationOperation.boundSetter = [CPTAnimation setterFromProperty:property];
    }

    [[CPTAnimation sharedInstance] addAnimationOperation:animationOperation];

    return animationOperation;
}

/// @cond

+(SEL)setterFromProperty:(NSString *)property
{
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", [property stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                                        withString:[[property substringToIndex:1] capitalizedString]]]);
}

/// @endcond

#pragma mark - Animation Management

/** @brief Adds an animation operation to the animation queue.
 *  @param animationOperation The animation operation to add.
 *  @return The queued animation operation.
 **/
-(CPTAnimationOperation *)addAnimationOperation:(CPTAnimationOperation *)animationOperation
{
    id boundObject             = animationOperation.boundObject;
    CPTAnimationPeriod *period = animationOperation.period;

    if ( animationOperation.delegate || (boundObject && period && ![period.startValue isEqual:period.endValue]) ) {
        dispatch_async(self.animationQueue, ^{
            [self.animationOperations addObject:animationOperation];

            if ( !self.timer ) {
                [self startTimer];
            }
        });
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
            animationOperation.canceled = YES;
        });
    }
}

/** @brief Removes all animation operations from the animation queue.
**/
-(void)removeAllAnimationOperations
{
    dispatch_async(self.animationQueue, ^{
        for ( CPTAnimationOperation *animationOperation in self.animationOperations ) {
            animationOperation.canceled = YES;
        }
    });
}

#pragma mark - Retrieving Animation Operations

/** @brief Gets the animation operation with the given identifier from the animation operation array.
 *  @param identifier An animation operation identifier.
 *  @return The animation operation with the given identifier or @nil if it was not found.
 **/
-(CPTAnimationOperation *)operationWithIdentifier:(id<NSCopying, NSObject>)identifier
{
    for ( CPTAnimationOperation *operation in self.animationOperations ) {
        if ( [[operation identifier] isEqual:identifier] ) {
            return operation;
        }
    }
    return nil;
}

#pragma mark - Animation Update

/// @cond

-(void)update
{
    self.timeOffset += kCPTAnimationFrameRate;

    NSMutableArray *theAnimationOperations = self.animationOperations;
    NSMutableArray *runningOperations      = self.runningAnimationOperations;
    NSMutableArray *expiredOperations      = [[NSMutableArray alloc] init];

    CGFloat currentTime = self.timeOffset;
    NSArray *runModes   = @[NSRunLoopCommonModes];

    dispatch_queue_t mainQueue = dispatch_get_main_queue();

    // Update all waiting and running animation operations
    for ( CPTAnimationOperation *animationOperation in theAnimationOperations ) {
        id<CPTAnimationDelegate> animationDelegate = animationOperation.delegate;

        CPTAnimationPeriod *period = animationOperation.period;

        CGFloat duration  = period.duration;
        CGFloat startTime = period.startOffset;
        CGFloat delay     = period.delay;
        if ( isnan(delay) ) {
            if ( [period canStartWithValueFromObject:animationOperation.boundObject propertyGetter:animationOperation.boundGetter] ) {
                period.delay = currentTime - startTime;
                startTime    = currentTime;
            }
            else {
                startTime = CPTFloat(NAN);
            }
        }
        else {
            startTime += delay;
        }
        CGFloat endTime = startTime + duration;

        if ( animationOperation.isCanceled ) {
            [expiredOperations addObject:animationOperation];

            if ( [animationDelegate respondsToSelector:@selector(animationCancelled:)] ) {
                dispatch_async(mainQueue, ^{
                    [animationDelegate animationCancelled:animationOperation];
                });
            }
        }
        else if ( currentTime >= startTime ) {
            id boundObject = animationOperation.boundObject;

            CPTAnimationTimingFunction timingFunction = [self timingFunctionForAnimationCurve:animationOperation.animationCurve];

            if ( boundObject && timingFunction ) {
                BOOL started = NO;

                if ( ![runningOperations containsObject:animationOperation] ) {
                    // Remove any running animations for the same property
                    SEL boundGetter = animationOperation.boundGetter;
                    SEL boundSetter = animationOperation.boundSetter;

                    for ( CPTAnimationOperation *operation in runningOperations ) {
                        if ( operation.boundObject == boundObject ) {
                            if ( (operation.boundGetter == boundGetter) && (operation.boundSetter == boundSetter) ) {
                                operation.canceled = YES;
                            }
                        }
                    }

                    // Start the new animation
                    [runningOperations addObject:animationOperation];
                    started = YES;
                }
                if ( !animationOperation.isCanceled ) {
                    CGFloat progress = timingFunction(currentTime - startTime, duration);

                    NSDictionary *parameters = @{
                        CPTAnimationOperationKey: animationOperation,
                        CPTAnimationValueKey: [period tweenedValueForProgress:progress],
                        CPTAnimationStartedKey: @(started),
                        CPTAnimationFinishedKey: @(currentTime >= endTime)
                    };

                    // Used -performSelectorOnMainThread:... instead of GCD to ensure the animation continues to run in all run loop common modes.
                    [self performSelectorOnMainThread:@selector(updateOnMainThreadWithParameters:)
                                           withObject:parameters
                                        waitUntilDone:NO
                                                modes:runModes];

                    if ( currentTime >= endTime ) {
                        [expiredOperations addObject:animationOperation];
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

// This method must be called from the main thread.
-(void)updateOnMainThreadWithParameters:(NSDictionary *)parameters
{
    CPTAnimationOperation *animationOperation = parameters[CPTAnimationOperationKey];

    __block BOOL canceled;

    dispatch_sync(self.animationQueue, ^{
        canceled = animationOperation.isCanceled;
    });

    if ( !canceled ) {
        @try {
            id<CPTAnimationDelegate> delegate = animationOperation.delegate;

            NSNumber *started = parameters[CPTAnimationStartedKey];
            if ( started.boolValue ) {
                if ( [delegate respondsToSelector:@selector(animationDidStart:)] ) {
                    [delegate animationDidStart:animationOperation];
                }
            }

            if ( [delegate respondsToSelector:@selector(animationWillUpdate:)] ) {
                [delegate animationWillUpdate:animationOperation];
            }

            SEL boundSetter = animationOperation.boundSetter;
            id boundObject  = animationOperation.boundObject;
            id tweenedValue = parameters[CPTAnimationValueKey];

            if ( [tweenedValue isKindOfClass:[NSDecimalNumber class]] ) {
                NSDecimal buffer = [(NSDecimalNumber *)tweenedValue decimalValue];

                typedef void (*SetterType)(id, SEL, NSDecimal);
                SetterType setterMethod = (SetterType)[boundObject methodForSelector : boundSetter];
                setterMethod(boundObject, boundSetter, buffer);
            }
            else if ( [tweenedValue isKindOfClass:[NSValue class]] ) {
                NSValue *value = (NSValue *)tweenedValue;

                NSUInteger bufferSize = 0;
                NSGetSizeAndAlignment(value.objCType, &bufferSize, NULL);

                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundSetter]];
                [invocation setTarget:boundObject];
                [invocation setSelector:boundSetter];

                void *buffer = malloc(bufferSize);
                [value getValue:buffer];
                [invocation setArgument:buffer atIndex:2];
                free(buffer);

                [invocation invoke];
            }
            else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id<NSObject> theObject = boundObject;
                [theObject performSelector:boundSetter withObject:tweenedValue];
#pragma clang diagnostic pop
            }

            if ( [delegate respondsToSelector:@selector(animationDidUpdate:)] ) {
                [delegate animationDidUpdate:animationOperation];
            }

            NSNumber *finished = parameters[CPTAnimationFinishedKey];
            if ( finished.boolValue ) {
                if ( [delegate respondsToSelector:@selector(animationDidFinish:)] ) {
                    [delegate animationDidFinish:animationOperation];
                }
            }
        }
        @catch ( NSException *__unused exception ) {
            // something went wrong; don't run this operation any more
            dispatch_async(self.animationQueue, ^{
                animationOperation.canceled = YES;
            });
        }
    }
}

-(void)startTimer
{
    self.timer = CreateDispatchTimer(kCPTAnimationFrameRate, self.animationQueue, ^{
        [self update];
    });
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

#pragma mark - Timing Functions

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
