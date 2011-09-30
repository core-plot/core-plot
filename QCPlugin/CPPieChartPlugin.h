#import "CorePlotQCPlugIn.h"
#import <Cocoa/Cocoa.h>

@interface CPPieChartPlugIn : CorePlotQCPlugIn<CPTPieChartDataSource>{
}

@property (assign) double inputPieRadius;
@property (assign) double inputSliceLabelOffset;
@property (assign) double inputStartAngle;
@property (assign) NSUInteger inputSliceDirection;
@property (assign) double inputBorderWidth;
@property (assign) CGColorRef inputBorderColor;
@property (assign) CGColorRef inputLabelColor;

@end
