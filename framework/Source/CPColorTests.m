
#import "CPColorTests.h"
#import "CPColor.h"

@interface CPColor (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation CPColor (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder 
{
    [super gtm_unitTestEncodeState:inCoder];
    [self encodeWithCoder:inCoder];
}

@end


@implementation CPColorTests

- (void)testFactories 
{
    GTMAssertObjectStateEqualToStateNamed([CPColor clearColor], @"CPColorTests-testFactories-clearColor", @"");
    GTMAssertObjectStateEqualToStateNamed([CPColor whiteColor], @"CPColorTests-testFactories-whiteColor", @"");
    GTMAssertObjectStateEqualToStateNamed([CPColor blackColor], @"CPColorTests-testFactories-blackColor", @"");
    GTMAssertObjectStateEqualToStateNamed([CPColor redColor], @"CPColorTests-testFactories-redColor", @"");
}

- (void)testCGColorRoundTrip 
{
    CGFloat compValue = 0.2;
    
    CGColorRef expected = CGColorCreateGenericRGB(compValue, compValue, compValue, compValue);
    CPColor *cpColor = [[CPColor alloc] initWithCGColor:expected];
    
    GTMAssertObjectStateEqualToStateNamed(cpColor, @"CPColorTests-testCGColorRoundTrip", @"");
    
    const CGFloat *actual = CGColorGetComponents(cpColor.cgColor);
    
    for(int i=0; i<4; i++) {
        STAssertEqualsWithAccuracy(actual[i], compValue, .001f, @"round-trip CGColor components not equal");
    }
    
    [cpColor release];
    CFRelease(expected);
}

@end
