#import "CPTDefinitions.h"
#import "CPTUtilities.h"
#import "CPTUtilities.h"
#import "CPTUtilitiesTests.h"

@implementation CPTUtilitiesTests

-(void)testCPTDecimalIntegerValue
{
	NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];

	STAssertEquals(CPTDecimalIntegerValue([d decimalValue]), (NSInteger)42, @"Result incorrect");

	d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
	STAssertEquals( (NSInteger)CPTDecimalIntegerValue([d decimalValue]), (NSInteger)42, @"Result incorrect" );
}

-(void)testCPTDecimalFloatValue
{
	NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];

	STAssertEquals( (float)CPTDecimalFloatValue([d decimalValue]), (float)42.0, @"Result incorrect" );

	d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
	STAssertEquals( (float)CPTDecimalFloatValue([d decimalValue]), (float)42.1, @"Result incorrect" );
}

-(void)testCPTDecimalDoubleValue
{
	NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];

	STAssertEquals( (double)CPTDecimalDoubleValue([d decimalValue]), (double)42.0, @"Result incorrect" );

	d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
	STAssertEquals( (double)CPTDecimalDoubleValue([d decimalValue]), (double)42.1, @"Result incorrect" );
}

-(void)testToDecimalConversion
{
	NSInteger i			 = 100;
	NSUInteger unsignedI = 100;
	float f				 = 3.141f;
	double d			 = 42.1;

	STAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"100"], [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(i)], @"NSInteger to NSDecimal conversion failed");
	STAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"100"], [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromUnsignedInteger(unsignedI)], @"NSUInteger to NSDecimal conversion failed");
	STAssertEqualsWithAccuracy([[NSDecimalNumber numberWithFloat:f] floatValue], [[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromFloat(f)] floatValue], 1.0e-7, @"float to NSDecimal conversion failed");
	STAssertEqualObjects([NSDecimalNumber numberWithDouble:d], [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromDouble(d)], @"double to NSDecimal conversion failed.");
}

-(void)testCachedZero
{
	NSDecimal zero = [[NSDecimalNumber zero] decimalValue];
	NSDecimal testValue;
	NSString *errMessage;

	// signed conversions
	testValue  = CPTDecimalFromChar(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromShort(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromLong(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromLongLong(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromInt(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromInteger(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	// unsigned conversions
	testValue  = CPTDecimalFromUnsignedChar(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedShort(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedLong(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedLongLong(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedInt(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedInteger(0);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
}

-(void)testCachedOne
{
	NSDecimal one = [[NSDecimalNumber one] decimalValue];
	NSDecimal testValue;
	NSString *errMessage;

	// signed conversions
	testValue  = CPTDecimalFromChar(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromShort(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromLong(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromLongLong(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromInt(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromInteger(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	// unsigned conversions
	testValue  = CPTDecimalFromUnsignedChar(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedShort(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedLong(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedLongLong(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedInt(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromUnsignedInteger(1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
}

-(void)testConvertNegativeOne
{
	NSDecimal zero = [[NSDecimalNumber zero] decimalValue];
	NSDecimal one  = [[NSDecimalNumber one] decimalValue];
	NSDecimal negativeOne;

	NSDecimalSubtract(&negativeOne, &zero, &one, NSRoundPlain);
	NSDecimal testValue;
	NSString *errMessage;

	// signed conversions
	testValue  = CPTDecimalFromChar(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromShort(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromLong(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromLongLong(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromInt(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

	testValue  = CPTDecimalFromInteger(-1);
	errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil), nil];
	STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);
}

@end
