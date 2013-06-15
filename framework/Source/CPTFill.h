@class CPTGradient;
@class CPTImage;
@class CPTColor;

@interface CPTFill : NSObject<NSCopying, NSCoding> {
}

/// @name Factory Methods
/// @{
+(CPTFill *)fillWithColor:(CPTColor *)aColor;
+(CPTFill *)fillWithGradient:(CPTGradient *)aGradient;
+(CPTFill *)fillWithImage:(CPTImage *)anImage;
/// @}

/// @name Initialization
/// @{
-(id)initWithColor:(CPTColor *)aColor;
-(id)initWithGradient:(CPTGradient *)aGradient;
-(id)initWithImage:(CPTImage *)anImage;
/// @}

@end

/** @category CPTFill(AbstractMethods)
 *  @brief CPTFill abstract methods—must be overridden by subclasses
 **/
@interface CPTFill(AbstractMethods)

@property (nonatomic, readonly, getter = isOpaque) BOOL opaque;

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
