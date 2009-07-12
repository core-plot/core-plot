//
//  CPTestAppBarChartController.h
//  CPTestApp-iPhone
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTestAppBarChartController : UIViewController <CPPlotDataSource> 
{
	CPXYGraph *barChart;
	
	NSMutableArray *dataForChart;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart;

@end
