#import "CPTDarkGradientThemeTests.h"

#import "_CPTDarkGradientTheme.h"
#import "CPTXYGraphTestCase.h"

@implementation CPTDarkGradientThemeTests

-(void)testNewThemeShouldBeCPTXYGraph
{
    // Arrange
    CPTDarkGradientTheme *theme = [[CPTDarkGradientTheme alloc] init];

    // Act
    CPTGraph *graph = [theme newGraph];

    // Assert
    XCTAssertEqual([graph class], [CPTXYGraph class], @"graph should be of type CPTXYGraph");
}

-(void)testNewThemeSetGraphClassReturnedClassShouldBeOfCorrectType
{
    // Arrange
    CPTDarkGradientTheme *theme = [[CPTDarkGradientTheme alloc] init];

    theme.graphClass = [CPTXYGraphTestCase class];

    // Act
    CPTGraph *graph = [theme newGraph];

    // Assert
    XCTAssertEqual([graph class], [CPTXYGraphTestCase class], @"graph should be of type CPTXYGraphTestCase");
}

@end
