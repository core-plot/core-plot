#import <Cocoa/Cocoa.h>
#import "CorePlotQCPTlugIn.h"

@interface CPTBarPlotPlugIn : CorePlotQCPTlugIn<CPTBarPlotDataSource> {
}

@property(assign) double inputBaseValue;
@property(assign) double inputBarWidth;
@property(assign) double inputBarOffset;
@property(assign) BOOL inputHorizontalBars;

-(CPTFill *) barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSNumber *)index;

@end
