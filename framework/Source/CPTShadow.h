@class CPTColor;

@interface CPTShadow : NSObject<NSCoding, NSCopying, NSMutableCopying> {
    @private
    CGSize shadowOffset;
    CGFloat shadowBlurRadius;
    CPTColor *shadowColor;
}

@property (nonatomic, readonly, assign) CGSize shadowOffset;
@property (nonatomic, readonly, assign) CGFloat shadowBlurRadius;
@property (nonatomic, readonly, retain) CPTColor *shadowColor;

/// @name Factory Methods
/// @{
+(id)shadow;
/// @}

/// @name Drawing
/// @{
-(void)setShadowInContext:(CGContextRef)context;
/// @}

@end
