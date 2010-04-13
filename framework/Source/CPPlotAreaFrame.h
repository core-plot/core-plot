#import "CPBorderedLayer.h"

@class CPAxisSet;
@class CPPlotGroup;
@class CPPlottingArea;

@interface CPPlotAreaFrame : CPBorderedLayer {
@private
    CPPlottingArea *plottingArea;
}

@property (nonatomic, readwrite, retain) CPPlottingArea *plottingArea;
@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotGroup *plotGroup;

@end
