#import "CPDarkGradientThemeTests.h"
#import "CPDarkGradientTheme.h"
#import "CPGraph.h"
#import "CPPlotRange.h"
#import "CPXYGraph.h"
#import "CPDerivedXYGraph.h"
#import "CPXYPlotSpace.h"
#import "CPXYAxisSet.h"
#import "CPUtilities.h"

@implementation CPDarkGradientThemeTests

-(void)testNewThemeShouldBeCPXYGraph
{
	// Arrange
	CPDarkGradientTheme *theme = [[CPDarkGradientTheme alloc] init];
    
	// Act
	CPGraph *graph = [theme newGraph];
    
	// Assert
	STAssertEquals([graph class], [CPXYGraph class], @"graph should be of type CPXYGraph");	
	[theme release];
}

-(void)testNewThemeSetGraphClassReturnedClassShouldBeOfCorrectType
{
	// Arrange
	CPDarkGradientTheme *theme = [[CPDarkGradientTheme alloc] init];
	[theme setGraphClass:[CPDerivedXYGraph class]];
    
	// Act
	CPGraph *graph = [theme newGraph];
    
	// Assert
	STAssertEquals([graph class], [CPDerivedXYGraph class], @"graph should be of type CPDerivedXYGraph");	
	[theme release];
}

-(CPXYGraph *)createTestGraph
{
    CPXYGraph *graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	graph.paddingLeft = 20.0;
	graph.paddingTop = 20.0;
	graph.paddingRight = 20.0;
	graph.paddingBottom = 20.0;
    
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)];
	
    return [graph autorelease];
}

@end
