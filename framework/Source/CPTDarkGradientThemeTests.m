#import "CPTDarkGradientThemeTests.h"
#import "CPTDarkGradientTheme.h"
#import "CPTGraph.h"
#import "CPTXYGraph.h"
#import "CPTDerivedXYGraph.h"

@implementation CPTDarkGradientThemeTests

-(void)testNewThemeShouldBeCPTXYGraph
{
	// Arrange
	CPTDarkGradientTheme *theme = [[CPTDarkGradientTheme alloc] init];
    
	// Act
	CPTGraph *graph = [theme newGraph];
    
	// Assert
	STAssertEquals([graph class], [CPTXYGraph class], @"graph should be of type CPTXYGraph");	
	[theme release];
}

-(void)testNewThemeSetGraphClassReturnedClassShouldBeOfCorrectType
{
	// Arrange
	CPTDarkGradientTheme *theme = [[CPTDarkGradientTheme alloc] init];
	[theme setGraphClass:[CPTDerivedXYGraph class]];
    
	// Act
	CPTGraph *graph = [theme newGraph];
    
	// Assert
	STAssertEquals([graph class], [CPTDerivedXYGraph class], @"graph should be of type CPTDerivedXYGraph");	
	[theme release];
}

@end
