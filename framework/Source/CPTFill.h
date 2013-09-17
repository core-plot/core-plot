@class CPTGradient;
@class CPTImage;
@class CPTColor;

@interface CPTFill : NSObject<NSCopying, NSCoding>

/// @name Factory Methods
/// @{
+(instancetype)fillWithColor:(CPTColor *)aColor;
+(instancetype)fillWithGradient:(CPTGradient *)aGradient;
+(instancetype)fillWithImage:(CPTImage *)anImage;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithColor:(CPTColor *)aColor;
-(instancetype)initWithGradient:(CPTGradient *)aGradient;
-(instancetype)initWithImage:(CPTImage *)anImage;
/// @}

@end

/** @category CPTFill(AbstractMethods)
 *  @brief CPTFill abstract methods—must be overridden by subclasses
 **/
@interface CPTFill(AbstractMethods)

@property (nonatomic, readonly, getter = isOpaque) BOOL opaque;
@property (nonatomic, readonly) CGColorRef cgColor;

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
