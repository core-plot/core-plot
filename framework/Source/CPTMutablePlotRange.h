#import "CPTPlotRange.h"

@interface CPTMutablePlotRange : CPTPlotRange

/// @name Range Limits
/// @{
@property (nonatomic, readwrite, strong) NSNumber *location;
@property (nonatomic, readwrite, strong) NSNumber *length;
@property (nonatomic, readwrite) NSDecimal locationDecimal;
@property (nonatomic, readwrite) NSDecimal lengthDecimal;
@property (nonatomic, readwrite) double locationDouble;
@property (nonatomic, readwrite) double lengthDouble;
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
-(void)expandRangeByFactor:(NSNumber *)factor;
/// @}

@end
