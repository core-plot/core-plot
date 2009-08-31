
#import "CPXYTheme.h"
#import "CPXYGraph.h"
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"

@implementation CPXYTheme

-(id)newGraph 
{
    CPXYGraph *graph;
	if (self.graphClass) {
		graph = [(CPXYGraph *)[self.graphClass alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	}
	else {
		graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	}
	
	graph.paddingLeft = 60.0;
	graph.paddingTop = 60.0;
	graph.paddingRight = 60.0;
	graph.paddingBottom = 60.0;
    
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(1.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(1.0)];
    
    [self applyThemeToGraph:graph];
    
	return graph;
}

+(Class)requiredGraphSubclass
{
    return [CPXYGraph class];
}

@end
