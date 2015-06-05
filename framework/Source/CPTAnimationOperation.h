#import "CPTAnimation.h"
#import "CPTDefinitions.h"

@class CPTAnimationPeriod;

@interface CPTAnimationOperation : NSObject

/// @name Animation Timing
/// @{
@property (nonatomic, strong, nonnull) CPTAnimationPeriod *period;
@property (nonatomic, assign) CPTAnimationCurve animationCurve;
/// @}

/// @name Animated Property
/// @{
@property (nonatomic, strong, nonnull) id boundObject;
@property (nonatomic, nonnull) SEL boundGetter;
@property (nonatomic, nonnull) SEL boundSetter;
/// @}

/// @name Delegate
/// @{
@property (nonatomic, cpt_weak_property, nullable) __cpt_weak id<CPTAnimationDelegate> delegate;
/// @}

/// @name Status
/// @{
@property (atomic, getter = isCanceled) BOOL canceled;
/// @}

/// @name Identification
/// @{
@property (nonatomic, readwrite, copy, nullable) id<NSCopying, NSObject> identifier;
@property (nonatomic, readwrite, copy, nullable) NSDictionary *userInfo;
/// @}

@end
