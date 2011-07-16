#import "CPTPlotGroup.h"
#import "CPTPlot.h"

/**	@brief Defines the coordinate system of a plot.
 **/
@implementation CPTPlotGroup

/**	@property identifier
 *	@brief An object used to identify the plot group in collections.
 **/
@synthesize identifier;

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		identifier = nil;
	}
	return self;
}

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

/**	@brief Add a plot to the default plot space.
 *	@param plot The plot.
 **/
-(void)addPlot:(CPTPlot *)plot
{
	[self addSublayer:plot];
}

-(void)removePlot:(CPTPlot *)plot
{
	if ( self == [plot superlayer] ) {
		[plot removeFromSuperlayer];
	}
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	// nothing to draw
}

@end
