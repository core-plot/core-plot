@class CPTPlotRange;
@class CPTFill;

@interface CPTLimitBand : NSObject<NSCoding, NSCopying> {
    @private
    CPTPlotRange *range;
    CPTFill *fill;
}

@property (nonatomic, readwrite, retain) CPTPlotRange *range;
@property (nonatomic, readwrite, retain) CPTFill *fill;

/// @name Factory Methods
/// @{
+(CPTLimitBand *)limitBandWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill;
/// @}

/// @name Initialization
/// @{
-(id)initWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill;
/// @}

@end
