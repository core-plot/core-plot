//
//  APYahooDataPullerGraph.h
//  StockPlot
//
//  Created by Jonathan Saggau on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface APYahooDataPullerGraph : UIViewController<APYahooDataPullerDelegate, CPTPlotDataSource> {
    CPTGraphHostingView *graphHost;
    APYahooDataPuller *dataPuller;

    @private
    CPTXYGraph *graph;
}

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *graphHost;
@property (nonatomic, strong) APYahooDataPuller *dataPuller;

@end
