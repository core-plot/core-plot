#import "_CPTXYTheme.h"

#import "CPTPlotRange.h"
#import "CPTUtilities.h"
#import "CPTXYGraph.h"
#import "CPTXYPlotSpace.h"

/**
 *  @brief Creates a CPTXYGraph instance formatted with padding of 60 on each side and X and Y plot ranges of +/- 1.
 **/
@implementation _CPTXYTheme

/// @name Initialization
/// @{

-(id)init
{
    if ( (self = [super init]) ) {
        self.graphClass = [CPTXYGraph class];
    }
    return self;
}

/// @}

-(id)newGraph
{
    CPTXYGraph *graph;

    if ( self.graphClass ) {
        graph = [(CPTXYGraph *)[self.graphClass alloc] initWithFrame:CPTRectMake(0.0, 0.0, 200.0, 200.0)];
    }
    else {
        graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CPTRectMake(0.0, 0.0, 200.0, 200.0)];
    }
    graph.paddingLeft   = CPTFloat(60.0);
    graph.paddingTop    = CPTFloat(60.0);
    graph.paddingRight  = CPTFloat(60.0);
    graph.paddingBottom = CPTFloat(60.0);

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-1.0) length:CPTDecimalFromDouble(1.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-1.0) length:CPTDecimalFromDouble(1.0)];

    [self applyThemeToGraph:graph];

    return graph;
}

#pragma mark -
#pragma mark NSCoding Methods

-(Class)classForCoder
{
    return [CPTTheme class];
}

@end
