
#import "CPUtilitiesTests.h"
#import "CPDefinitions.h"

@implementation CPUtilitiesTests
- (void)testCPDecimalIntegerValue {
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];
    STAssertEquals(CPDecimalIntegerValue([d decimalValue]), (CPInteger)42, @"Result incorrect");
    
    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals((CPInteger)CPDecimalIntegerValue([d decimalValue]), (CPInteger)42, @"Result incorrect");
}

- (void)testCPDecimalFloatValue {
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];
    STAssertEquals((CPFloat)CPDecimalFloatValue([d decimalValue]), (CPFloat)42., @"Result incorrect");
    
    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals((CPFloat)CPDecimalFloatValue([d decimalValue]), (CPFloat)42.1, @"Result incorrect");
}

- (void)testCPDecimalDoubleValue {
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];
    STAssertEquals((CPDouble)CPDecimalDoubleValue([d decimalValue]), (CPDouble)42., @"Result incorrect");
    
    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals((CPDouble)CPDecimalDoubleValue([d decimalValue]), (CPDouble)42.1, @"Result incorrect");
}

- (void)testToDecimalConversion {
    CPInteger i = 100;
    CPFloat f = 3.141;
    CPDouble d = 42.1;
    
    STAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"100"], [NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromInt(i)], @"CPInteger to NSDecimal conversion failed");
    STAssertEqualObjects([NSDecimalNumber numberWithFloat:f], [NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromFloat(f)], @"CPFloat to NSDecimal conversion failed");
    STAssertEqualObjects([NSDecimalNumber numberWithDouble:d], [NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromDouble(d)], @"CPDouble to NSDecimal conversion failed.");
}

@end
