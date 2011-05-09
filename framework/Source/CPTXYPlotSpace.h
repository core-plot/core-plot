#import "CPTPlotSpace.h"
#import "CPTDefinitions.h"

@class CPTPlotRange;

@interface CPTXYPlotSpace : CPTPlotSpace {
	@private
	CPTPlotRange *xRange;
	CPTPlotRange *yRange;
    CPTPlotRange *globalXRange;
	CPTPlotRange *globalYRange;
    CPTScaleType xScaleType; // TODO: Implement scale types
    CPTScaleType yScaleType; // TODO: Implement scale types
    CGPoint lastDragPoint;
    BOOL isDragging;
}

@property (nonatomic, readwrite, copy) CPTPlotRange *xRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *yRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *globalXRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *globalYRange;
@property (nonatomic, readwrite, assign) CPTScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType yScaleType;

@end
