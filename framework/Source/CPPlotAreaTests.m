
#import "CPPlotAreaTests.h"

#import <CorePlot/CPPlotArea.h>

#import "GTMNSObject+BindingUnitTesting.h"
#import "GTMNSObject+UnitTesting.h"

@implementation CPPlotAreaTests
- (void)testBindings {
    CPPlotArea *plotArea = [[CPPlotArea alloc] init];
    NSArray *errors;
    STAssertTrue(GTMDoExposedBindingsFunctionCorrectly(plotArea, &errors), @"CPPlotArea bindings do not work as expected: %@", errors);
    
    [plotArea release];
}

- (void)testDrawInContextRendersAsExpected {
    CPPlotArea *plotArea = [[CPPlotArea alloc] init];
    [plotArea setFrame:CGRectMake(0, 0, 50, 50)];
    [plotArea setBounds:CGRectMake(0, 0, 50, 50)];
    
    GTMAssertObjectEqualToStateAndImageNamed(plotArea, @"CPPlotAreaTests-testDrawInContextRendersAsExpected", @"");
    
    [plotArea release];
}
@end
