//
// APYahooDataPullerGraph.h
// StockPlot
//
// Created by Jonathan Saggau on 6/19/09.
// Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface APYahooDataPullerGraph : UIViewController<APYahooDataPullerDelegate, CPTPlotDataSource>

@property (nonatomic, strong, nullable) IBOutlet CPTGraphHostingView *graphHost;
@property (nonatomic, strong, nonnull) APYahooDataPuller *dataPuller;

@end
