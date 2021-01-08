#import "_CPTPolarTheme.h"

#import "CPTPlotRange.h"
#import "CPTUtilities.h"
#import "CPTPolarGraph.h"
#import "CPTPolarPlotSpace.h"

/**
 *  @brief Creates a CPTPolarGraph instance formatted with padding of 60 on each side and X and Y plot ranges of +/- 1.
 **/
@implementation _CPTPolarTheme

/// @name Initialization
/// @{

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        self.graphClass = [CPTPolarGraph class];
    }
    return self;
}

/// @}

-(nullable id)newGraph
{
    CPTPolarGraph *graph;

    if ( self.graphClass ) {
        graph = [[self.graphClass alloc] initWithFrame:CPTRectMake(0.0, 0.0, 200.0, 200.0)];
    }
    else {
        graph = [[CPTPolarGraph alloc] initWithFrame:CPTRectMake(0.0, 0.0, 200.0, 200.0)];
    }
    graph.paddingLeft   = CPTFloat(60.0);
    graph.paddingTop    = CPTFloat(60.0);
    graph.paddingRight  = CPTFloat(60.0);
    graph.paddingBottom = CPTFloat(60.0);

    CPTPolarPlotSpace *plotSpace = (CPTPolarPlotSpace *)graph.defaultPlotSpace;
    plotSpace.majorRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@2.0];
    plotSpace.minorRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@2.0];

    [self applyThemeToGraph:graph];

    return graph;
}

#pragma mark -
#pragma mark NSCoding Methods

-(nonnull Class)classForCoder
{
    return [CPTTheme class];
}

@end
