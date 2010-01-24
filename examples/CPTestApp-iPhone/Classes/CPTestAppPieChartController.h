#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTestAppPieChartController : UIViewController <CPPieChartDataSource> 
{
	@private
	CPXYGraph *pieChart;
	NSMutableArray *dataForChart;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart;

@end
