//
//  CPTTestAppBarChartController.h
//  CPTTestApp-iPhone
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppBarChartController : UIViewController<CPTPlotDataSource>
{
    @private
    CPTXYGraph *barChart;
    NSTimer *timer;
}

@property (readwrite, strong, nonatomic) NSTimer *timer;

-(void)timerFired;

@end
