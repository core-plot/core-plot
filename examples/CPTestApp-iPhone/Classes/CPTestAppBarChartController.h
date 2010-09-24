//
//  CPTestAppBarChartController.h
//  CPTestApp-iPhone
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTestAppBarChartController : UIViewController <CPPlotDataSource>
{
@private
	CPXYGraph *barChart;
	NSTimer *timer;
}

@property(readwrite, retain, nonatomic) NSTimer *timer;

-(void)timerFired;

@end
