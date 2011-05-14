//
//  CPTTestAppBarChartController.h
//  CPTTestApp-iPhone
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTTestAppBarChartController : UIViewController <CPTPlotDataSource> 
{
	CPTXYGraph *barChart;
}

@end
