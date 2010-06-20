
#import "CPUtilities.h"
#import "CPUtilitiesTests.h"
#import "CPDefinitions.h"
#import "CPUtilities.h"

@implementation CPUtilitiesTests

-(void)testCPDecimalIntegerValue 
{
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];
    STAssertEquals(CPDecimalIntegerValue([d decimalValue]), (NSInteger)42, @"Result incorrect");
    
    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals((NSInteger)CPDecimalIntegerValue([d decimalValue]), (NSInteger)42, @"Result incorrect");
}

-(void)testCPDecimalFloatValue 
{
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];
    STAssertEquals((float)CPDecimalFloatValue([d decimalValue]), (float)42.0, @"Result incorrect");
    
    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals((float)CPDecimalFloatValue([d decimalValue]), (float)42.1, @"Result incorrect");
}

-(void)testCPDecimalDoubleValue 
{
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];
    STAssertEquals((double)CPDecimalDoubleValue([d decimalValue]), (double)42.0, @"Result incorrect");
    
    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals((double)CPDecimalDoubleValue([d decimalValue]), (double)42.1, @"Result incorrect");
}

-(void)testToDecimalConversion 
{
    NSInteger i = 100;
	NSUInteger unsignedI = 100;
    float f = 3.141f;
    double d = 42.1;
    
    STAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"100"], [NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromInteger(i)], @"NSInteger to NSDecimal conversion failed");
    STAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"100"], [NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromUnsignedInteger(unsignedI)], @"NSUInteger to NSDecimal conversion failed");
    STAssertEqualsWithAccuracy([[NSDecimalNumber numberWithFloat:f] floatValue], [[NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromFloat(f)] floatValue], 1.0e-7, @"float to NSDecimal conversion failed");
    STAssertEqualObjects([NSDecimalNumber numberWithDouble:d], [NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromDouble(d)], @"double to NSDecimal conversion failed.");
}

@end
