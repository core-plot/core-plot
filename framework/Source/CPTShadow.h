@class CPTColor;

@interface CPTShadow : NSObject<NSCoding, NSCopying, NSMutableCopying>

@property (nonatomic, readonly, assign) CGSize shadowOffset;
@property (nonatomic, readonly, assign) CGFloat shadowBlurRadius;
@property (nonatomic, readonly, strong) CPTColor *shadowColor;

/// @name Factory Methods
/// @{
+(id)shadow;
/// @}

/// @name Drawing
/// @{
-(void)setShadowInContext:(CGContextRef)context;
/// @}

@end
