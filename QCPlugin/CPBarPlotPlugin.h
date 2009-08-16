//
//  CPBarPlotPlugIn.h
//  CorePlotQCPlugIn
//
//  Created by Caleb Cannon on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CorePlotQCPlugIn.h"

@interface CPBarPlotPlugIn : CorePlotQCPlugIn<CPBarPlotDataSource>
{

}

@property(assign) double inputBaseValue;
@property(assign) double inputBarWidth;
@property(assign) double inputBarOffset;
@property(assign) BOOL inputHorizontalBars;

-(CPFill *) barFillForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSNumber *)index;

@end
