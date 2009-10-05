
#import "CPTestCase.h"

@class CPLayer;
@class CPXYPlotSpace;

@interface CPXYPlotSpaceTests : CPTestCase {
    CPLayer *layer;
    CPXYPlotSpace *plotSpace;
}

@property (retain,readwrite) CPLayer *layer;
@property (retain,readwrite) CPXYPlotSpace *plotSpace;

@end
