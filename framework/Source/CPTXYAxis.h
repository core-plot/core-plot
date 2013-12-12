#import "CPTAxis.h"

@class CPTConstraints;

@interface CPTXYAxis : CPTAxis

/// @name Positioning
/// @{
@property (nonatomic, readwrite) NSDecimal orthogonalCoordinateDecimal;
@property (nonatomic, readwrite, strong) CPTConstraints *axisConstraints;
/// @}

@end
