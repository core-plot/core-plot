#import "CPTBorderedLayer.h"

@class CPTAxisSet;
@class CPTPlotGroup;
@class CPTPlotArea;

@interface CPTPlotAreaFrame : CPTBorderedLayer {
    @private
    CPTPlotArea *plotArea;
}

@property (nonatomic, readonly, strong) CPTPlotArea *plotArea;
@property (nonatomic, readwrite, strong) CPTAxisSet *axisSet;
@property (nonatomic, readwrite, strong) CPTPlotGroup *plotGroup;

@end
