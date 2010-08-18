#import <Cocoa/Cocoa.h>
#import "CorePlotQCPlugIn.h"

@interface CPBarPlotPlugIn : CorePlotQCPlugIn<CPBarPlotDataSource> {
}

@property(assign) double inputBaseValue;
@property(assign) double inputBarWidth;
@property(assign) double inputBarOffset;
@property(assign) BOOL inputHorizontalBars;

-(CPFill *) barFillForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSNumber *)index;

@end
