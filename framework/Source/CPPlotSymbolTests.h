//
//  CPPlotSymbolTests.h
//  CorePlot
//

#import "CPDataSourceTestCase.h"

@class CPScatterPlot;


@interface CPPlotSymbolTests : CPDataSourceTestCase {
    CPScatterPlot *plot;
}

@property (retain,readwrite) CPScatterPlot *plot;

- (void)setUpPlotSpace;
- (void)buildData;

@end
