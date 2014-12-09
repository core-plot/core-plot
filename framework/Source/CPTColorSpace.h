@interface CPTColorSpace : NSObject<NSCoding>

@property (nonatomic, readonly) CGColorSpaceRef cgColorSpace;

/// @name Factory Methods
/// @{
+(instancetype)genericRGBSpace;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithCGColorSpace:(CGColorSpaceRef)colorSpace NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

@end
