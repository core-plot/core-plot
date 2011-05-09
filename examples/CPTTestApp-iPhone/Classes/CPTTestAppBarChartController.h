//
//  CPTTestAppBarChartController.h
//  CPTTestApp-iPhone
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTTestAppBarChartController : UIViewController <CPTPlotDataSource>
{
@private
	CPTXYGraph *barChart;
	NSTimer *timer;
}

@property(readwrite, retain, nonatomic) NSTimer *timer;

-(void)timerFired;

@end
