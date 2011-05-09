//
//  APYahooDataPullerGraph.h
//  StockPlot
//
//  Created by Jonathan Saggau on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"

@interface APYahooDataPullerGraph : UIViewController <APYahooDataPullerDelegate, CPTPlotDataSource> {
    CPTGraphHostingView *graphHost;
    APYahooDataPuller *dataPuller;

@private
    CPTXYGraph *graph;
}

@property (nonatomic, retain) IBOutlet CPTGraphHostingView *graphHost;
@property (nonatomic, retain) APYahooDataPuller *dataPuller;

@end
