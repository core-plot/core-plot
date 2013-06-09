#import "CPTPlotRange.h"

@interface CPTMutablePlotRange : CPTPlotRange

/// @name Range Limits
/// @{
@property (nonatomic, readwrite) NSDecimal location;
@property (nonatomic, readwrite) NSDecimal length;
/// @}

/// @name Combining Ranges
/// @{
-(void)unionPlotRange:(CPTPlotRange *)otherRange;
-(void)intersectionPlotRange:(CPTPlotRange *)otherRange;
/// @}

/// @name Shifting Ranges
/// @{
-(void)shiftLocationToFitInRange:(CPTPlotRange *)otherRange;
-(void)shiftEndToFitInRange:(CPTPlotRange *)otherRange;
/// @}

/// @name Expanding/Contracting Ranges
/// @{
-(void)expandRangeByFactor:(NSDecimal)factor;
/// @}

@end
