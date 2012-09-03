#import "CPTConstraints.h"
#import <Foundation/Foundation.h>

@interface _CPTConstraintsFixed : CPTConstraints {
    @private
    CGFloat offset;
    BOOL isFixedToLower;
}

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
