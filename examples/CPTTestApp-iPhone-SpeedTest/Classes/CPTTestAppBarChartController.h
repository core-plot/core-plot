//
//  CPTTestAppBarChartController.h
//  CPTTestApp-iPhone
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppBarChartController : UIViewController<CPTPlotDataSource>
{
	CPTXYGraph *barChart;
}

@end
