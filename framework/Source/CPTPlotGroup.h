#import "CPTLayer.h"

@class CPTPlot;

@interface CPTPlotGroup : CPTLayer

/// @name Adding and Removing Plots
/// @{
-(void)addPlot:(nonnull CPTPlot *)plot cpt_requires_super;
-(void)removePlot:(nullable CPTPlot *)plot cpt_requires_super;
-(void)insertPlot:(nonnull CPTPlot *)plot atIndex:(NSUInteger)idx cpt_requires_super;
/// @}

@end
