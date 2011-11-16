//
//  CPTTestApp_iPadViewController.h
//  CPTTestApp-iPad
//
//  Created by Brad Larson on 4/1/2010.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"


@interface CPTTestApp_iPadViewController : UIViewController <CPTBarPlotDataSource, CPTPieChartDataSource, CPTBarPlotDelegate>
{
	IBOutlet CPTGraphHostingView *scatterPlotView, *barChartView, *pieChartView;
	CPTXYGraph *graph, *barChart, *pieGraph;
    CPTPieChart *piePlot;
    BOOL piePlotIsRotating;

	NSMutableArray *dataForChart, *dataForPlot;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart, *dataForPlot;

// Plot construction methods
-(void)constructScatterPlot;
-(void)constructBarChart;
-(void)constructPieChart;

@end

