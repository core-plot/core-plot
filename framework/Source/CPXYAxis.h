

#import <Foundation/Foundation.h>
#import "CPAxis.h"
#import "CPDefinitions.h"

@class CPConstrainedPosition;

@interface CPXYAxis : CPAxis {
	@private
    BOOL positionedRelativeToPlotArea;
    NSDecimal orthogonalCoordinateDecimal;
    CPPlotRange *orthogonalVisibleRange;
	CPConstraints constraints;
    CPConstrainedPosition *constrainedPosition;
}

@property (nonatomic, readwrite) NSDecimal orthogonalCoordinateDecimal;
@property (nonatomic, readwrite) CPConstraints constraints;
@property (nonatomic, readwrite) BOOL positionedRelativeToPlotArea;
@property (nonatomic, readwrite, copy) CPPlotRange *orthogonalVisibleRange;

@end
