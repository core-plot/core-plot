#import "CPTConstraints.h"

@interface _CPTConstraintsRelative : CPTConstraints

/// @name Initialization
/// @{
-(instancetype)initWithRelativeOffset:(CGFloat)newOffset NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Comparison
/// @{
-(BOOL)isEqualToConstraint:(CPTConstraints *)otherConstraint;
/// @}

/// @name Position
/// @{
-(CGFloat)positionForLowerBound:(CGFloat)lowerBound upperBound:(CGFloat)upperBound;
/// @}

@end
