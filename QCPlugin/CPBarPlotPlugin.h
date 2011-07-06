#import <Cocoa/Cocoa.h>
#import "CorePlotQCPlugIn.h"

@interface CPBarPlotPlugIn : CorePlotQCPlugIn<CPTBarPlotDataSource> {
}

@property(assign) double inputBaseValue;
@property(assign) double inputBarWidth;
@property(assign) double inputBarOffset;
@property(assign) BOOL inputHorizontalBars;

-(CPTFill *) barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSNumber *)index;

@end
