//
//  CPTTestAppScatterPlotController.h
//  CPTTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppScatterPlotController : UIViewController<CPTPlotDataSource, CPTAxisDelegate>

@property (nonatomic, readwrite, strong) NSMutableArray *dataForPlot;

@end
