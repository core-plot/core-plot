#import "_CPTXYTheme.h"

#import "CPTPlotRange.h"
#import "CPTUtilities.h"
#import "CPTXYGraph.h"
#import "CPTXYPlotSpace.h"

/**
 *	@brief Creates a CPTXYGraph instance formatted with padding of 60 on each side and X and Y plot ranges of +/- 1.
 **/
@implementation _CPTXYTheme

-(id)init
{
	if ( (self = [super init]) ) {
		self.graphClass = [CPTXYGraph class];
	}
	return self;
}

-(id)newGraph
{
	CPTXYGraph *graph;

	if ( self.graphClass ) {
		graph = [(CPTXYGraph *)[self.graphClass alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	}
	else {
		graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	}
	graph.paddingLeft	= 60.0;
	graph.paddingTop	= 60.0;
	graph.paddingRight	= 60.0;
	graph.paddingBottom = 60.0;

	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-1.0) length:CPTDecimalFromDouble(1.0)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-1.0) length:CPTDecimalFromDouble(1.0)];

	[self applyThemeToGraph:graph];

	return graph;
}

#pragma mark -
#pragma mark NSCoding methods

-(Class)classForCoder
{
	return [CPTTheme class];
}

@end
