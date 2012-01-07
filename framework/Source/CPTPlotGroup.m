#import "CPTPlotGroup.h"

#import "CPTPlot.h"

/**
 *	@brief Defines the coordinate system of a plot.
 **/
@implementation CPTPlotGroup

/**	@property identifier
 *	@brief An object used to identify the plot group in collections.
 **/
@synthesize identifier;

#pragma mark -
#pragma mark Initialize/Deallocate

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPlotGroup object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @link CPTPlotGroup::identifier identifier @endlink = <code>nil</code>
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTPlotGroup object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		identifier = nil;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTPlotGroup *theLayer = (CPTPlotGroup *)layer;

		identifier = [theLayer->identifier retain];
	}
	return self;
}

-(void)dealloc
{
	[identifier release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.identifier forKey:@"CPTPlotGroup.identifier"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		identifier = [[coder decodeObjectForKey:@"CPTPlotGroup.identifier"] copy];
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
