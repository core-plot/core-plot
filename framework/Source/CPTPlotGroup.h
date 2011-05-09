#import "CPTLayer.h"

@class CPTPlot;

@interface CPTPlotGroup : CPTLayer {
	@private
	id <NSCopying, NSObject> identifier;
}

@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;

/// @name Adding and Removing Plots
/// @{
-(void)addPlot:(CPTPlot *)plot; 
-(void)removePlot:(CPTPlot *)plot;
///	@}

@end
