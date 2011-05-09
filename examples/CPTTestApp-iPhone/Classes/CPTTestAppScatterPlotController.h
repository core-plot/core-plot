//
//  CPTTestAppScatterPlotController.h
//  CPTTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CPTTestAppScatterPlotController : UIViewController <CPTPlotDataSource>
{
	CPTXYGraph *graph;
	
	NSMutableArray *dataForPlot;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForPlot;

@end
