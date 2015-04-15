//
//  CPTTestAppBarChartController.h
//  CPTTestApp-iPhone
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppBarChartController : UIViewController<CPTPlotDataSource>

@property (nonatomic, readwrite, strong) NSTimer *timer;

-(void)timerFired;

@end
