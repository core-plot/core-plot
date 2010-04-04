//
//  CPTestApp_iPadViewController.h
//  CPTestApp-iPad
//
//  Created by Brad Larson on 4/1/2010.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"


@interface CPTestApp_iPadViewController : UIViewController <CPPlotDataSource, CPPieChartDataSource>
{
	IBOutlet CPLayerHostingView *scatterPlotView, *barChartView, *pieChartView;
	CPXYGraph *graph, *barChart, *pieChart;

	NSMutableArray *dataForChart, *dataForPlot;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart, *dataForPlot;

// Plot construction methods
- (void)constructScatterPlot;
- (void)constructBarChart;
- (void)constructPieChart;

@end

