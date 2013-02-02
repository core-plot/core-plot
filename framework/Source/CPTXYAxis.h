#import "CPTAxis.h"

@class CPTConstraints;

@interface CPTXYAxis : CPTAxis {
    @private
    NSDecimal orthogonalCoordinateDecimal;
    CPTConstraints *axisConstraints;
}

/// @name Positioning
/// @{
@property (nonatomic, readwrite) NSDecimal orthogonalCoordinateDecimal;
@property (nonatomic, readwrite, retain) CPTConstraints *axisConstraints;
/// @}

@end
