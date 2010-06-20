//
//  RootViewController.h
//  StockPlot
//
//  Created by Jonathan Saggau on 6/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "APYahooDataPuller.h"
#import "APYahooDataPullerGraph.h"

NSTimeInterval timeIntervalForNumberOfWeeks(float numberOfWeeks);

@interface RootViewController : UITableViewController <APYahooDataPullerDelegate> {
        
@private
    NSMutableArray *stocks;
    APYahooDataPullerGraph *graph;
}

@property(nonatomic, readonly)NSArray *symbols;

- (void)addSymbol:(NSString *)aSymbol;

@end
