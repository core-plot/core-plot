//
//  CPTTestAppScatterPlotController.h
//  CPTTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppScatterPlotController : UIViewController<CPTPlotDataSource, CPTAxisDelegate>
{
	CPTXYGraph *graph;

	NSMutableArray *dataForPlot;
}

@property (readwrite, retain, nonatomic) NSMutableArray *dataForPlot;

@end
