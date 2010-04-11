

#import <Foundation/Foundation.h>
#import "CPAxis.h"
#import "CPDefinitions.h"

@class CPConstrainedPosition;

@interface CPXYAxis : CPAxis {
	@private
    BOOL positionedRelativeToPlotArea;
    NSDecimal orthogonalCoordinateDecimal;
	CPConstraints constraints;
    CPConstrainedPosition *constrainedPosition;
}

/// @name Positioning
/// @{
@property (nonatomic, readwrite) NSDecimal orthogonalCoordinateDecimal;
@property (nonatomic, readwrite) CPConstraints constraints;
@property (nonatomic, readwrite) BOOL positionedRelativeToPlotArea;
///	@}

@end
