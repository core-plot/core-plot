@class CPTPlotRange;
@class CPTFill;

@interface CPTLimitBand : NSObject<NSCoding, NSCopying>

@property (nonatomic, readwrite, strong) CPTPlotRange *range;
@property (nonatomic, readwrite, strong) CPTFill *fill;

/// @name Factory Methods
/// @{
+(instancetype)limitBandWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

@end
