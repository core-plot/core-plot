
#import "CPPlotAreaTests.h"
#import <CorePlot/CorePlot.h>
#import "GTMNSObject+BindingUnitTesting.h"
#import "GTMNSObject+UnitTesting.h"


@interface CPPlotArea (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end


@implementation CPPlotArea (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder
{
    [super gtm_unitTestEncodeState:inCoder];
    
    [inCoder encodeObject:self.fill forKey:@"FillInstanceVariable"];
}

@end


@implementation CPPlotAreaTests

-(void)testBindings
{
    CPPlotArea *plotArea = [[CPPlotArea alloc] init];
    NSArray *errors;
    STAssertTrue(GTMDoExposedBindingsFunctionCorrectly(plotArea, &errors), @"CPPlotArea bindings do not work as expected: %@", errors);
    
    [plotArea release];
}

-(void)testDrawInContextRendersAsExpected
{
    CPPlotArea *plotArea = [[CPPlotArea alloc] init];
    [plotArea setFrame:CGRectMake(0, 0, 50, 50)];
    [plotArea setBounds:CGRectMake(0, 0, 50, 50)];
    
	plotArea.fill = [CPFill fillWithColor:[CPColor blueColor]];
	
    GTMAssertObjectImageEqualToImageNamed(plotArea, @"CPPlotAreaTests-testDrawInContextRendersAsExpected-blueFill", @"");
    
    [plotArea release];
}

@end
