//
// CPTTestApp_iPadViewController.h
// CPTTestApp-iPad
//
// Created by Brad Larson on 4/1/2010.
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestApp_iPadViewController : UIViewController<CPTBarPlotDataSource, CPTPieChartDataSource, CPTBarPlotDelegate>

@property (nonatomic, readwrite, strong, nonnull) CPTNumberArray dataForChart;
@property (nonatomic, readwrite, strong, nonnull) NSArray<NSDictionary *> *dataForPlot;

// Plot construction methods
-(void)constructScatterPlot;
-(void)constructBarChart;
-(void)constructPieChart;

@end
