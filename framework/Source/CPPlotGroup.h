#import "CPLayer.h"

@class CPPlot;

@interface CPPlotGroup : CPLayer {
	@private
	id <NSCopying, NSObject> identifier;
}

@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;

/// @name Adding and Removing Plots
/// @{
-(void)addPlot:(CPPlot *)plot; 
-(void)removePlot:(CPPlot *)plot;
///	@}

@end
