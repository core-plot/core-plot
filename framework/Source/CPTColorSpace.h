@interface CPTColorSpace : NSObject<NSCoding> {
    @private
    CGColorSpaceRef cgColorSpace;
}

@property (nonatomic, readonly, assign) CGColorSpaceRef cgColorSpace;

/// @name Factory Methods
/// @{
+(CPTColorSpace *)genericRGBSpace;
/// @}

/// @name Initialization
/// @{
-(id)initWithCGColorSpace:(CGColorSpaceRef)colorSpace;
/// @}

@end
