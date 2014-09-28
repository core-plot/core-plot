#import "CorePlotQCPlugIn.h"
#import <Cocoa/Cocoa.h>

@interface CPBarPlotPlugIn : CorePlotQCPlugIn<CPTBarPlotDataSource> {
}

@property (nonatomic, readwrite, assign) double inputBaseValue;
@property (nonatomic, readwrite, assign) double inputBarWidth;
@property (nonatomic, readwrite, assign) double inputBarOffset;
@property (nonatomic, readwrite, assign) BOOL inputHorizontalBars;

@end
