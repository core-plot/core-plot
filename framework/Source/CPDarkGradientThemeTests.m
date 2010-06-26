#import "CPDarkGradientThemeTests.h"
#import "CPDarkGradientTheme.h"
#import "CPGraph.h"
#import "CPXYGraph.h"
#import "CPDerivedXYGraph.h"

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

@end
