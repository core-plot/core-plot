#import "CorePlotQCPlugin.h"
#import <Cocoa/Cocoa.h>

@interface CPTBarPlotPlugIn : CorePlotQCPlugIn<CPTBarPlotDataSource>

@property (readwrite, assign) double inputBaseValue;
@property (readwrite, assign) double inputBarWidth;
@property (readwrite, assign) double inputBarOffset;
@property (readwrite, assign) BOOL inputHorizontalBars;

@end
