#import "CPTAnimation.h"
#import "CPTDefinitions.h"

@class CPTAnimationPeriod;

@interface CPTAnimationOperation : NSObject

/// @name Animation Timing
/// @{
@property (nonatomic, strong) CPTAnimationPeriod *period;
@property (nonatomic, assign) CPTAnimationCurve animationCurve;
/// @}

/// @name Animated Property
/// @{
@property (nonatomic, strong) id boundObject;
@property (nonatomic) SEL boundGetter;
@property (nonatomic) SEL boundSetter;
/// @}

/// @name Delegate
/// @{
@property (nonatomic, cpt_weak_property) __cpt_weak id<CPTAnimationDelegate> delegate;
/// @}

/// @name Status
/// @{
@property (atomic, getter = isCanceled) BOOL canceled;
/// @}

/// @name Identification
/// @{
@property (nonatomic, readwrite, copy) id<NSCopying, NSObject> identifier;
@property (nonatomic, readwrite, copy) NSDictionary *userInfo;
/// @}

@end
