#import "CPTLayer.h"

@class CPTPlot;

@interface CPTPlotGroup : CPTLayer {
}

/// @name Adding and Removing Plots
/// @{
-(void)addPlot:(CPTPlot *)plot;
-(void)removePlot:(CPTPlot *)plot;
///	@}

@end
