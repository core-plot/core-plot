
#import "CPPlotSpace.h"
#import "CPDefinitions.h"

@class CPPlotRange;

@interface CPXYPlotSpace : CPPlotSpace {
	@private
	CPPlotRange *xRange;
	CPPlotRange *yRange;
    CPScaleType xScaleType; // TODO: Implement scale types
    CPScaleType yScaleType; // TODO: Implement scale types
    CGPoint lastDragPoint;
    BOOL isDragging;
}

@property (nonatomic, readwrite, copy) CPPlotRange *xRange;
@property (nonatomic, readwrite, copy) CPPlotRange *yRange;
@property (nonatomic, readwrite, assign) CPScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPScaleType yScaleType;

@end
