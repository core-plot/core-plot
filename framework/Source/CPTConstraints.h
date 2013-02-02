@interface CPTConstraints : NSObject<NSCoding, NSCopying> {
}

/// @name Factory Methods
/// @{
+(CPTConstraints *)constraintWithLowerOffset:(CGFloat)newOffset;
+(CPTConstraints *)constraintWithUpperOffset:(CGFloat)newOffset;
+(CPTConstraints *)constraintWithRelativeOffset:(CGFloat)newOffset;
/// @}

/// @name Initialization
/// @{
-(id)initWithLowerOffset:(CGFloat)newOffset;
-(id)initWithUpperOffset:(CGFloat)newOffset;
-(id)initWithRelativeOffset:(CGFloat)newOffset;
/// @}

@end

/** @category CPTConstraints(AbstractMethods)
 *  @brief CPTConstraints abstract methods—must be overridden by subclasses
 **/
@interface CPTConstraints(AbstractMethods)

/// @name Comparison
/// @{
-(BOOL)isEqualToConstraint:(CPTConstraints *)otherConstraint;
/// @}

/// @name Position
/// @{
-(CGFloat)positionForLowerBound:(CGFloat)lowerBound upperBound:(CGFloat)upperBound;
/// @}

@end
