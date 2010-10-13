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

@interface APYahooDataPullerGraph : UIViewController <APYahooDataPullerDelegate, CPPlotDataSource> {
    CPGraphHostingView *graphHost;
    APYahooDataPuller *dataPuller;

@private
    CPXYGraph *graph;
}

@property (nonatomic, retain) IBOutlet CPGraphHostingView *graphHost;
@property (nonatomic, retain) APYahooDataPuller *dataPuller;

@end
