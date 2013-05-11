#import "CPTDefinitions.h"
#import "CPTPlotSpace.h"

@class CPTPlotRange;

typedef enum _CPTRubberBandType {
    kCPTRubberBandNone,
    kCPTRubberBandLeft,
    kCPTRubberBandRight
}
CPTRubberBandType;

@interface CPTXYPlotSpace : CPTPlotSpace {
    @private
    CPTPlotRange *xRange;
    CPTPlotRange *yRange;
    CPTPlotRange *globalXRange;
    CPTPlotRange *globalYRange;
    CPTScaleType xScaleType;
    CPTScaleType yScaleType;
    CGPoint lastDragPoint;
    BOOL isDragging;
    BOOL hasMomentum;
    CPTRubberBandType rubberBand;
    CGPoint momentum;
}

@property (nonatomic, readwrite, copy) CPTPlotRange *xRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *yRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *globalXRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *globalYRange;
@property (nonatomic, readwrite, assign) CPTScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType yScaleType;

@property (nonatomic, readwrite) BOOL allowsMomentum;
@property (nonatomic, readwrite) BOOL elasticGlobalXRange;
@property (nonatomic, readwrite) BOOL elasticGlobalYRange;

@end
