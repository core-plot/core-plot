@class CPTPlotRange;
@class CPTFill;

@interface CPTLimitBand : NSObject<NSCoding, NSCopying>

@property (nonatomic, readwrite, strong, nullable) CPTPlotRange *range;
@property (nonatomic, readwrite, strong, nullable) CPTFill *fill;

/// @name Factory Methods
/// @{
+(nonnull instancetype)limitBandWithRange:(nullable CPTPlotRange *)newRange fill:(nullable CPTFill *)newFill;
/// @}

/// @name Initialization
/// @{
-(nonnull instancetype)initWithRange:(nullable CPTPlotRange *)newRange fill:(nullable CPTFill *)newFill NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

@end
