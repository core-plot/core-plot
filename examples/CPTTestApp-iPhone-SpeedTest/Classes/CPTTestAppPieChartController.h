#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppPieChartController : UIViewController<CPTPieChartDataSource>

@property (nonatomic, readwrite, strong) NSArray *dataForChart;

@end
