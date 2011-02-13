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

-(void)testCachedZero
{
	NSDecimal zero = [[NSDecimalNumber zero] decimalValue];
	NSDecimal testValue;
	NSString *errMessage;
	
	// signed conversions
	testValue = CPDecimalFromChar(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromShort(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromLong(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromLongLong(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromInt(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromInteger(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	// unsigned conversions
	testValue = CPDecimalFromUnsignedChar(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedShort(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedLong(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedLongLong(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedInt(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedInteger(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
}

-(void)testCachedOne
{
	NSDecimal one = [[NSDecimalNumber one] decimalValue];
	NSDecimal testValue;
	NSString *errMessage;
	
	// signed conversions
	testValue = CPDecimalFromChar(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromShort(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromLong(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromLongLong(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromInt(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromInteger(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	// unsigned conversions
	testValue = CPDecimalFromUnsignedChar(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedShort(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedLong(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedLongLong(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedInt(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromUnsignedInteger(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
}

-(void)testConvertNegativeOne
{
	NSDecimal zero = [[NSDecimalNumber zero] decimalValue];
	NSDecimal one = [[NSDecimalNumber one] decimalValue];
	NSDecimal negativeOne;
	NSDecimalSubtract(&negativeOne, &zero, &one, NSRoundPlain);
	NSDecimal testValue;
	NSString *errMessage;
	
	// signed conversions
	testValue = CPDecimalFromChar(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromShort(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromLong(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromLongLong(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromInt(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);
	
	testValue = CPDecimalFromInteger(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);
}

@end
