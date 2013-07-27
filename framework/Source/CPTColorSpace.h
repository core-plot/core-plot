@interface CPTColorSpace : NSObject<NSCoding>

@property (nonatomic, readonly) CGColorSpaceRef cgColorSpace;

/// @name Factory Methods
/// @{
+(CPTColorSpace *)genericRGBSpace;
/// @}

/// @name Initialization
/// @{
-(id)initWithCGColorSpace:(CGColorSpaceRef)colorSpace;
/// @}

@end
