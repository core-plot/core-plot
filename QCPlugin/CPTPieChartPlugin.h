#import "CorePlotQCPlugIn.h"
#import <Cocoa/Cocoa.h>

@interface CPTPieChartPlugIn : CorePlotQCPlugIn<CPTPieChartDataSource>

@property (readwrite, assign) double inputPieRadius;
@property (readwrite, assign) double inputSliceLabelOffset;
@property (readwrite, assign) double inputStartAngle;
@property (readwrite, assign) NSUInteger inputSliceDirection;
@property (readwrite, assign) double inputBorderWidth;
@property (readwrite, assign) CGColorRef inputBorderColor;
@property (readwrite, assign) CGColorRef inputLabelColor;

@end
