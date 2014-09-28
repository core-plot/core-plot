#import "CorePlotQCPlugIn.h"
#import <Cocoa/Cocoa.h>

@interface CPPieChartPlugIn : CorePlotQCPlugIn<CPTPieChartDataSource> {
}

@property (nonatomic, readwrite, assign) double inputPieRadius;
@property (nonatomic, readwrite, assign) double inputSliceLabelOffset;
@property (nonatomic, readwrite, assign) double inputStartAngle;
@property (nonatomic, readwrite, assign) NSUInteger inputSliceDirection;
@property (nonatomic, readwrite, assign) double inputBorderWidth;
@property (nonatomic, readwrite, strong) NSColor *inputBorderColor;
@property (nonatomic, readwrite, strong) NSColor *inputLabelColor;

@end
