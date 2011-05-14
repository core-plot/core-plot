#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTTestAppPieChartController : UIViewController <CPTPieChartDataSource> 
{
	@private
	CPTXYGraph *pieChart;
	NSMutableArray *dataForChart;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart;

@end
