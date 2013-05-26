@class CPTPlotRange;
@class CPTFill;

@interface CPTLimitBand : NSObject<NSCoding, NSCopying>

@property (nonatomic, readwrite, strong) CPTPlotRange *range;
@property (nonatomic, readwrite, strong) CPTFill *fill;

/// @name Factory Methods
/// @{
+(CPTLimitBand *)limitBandWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill;
/// @}

/// @name Initialization
/// @{
-(id)initWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill;
/// @}

@end
