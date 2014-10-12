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

@interface RootViewController : UITableViewController<APYahooDataPullerDelegate>

@property (nonatomic, readonly, strong) NSArray *symbols;

-(void)addSymbol:(NSString *)aSymbol;

@end
