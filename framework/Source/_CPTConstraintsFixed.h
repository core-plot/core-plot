#import "CPTConstraints.h"

@interface _CPTConstraintsFixed : CPTConstraints

/// @name Initialization
/// @{
-(instancetype)initWithLowerOffset:(CGFloat)newOffset;
-(instancetype)initWithUpperOffset:(CGFloat)newOffset;
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
