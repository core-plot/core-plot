#import "CPTAxis.h"

@class CPTConstraints;

@interface CPTXYAxis : CPTAxis

/// @name Positioning
/// @{
@property (nonatomic, readwrite, strong) NSNumber *orthogonalPosition;
@property (nonatomic, readwrite, strong) CPTConstraints *axisConstraints;
/// @}

@end
