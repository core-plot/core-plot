@class CPTColor;

@interface CPTShadow : NSObject<NSCoding, NSCopying, NSMutableCopying>

@property (nonatomic, readonly) CGSize shadowOffset;
@property (nonatomic, readonly) CGFloat shadowBlurRadius;
@property (nonatomic, readonly, nullable) CPTColor *shadowColor;

/// @name Factory Methods
/// @{
+(nonnull instancetype)shadow;
/// @}

/// @name Drawing
/// @{
-(void)setShadowInContext:(nonnull CGContextRef)context;
/// @}

@end
