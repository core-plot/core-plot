#import "CPTConstraints.h"

@interface _CPTConstraintsRelative : CPTConstraints

/// @name Initialization
/// @{
-(id)initWithRelativeOffset:(CGFloat)newOffset;
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
