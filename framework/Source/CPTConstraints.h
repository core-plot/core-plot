@interface CPTConstraints : NSObject<NSCoding, NSCopying>

/// @name Factory Methods
/// @{
+(instancetype)constraintWithLowerOffset:(CGFloat)newOffset;
+(instancetype)constraintWithUpperOffset:(CGFloat)newOffset;
+(instancetype)constraintWithRelativeOffset:(CGFloat)newOffset;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithLowerOffset:(CGFloat)newOffset;
-(instancetype)initWithUpperOffset:(CGFloat)newOffset;
-(instancetype)initWithRelativeOffset:(CGFloat)newOffset;
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
