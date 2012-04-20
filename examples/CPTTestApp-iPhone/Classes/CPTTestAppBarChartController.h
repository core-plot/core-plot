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

@property (readwrite, retain, nonatomic) NSTimer *timer;

-(void)timerFired;

@end
