//
//  CPTestAppBarChartController.h
//  CPTestApp-iPhone
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTestAppBarChartController : UIViewController <CPPlotDataSource> 
{
	CPXYGraph *barChart;
}

@end
