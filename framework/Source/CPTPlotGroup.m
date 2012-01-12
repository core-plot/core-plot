#import "CPTPlotGroup.h"

#import "CPTPlot.h"

/**
 *	@brief Defines the coordinate system of a plot.
 **/
@implementation CPTPlotGroup

#pragma mark -
#pragma mark NSCoding methods

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		// support old archives
		if ( [coder containsValueForKey:@"CPTPlotGroup.identifier"] ) {
			self.identifier = [coder decodeObjectForKey:@"CPTPlotGroup.identifier"];
		}
	}
	return self;
}

#pragma mark -
#pragma mark Organizing Plots

/**	@brief Add a plot to this plot group.
 *	@param plot The plot.
 **/
-(void)addPlot:(CPTPlot *)plot
{
	[self addSublayer:plot];
}

/**	@brief Remove a plot from this plot group.
 *	@param plot The plot to remove.
 **/
-(void)removePlot:(CPTPlot *)plot
{
	if ( self == [plot superlayer] ) {
		[plot removeFromSuperlayer];
	}
}

#pragma mark -
#pragma mark Drawing

///	@cond

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	// nothing to draw
}

///	@endcond

@end
