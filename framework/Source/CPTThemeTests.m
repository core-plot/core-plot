#import "CPTDerivedXYGraph.h"
#import "CPTExceptions.h"
#import "CPTGraph.h"
#import "CPTTheme.h"
#import "CPTThemeTests.h"
#import "CPTXYGraph.h"
#import "_CPTDarkGradientTheme.h"
#import "_CPTPlainBlackTheme.h"
#import "_CPTPlainWhiteTheme.h"
#import "_CPTStocksTheme.h"

@implementation CPTThemeTests

-(void)testSetGraphClassUsingCPTXYGraphShouldWork
{
	CPTTheme *theme = [[CPTTheme alloc] init];

	[theme setGraphClass:[CPTXYGraph class]];
	STAssertEquals([CPTXYGraph class], theme.graphClass, @"graphClass should be CPTXYGraph");
	[theme release];
}

-(void)testSetGraphUsingDerivedClassShouldWork
{
	CPTTheme *theme = [[CPTTheme alloc] init];

	[theme setGraphClass:[CPTDerivedXYGraph class]];
	STAssertEquals([CPTDerivedXYGraph class], theme.graphClass, @"graphClass should be CPTDerivedXYGraph");
	[theme release];
}

-(void)testSetGraphUsingCPTGraphShouldThrowException
{
	CPTTheme *theme = [[CPTTheme alloc] init];

	@try {
		STAssertThrowsSpecificNamed([theme setGraphClass:[CPTGraph class]], NSException, CPTException, @"Should raise CPTException for wrong kind of class");
	}
	@finally {
		STAssertNil(theme.graphClass, @"graphClass should be nil.");
		[theme release];
	}
}

-(void)testThemeNamedRandomNameShouldReturnNil
{
	CPTTheme *theme = [CPTTheme themeNamed:@"not a theme"];

	STAssertNil(theme, @"Should be nil");
}

-(void)testThemeNamedDarkGradientShouldReturnCPTDarkGradientTheme
{
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];

	STAssertTrue([theme isKindOfClass:[_CPTDarkGradientTheme class]], @"Should be CPTDarkGradientTheme");
}

-(void)testThemeNamedPlainBlackShouldReturnCPTPlainBlackTheme
{
	CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];

	STAssertTrue([theme isKindOfClass:[_CPTPlainBlackTheme class]], @"Should be CPTPlainBlackTheme");
}

-(void)testThemeNamedPlainWhiteShouldReturnCPTPlainWhiteTheme
{
	CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];

	STAssertTrue([theme isKindOfClass:[_CPTPlainWhiteTheme class]], @"Should be CPTPlainWhiteTheme");
}

-(void)testThemeNamedStocksShouldReturnCPTStocksTheme
{
	CPTTheme *theme = [CPTTheme themeNamed:kCPTStocksTheme];

	STAssertTrue([theme isKindOfClass:[_CPTStocksTheme class]], @"Should be CPTStocksTheme");
}

@end
