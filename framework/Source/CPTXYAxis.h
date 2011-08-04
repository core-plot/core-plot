#import <Foundation/Foundation.h>
#import "CPTAxis.h"

@class CPTConstraints;

@interface CPTXYAxis : CPTAxis {
@private
    BOOL isFloatingAxis;
    NSDecimal orthogonalCoordinateDecimal;
	CPTConstraints *axisConstraints;
}

/// @name Positioning
/// @{
@property (nonatomic, readwrite) NSDecimal orthogonalCoordinateDecimal;
@property (nonatomic, readwrite, retain) CPTConstraints *axisConstraints;
@property (nonatomic, readwrite) BOOL isFloatingAxis;
///	@}

@end
