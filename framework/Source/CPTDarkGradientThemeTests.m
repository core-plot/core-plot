#import "CPTDarkGradientThemeTests.h"
#import "CPTDerivedXYGraph.h"
#import "CPTGraph.h"
#import "CPTXYGraph.h"
#import "_CPTDarkGradientTheme.h"

@implementation CPTDarkGradientThemeTests

-(void)testNewThemeShouldBeCPTXYGraph
{
	// Arrange
	_CPTDarkGradientTheme *theme = [[_CPTDarkGradientTheme alloc] init];

	// Act
	CPTGraph *graph = [theme newGraph];

	// Assert
	STAssertEquals([graph class], [CPTXYGraph class], @"graph should be of type CPTXYGraph");
	[theme release];
}

-(void)testNewThemeSetGraphClassReturnedClassShouldBeOfCorrectType
{
	// Arrange
	_CPTDarkGradientTheme *theme = [[_CPTDarkGradientTheme alloc] init];

	[theme setGraphClass:[CPTDerivedXYGraph class]];

	// Act
	CPTGraph *graph = [theme newGraph];

	// Assert
	STAssertEquals([graph class], [CPTDerivedXYGraph class], @"graph should be of type CPTDerivedXYGraph");
	[theme release];
}

@end
