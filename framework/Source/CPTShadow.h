@class CPTColor;

@interface CPTShadow : NSObject<NSCoding, NSCopying, NSMutableCopying>

@property (nonatomic, readonly) CGSize shadowOffset;
@property (nonatomic, readonly) CGFloat shadowBlurRadius;
@property (nonatomic, readonly) CPTColor *shadowColor;

/// @name Factory Methods
/// @{
+(instancetype)shadow;
/// @}

/// @name Drawing
/// @{
-(void)setShadowInContext:(CGContextRef)context;
/// @}

@end
