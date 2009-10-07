#import "CPPlotGroup.h"
#import "CPPlot.h"

/**	@brief Defines the coordinate system of a plot.
 **/
@implementation CPPlotGroup

/**	@property identifier
 *	@brief An object used to identify the plot group in collections.
 **/
@synthesize identifier;

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		self.masksToBounds = YES;
	}
	return self;
}

#pragma mark -
#pragma mark Organizing Plots

/**	@brief Add a plot to the default plot space.
 *	@param plot The plot.
 **/
-(void)addPlot:(CPPlot *)plot
{
	[self addSublayer:plot];
}

-(void)removePlot:(CPPlot *)plot
{
	if ( self == [plot superlayer] ) {
		[plot removeFromSuperlayer];
	}
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotGroup;
}

@end
