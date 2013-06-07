#import "CPTConstraints.h"

@interface _CPTConstraintsFixed : CPTConstraints

/// @name Initialization
/// @{
-(id)initWithLowerOffset:(CGFloat)newOffset;
-(id)initWithUpperOffset:(CGFloat)newOffset;
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
