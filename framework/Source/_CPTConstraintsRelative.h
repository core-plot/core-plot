/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTConstraints.h>
#else
#import "CPTConstraints.h"
#endif

@interface _CPTConstraintsRelative : CPTConstraints

/// @name Initialization
/// @{
-(nonnull instancetype)initWithRelativeOffset:(CGFloat)newOffset NS_DESIGNATED_INITIALIZER;
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Comparison
/// @{
-(BOOL)isEqualToConstraint:(nullable CPTConstraints *)otherConstraint;
/// @}

/// @name Position
/// @{
-(CGFloat)positionForLowerBound:(CGFloat)lowerBound upperBound:(CGFloat)upperBound;
/// @}

@end
