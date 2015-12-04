@interface CPTColorSpace : NSObject<NSCoding, NSSecureCoding>

@property (nonatomic, readonly, nullable) CGColorSpaceRef cgColorSpace;

/// @name Factory Methods
/// @{
+(nonnull instancetype)genericRGBSpace;
/// @}

/// @name Initialization
/// @{
-(nonnull instancetype)initWithCGColorSpace:(nonnull CGColorSpaceRef)colorSpace NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

@end
