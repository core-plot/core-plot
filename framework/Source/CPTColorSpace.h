@interface CPTColorSpace : NSObject<NSCoding>

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
