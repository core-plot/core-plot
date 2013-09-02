@interface CPTColorSpace : NSObject<NSCoding>

@property (nonatomic, readonly) CGColorSpaceRef cgColorSpace;

/// @name Factory Methods
/// @{
+(instancetype)genericRGBSpace;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithCGColorSpace:(CGColorSpaceRef)colorSpace;
/// @}

@end
