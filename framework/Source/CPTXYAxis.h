#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTAxis.h>
#else
#import "CPTAxis.h"
#endif

@class CPTConstraints;

@interface CPTXYAxis : CPTAxis

/// @name Positioning
/// @{
@property (nonatomic, readwrite, strong, nullable) NSNumber *orthogonalPosition;
@property (nonatomic, readwrite, strong, nullable) CPTConstraints *axisConstraints;
/// @}

@end
