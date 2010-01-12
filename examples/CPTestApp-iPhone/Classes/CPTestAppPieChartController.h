//
//  CPTestAppPieChartController.h
//  CPTestApp-iPhone
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTestAppPieChartController : UIViewController <CPPlotDataSource> 
{
	CPXYGraph *pieChart;
	
	NSMutableArray *dataForChart;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart;

@end
