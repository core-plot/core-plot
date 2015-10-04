#import "CPTThemeTests.h"

#import "CPTDerivedXYGraph.h"
#import "CPTExceptions.h"
#import "CPTTheme.h"
#import "_CPTDarkGradientTheme.h"
#import "_CPTPlainBlackTheme.h"
#import "_CPTPlainWhiteTheme.h"
#import "_CPTSlateTheme.h"
#import "_CPTStocksTheme.h"

@implementation CPTThemeTests

-(void)testSetGraphClassUsingCPTXYGraphShouldWork
{
    CPTTheme *theme = [[CPTTheme alloc] init];

    [theme setGraphClass:[CPTXYGraph class]];
    XCTAssertEqual([CPTXYGraph class], theme.graphClass, @"graphClass should be CPTXYGraph");
}

-(void)testSetGraphUsingDerivedClassShouldWork
{
    CPTTheme *theme = [[CPTTheme alloc] init];

    [theme setGraphClass:[CPTDerivedXYGraph class]];
    XCTAssertEqual([CPTDerivedXYGraph class], theme.graphClass, @"graphClass should be CPTDerivedXYGraph");
}

-(void)testSetGraphUsingCPTGraphShouldThrowException
{
    CPTTheme *theme = [[CPTTheme alloc] init];

    @try {
        XCTAssertThrowsSpecificNamed([theme setGraphClass:[CPTGraph class]], NSException, CPTException, @"Should raise CPTException for wrong kind of class");
    }
    @finally {
        XCTAssertNil(theme.graphClass, @"graphClass should be nil.");
        theme = nil;
    }
}

-(void)testThemeNamedRandomNameShouldReturnNil
{
    CPTTheme *theme = [CPTTheme themeNamed:@"not a theme"];

    XCTAssertNil(theme, @"Should be nil");
}

-(void)testThemeNamedDarkGradientShouldReturnCPTDarkGradientTheme
{
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];

    XCTAssertTrue([theme isKindOfClass:[_CPTDarkGradientTheme class]], @"Should be _CPTDarkGradientTheme");
}

-(void)testThemeNamedPlainBlackShouldReturnCPTPlainBlackTheme
{
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];

    XCTAssertTrue([theme isKindOfClass:[_CPTPlainBlackTheme class]], @"Should be _CPTPlainBlackTheme");
}

-(void)testThemeNamedPlainWhiteShouldReturnCPTPlainWhiteTheme
{
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];

    XCTAssertTrue([theme isKindOfClass:[_CPTPlainWhiteTheme class]], @"Should be _CPTPlainWhiteTheme");
}

-(void)testThemeNamedStocksShouldReturnCPTStocksTheme
{
    CPTTheme *theme = [CPTTheme themeNamed:kCPTStocksTheme];

    XCTAssertTrue([theme isKindOfClass:[_CPTStocksTheme class]], @"Should be _CPTStocksTheme");
}

-(void)testThemeNamedSlateShouldReturnCPTSlateTheme
{
    CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];

    XCTAssertTrue([theme isKindOfClass:[_CPTSlateTheme class]], @"Should be _CPTSlateTheme");
}

@end
