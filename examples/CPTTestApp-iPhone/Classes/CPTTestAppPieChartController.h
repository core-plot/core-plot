#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppPieChartController : UIViewController<CPTPieChartDataSource, CPTPieChartDelegate>
{
    @private
    CPTXYGraph *pieChart;
    NSMutableArray *dataForChart;
    NSTimer *timer;
}

@property (readwrite, strong, nonatomic) NSMutableArray *dataForChart;
@property (readwrite, strong, nonatomic) NSTimer *timer;

-(void)timerFired;

@end
