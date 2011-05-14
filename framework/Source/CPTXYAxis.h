#import <Foundation/Foundation.h>
#import "CPTAxis.h"
#import "CPTDefinitions.h"

@class CPTConstrainedPosition;

@interface CPTXYAxis : CPTAxis {
@private
    BOOL isFloatingAxis;
    NSDecimal orthogonalCoordinateDecimal;
	CPTConstraints constraints;
    CPTConstrainedPosition *constrainedPosition;
}

/// @name Positioning
/// @{
@property (nonatomic, readwrite) NSDecimal orthogonalCoordinateDecimal;
@property (nonatomic, readwrite) CPTConstraints constraints;
@property (nonatomic, readwrite) BOOL isFloatingAxis;
///	@}

@end
