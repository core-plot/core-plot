#import "CPThemeTests.h"
#import "CPTheme.h"
#import "CPXYGraph.h"
#import "CPGraph.h"
#import "CPExceptions.h"
#import "CPDarkGradientTheme.h"
#import "CPPlainBlackTheme.h"
#import "CPPlainWhiteTheme.h"
#import "CPStocksTheme.h"
#import "CPDerivedXYGraph.h"

@implementation CPThemeTests

-(void)testSetGraphClassUsingCPXYGraphShouldWork
{
	CPTheme *theme = [[CPTheme alloc] init];
	[theme setGraphClass:[CPXYGraph class]];
	STAssertEquals([CPXYGraph class], theme.graphClass, @"graphClass should be CPXYGraph");
	[theme release];
}

-(void)testSetGraphUsingDerivedClassShouldWork
{
	CPTheme *theme = [[CPTheme alloc] init];
	[theme setGraphClass:[CPDerivedXYGraph class]];
	STAssertEquals([CPDerivedXYGraph class], theme.graphClass, @"graphClass should be CPDerivedXYGraph");
	[theme release];
}

-(void)testSetGraphUsingCPGraphShouldThrowException
{
	CPTheme *theme = [[CPTheme alloc] init];
	@try {
		STAssertThrowsSpecificNamed([theme setGraphClass:[CPGraph class]], NSException, CPException, @"Should raise CPException for wrong kind of class"); 
	}
	@finally {
		STAssertNil(theme.graphClass, @"graphClass should be nil.");
		[theme release];
	}
}

-(void)testThemeNamedRandomNameShouldReturnNil
{
	CPTheme *theme = [CPTheme themeNamed:@"not a theme"];
	STAssertNil(theme, @"Should be nil");
}

-(void)testThemeNamedDarkGradientShouldReturnCPDarkGradientTheme 
{
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	STAssertTrue([theme isKindOfClass:[CPDarkGradientTheme class]], @"Should be CPDarkGradientTheme");
}

-(void)testThemeNamedPlainBlackShouldReturnCPPlainBlackTheme 
{
	CPTheme *theme = [CPTheme themeNamed:kCPPlainBlackTheme];
	STAssertTrue([theme isKindOfClass:[CPPlainBlackTheme class]], @"Should be CPPlainBlackTheme");
}

-(void)testThemeNamedPlainWhiteShouldReturnCPPlainWhiteTheme 
{
	CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
	STAssertTrue([theme isKindOfClass:[CPPlainWhiteTheme class]], @"Should be CPPlainWhiteTheme");
}

-(void)testThemeNamedStocksShouldReturnCPStocksTheme 
{
	CPTheme *theme = [CPTheme themeNamed:kCPStocksTheme];
	STAssertTrue([theme isKindOfClass:[CPStocksTheme class]], @"Should be CPStocksTheme");
}

@end
