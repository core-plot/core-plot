#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppPieChartController : UIViewController<CPTPieChartDataSource, CPTPieChartDelegate>

@property (nonatomic, readwrite, strong) NSArray *dataForChart;
@property (nonatomic, readwrite, strong) NSTimer *timer;

-(void)timerFired;

@end
