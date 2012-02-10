#import "CorePlotQCPlugIn.h"
#import <Cocoa/Cocoa.h>

@interface CPBarPlotPlugIn : CorePlotQCPlugIn<CPTBarPlotDataSource> {
}

@property (assign) double inputBaseValue;
@property (assign) double inputBarWidth;
@property (assign) double inputBarOffset;
@property (assign) BOOL inputHorizontalBars;

@end
