#import "CPTBorderedLayer.h"

@class CPTAxisSet;
@class CPTPlotGroup;
@class CPTPlotArea;

@interface CPTPlotAreaFrame : CPTBorderedLayer {
    @private
    CPTPlotArea *plotArea;
}

@property (nonatomic, readonly, retain) CPTPlotArea *plotArea;
@property (nonatomic, readwrite, retain) CPTAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPTPlotGroup *plotGroup;

@end
