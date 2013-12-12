#import "CPTAnimationOperation.h"

#import "CPTAnimationPeriod.h"

/** @brief Describes all aspects of an animation operation, including the value range, duration, animation curve, property to update, and the delegate.
**/
@implementation CPTAnimationOperation

/** @property CPTAnimationPeriod *period
 *  @brief The start value, end value, and duration of this animation operation.
 **/
@synthesize period;

/** @property CPTAnimationCurve animationCurve
 *  @brief The animation curve used to animate this operation.
 **/
@synthesize animationCurve;

/** @property id boundObject
 *  @brief The object to update for each animation frame.
 **/
@synthesize boundObject;

/** @property SEL boundGetter
 *  @brief The @ref boundObject getter method for the property to update for each animation frame.
 **/
@synthesize boundGetter;

/** @property SEL boundSetter
 *  @brief The @ref boundObject setter method for the property to update for each animation frame.
 **/
@synthesize boundSetter;

/** @property __cpt_weak NSObject<CPTAnimationDelegate> *delegate
 *  @brief The animation delegate
 **/
@synthesize delegate;

/** @property id<NSCopying, NSObject> identifier
 *  @brief An object used to identify the layer in collections.
 **/
@synthesize identifier;

/** @property NSDictionary *userInfo
 *  @brief Application-specific user info that can be attached to the operation.
 **/
@synthesize userInfo;

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTAnimationOperation object.
 *
 *  This is the designated initializer. The initialized object will have the following properties:
 *  - @ref period = @nil
 *  - @ref animationCurve = #CPTAnimationCurveDefault
 *  - @ref boundObject = @nil
 *  - @ref boundGetter = @NULL
 *  - @ref boundSetter = @NULL
 *  - @ref delegate = @nil
 *  - @ref identifier = @nil
 *  - @ref userInfo = @nil
 *
 *  @return The initialized object.
 **/
-(id)init
{
    if ( (self = [super init]) ) {
        period         = nil;
        animationCurve = CPTAnimationCurveDefault;
        boundObject    = nil;
        boundGetter    = NULL;
        boundSetter    = NULL;
        delegate       = nil;
        identifier     = nil;
        userInfo       = nil;
    }

    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    [period release];
    [boundObject release];
    [identifier release];
    [userInfo release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ animate %@ %@ with period %@>", [super description], self.boundObject, NSStringFromSelector(self.boundGetter), period];
}

/// @endcond

@end
