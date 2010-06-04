//
//  CPTestAppScatterPlotController.h
//  CPTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

#define NUM_POINTS 500

@interface CPTestAppScatterPlotController : UIViewController <CPPlotDataSource>
{
	CPXYGraph *graph;
    double xxx[NUM_POINTS] ;
    double yyy1[NUM_POINTS] ;
    double yyy2[NUM_POINTS] ;
}

@end
