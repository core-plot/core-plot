#import "CPTNumericData+TypeConversion.h"
#import "CPTNumericData.h"
#import "CPTNumericDataTypeConversionTests.h"
#import "CPTUtilities.h"

static const NSUInteger numberOfSamples = 5;
static const double precision			= 1.0e-6;

@implementation CPTNumericDataTypeConversionTests

-(void)testFloatToDoubleConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(float)];
	float *samples		= (float *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sinf(i);
	}

	CPTNumericData *fd = [[CPTNumericData alloc] initWithData:data
													 dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
														shape:nil];

	CPTNumericData *dd = [fd dataByConvertingToType:CPTFloatingPointDataType
										sampleBytes:sizeof(double)
										  byteOrder:NSHostByteOrder()];

	[fd release];

	const double *doubleSamples = (const double *)[dd.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy( (double)samples[i], doubleSamples[i], precision, @"(float)%g != (double)%g", samples[i], doubleSamples[i] );
	}
}

-(void)testDoubleToFloatConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(double)];
	double *samples		= (double *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}

	CPTNumericData *dd = [[CPTNumericData alloc] initWithData:data
													 dataType:CPTDataType( CPTFloatingPointDataType, sizeof(double), NSHostByteOrder() )
														shape:nil];

	CPTNumericData *fd = [dd dataByConvertingToType:CPTFloatingPointDataType
										sampleBytes:sizeof(float)
										  byteOrder:NSHostByteOrder()];

	[dd release];

	const float *floatSamples = (const float *)[fd.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy( (double)floatSamples[i], samples[i], precision, @"(float)%g != (double)%g", floatSamples[i], samples[i] );
	}
}

-(void)testFloatToIntegerConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(float)];
	float *samples		= (float *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sinf(i) * 1000.0f;
	}

	CPTNumericData *fd = [[CPTNumericData alloc] initWithData:data
													 dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
														shape:nil];

	CPTNumericData *intData = [fd dataByConvertingToType:CPTIntegerDataType
											 sampleBytes:sizeof(NSInteger)
											   byteOrder:NSHostByteOrder()];

	[fd release];

	const NSInteger *intSamples = (const NSInteger *)[intData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy( (NSInteger)samples[i], intSamples[i], precision, @"(float)%g != (NSInteger)%ld", samples[i], (long)intSamples[i] );
	}
}

-(void)testIntegerToFloatConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(NSInteger)];
	NSInteger *samples	= (NSInteger *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i) * 1000.0;
	}

	CPTNumericData *intData = [[CPTNumericData alloc] initWithData:data
														  dataType:CPTDataType( CPTIntegerDataType, sizeof(NSInteger), NSHostByteOrder() )
															 shape:nil];

	CPTNumericData *fd = [intData dataByConvertingToType:CPTFloatingPointDataType
											 sampleBytes:sizeof(float)
											   byteOrder:NSHostByteOrder()];

	[intData release];

	const float *floatSamples = (const float *)[fd.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy(floatSamples[i], (float)samples[i], precision, @"(float)%g != (NSInteger)%ld", floatSamples[i], (long)samples[i]);
	}
}

-(void)testTypeConversionSwapsByteOrderInteger
{
	CFByteOrder hostByteOrder	 = CFByteOrderGetCurrent();
	CFByteOrder swappedByteOrder = (hostByteOrder == CFByteOrderBigEndian) ? CFByteOrderLittleEndian : CFByteOrderBigEndian;

	uint32_t start	  = 1000;
	NSData *startData = [NSData dataWithBytesNoCopy:&start
											 length:sizeof(uint32_t)
									   freeWhenDone:NO];

	CPTNumericData *intData = [[CPTNumericData alloc] initWithData:startData
														  dataType:CPTDataType(CPTUnsignedIntegerDataType, sizeof(uint32_t), hostByteOrder)
															 shape:nil];

	CPTNumericData *swappedData = [intData dataByConvertingToType:CPTUnsignedIntegerDataType
													  sampleBytes:sizeof(uint32_t)
														byteOrder:swappedByteOrder];

	[intData release];

	uint32_t end = *(const uint32_t *)swappedData.bytes;
	STAssertEquals(CFSwapInt32(start), end, @"Bytes swapped");

	CPTNumericData *roundTripData = [swappedData dataByConvertingToType:CPTUnsignedIntegerDataType
															sampleBytes:sizeof(uint32_t)
															  byteOrder:hostByteOrder];

	uint32_t startRoundTrip = *(const uint32_t *)roundTripData.bytes;
	STAssertEquals(start, startRoundTrip, @"Round trip");
}

-(void)testDecimalToDoubleConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(NSDecimal)];
	NSDecimal *samples	= (NSDecimal *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = CPTDecimalFromDouble( sin(i) );
	}

	CPTNumericData *decimalData = [[CPTNumericData alloc] initWithData:data
															  dataType:CPTDataType( CPTDecimalDataType, sizeof(NSDecimal), NSHostByteOrder() )
																 shape:nil];

	CPTNumericData *doubleData = [decimalData dataByConvertingToType:CPTFloatingPointDataType
														 sampleBytes:sizeof(double)
														   byteOrder:NSHostByteOrder()];

	[decimalData release];

	const double *doubleSamples = (const double *)[doubleData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEquals(CPTDecimalDoubleValue(samples[i]), doubleSamples[i], @"(NSDecimal)%@ != (double)%g", CPTDecimalStringValue(samples[i]), doubleSamples[i]);
	}
}

-(void)testDoubleToDecimalConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(double)];
	double *samples		= (double *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}

	CPTNumericData *doubleData = [[CPTNumericData alloc] initWithData:data
															 dataType:CPTDataType( CPTFloatingPointDataType, sizeof(double), NSHostByteOrder() )
																shape:nil];

	CPTNumericData *decimalData = [doubleData dataByConvertingToType:CPTDecimalDataType
														 sampleBytes:sizeof(NSDecimal)
														   byteOrder:NSHostByteOrder()];

	[doubleData release];

	const NSDecimal *decimalSamples = (const NSDecimal *)[decimalData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertTrue(CPTDecimalEquals( decimalSamples[i], CPTDecimalFromDouble(samples[i]) ), @"(NSDecimal)%@ != (double)%g", CPTDecimalStringValue(decimalSamples[i]), samples[i]);
	}
}

-(void)testTypeConversionSwapsByteOrderDouble
{
	CFByteOrder hostByteOrder	 = CFByteOrderGetCurrent();
	CFByteOrder swappedByteOrder = (hostByteOrder == CFByteOrderBigEndian) ? CFByteOrderLittleEndian : CFByteOrderBigEndian;

	double start	  = 1000.0;
	NSData *startData = [NSData dataWithBytesNoCopy:&start
											 length:sizeof(double)
									   freeWhenDone:NO];

	CPTNumericData *doubleData = [[CPTNumericData alloc] initWithData:startData
															 dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), hostByteOrder)
																shape:nil];

	CPTNumericData *swappedData = [doubleData dataByConvertingToType:CPTFloatingPointDataType
														 sampleBytes:sizeof(double)
														   byteOrder:swappedByteOrder];

	[doubleData release];

	uint64_t end = *(const uint64_t *)swappedData.bytes;
	union swap {
		double v;
		CFSwappedFloat64 sv;
	}
	result;
	result.v = start;
	STAssertEquals(CFSwapInt64(result.sv.v), end, @"Bytes swapped");

	CPTNumericData *roundTripData = [swappedData dataByConvertingToType:CPTFloatingPointDataType
															sampleBytes:sizeof(double)
															  byteOrder:hostByteOrder];

	double startRoundTrip = *(const double *)roundTripData.bytes;
	STAssertEquals(start, startRoundTrip, @"Round trip");
}

-(void)testRoundTripToDoubleArray
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(double)];
	double *samples		= (double *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}
	CPTNumericDataType theDataType = CPTDataType( CPTFloatingPointDataType, sizeof(double), NSHostByteOrder() );

	CPTNumericData *doubleData = [[CPTNumericData alloc] initWithData:data
															 dataType:theDataType
																shape:nil];

	NSArray *doubleArray = [doubleData sampleArray];
	STAssertEquals(doubleArray.count, numberOfSamples, @"doubleArray size");

	CPTNumericData *roundTripData = [[CPTNumericData alloc] initWithArray:doubleArray
																 dataType:theDataType
																	shape:nil];
	STAssertEquals(roundTripData.numberOfSamples, numberOfSamples, @"roundTripData size");

	const double *roundTrip = (const double *)roundTripData.bytes;
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEquals(samples[i], roundTrip[i], @"Round trip");
	}

	[doubleData release];
	[roundTripData release];
}

-(void)testRoundTripToIntegerArray
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(NSInteger)];
	NSInteger *samples	= (NSInteger *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i) * 1000.0;
	}
	CPTNumericDataType theDataType = CPTDataType( CPTIntegerDataType, sizeof(NSInteger), NSHostByteOrder() );

	CPTNumericData *intData = [[CPTNumericData alloc] initWithData:data
														  dataType:theDataType
															 shape:nil];

	NSArray *integerArray = [intData sampleArray];
	STAssertEquals(integerArray.count, numberOfSamples, @"integerArray size");

	CPTNumericData *roundTripData = [[CPTNumericData alloc] initWithArray:integerArray
																 dataType:theDataType
																	shape:nil];
	STAssertEquals(roundTripData.numberOfSamples, numberOfSamples, @"roundTripData size");

	const NSInteger *roundTrip = (const NSInteger *)roundTripData.bytes;
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEquals(samples[i], roundTrip[i], @"Round trip");
	}

	[intData release];
	[roundTripData release];
}

-(void)testRoundTripToDecimalArray
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(NSDecimal)];
	NSDecimal *samples	= (NSDecimal *)[data mutableBytes];

	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = CPTDecimalFromDouble( sin(i) );
	}
	CPTNumericDataType theDataType = CPTDataType( CPTDecimalDataType, sizeof(NSDecimal), NSHostByteOrder() );

	CPTNumericData *decimalData = [[CPTNumericData alloc] initWithData:data
															  dataType:theDataType
																 shape:nil];

	NSArray *decimalArray = [decimalData sampleArray];
	STAssertEquals(decimalArray.count, numberOfSamples, @"doubleArray size");

	CPTNumericData *roundTripData = [[CPTNumericData alloc] initWithArray:decimalArray
																 dataType:theDataType
																	shape:nil];
	STAssertEquals(roundTripData.numberOfSamples, numberOfSamples, @"roundTripData size");

	const NSDecimal *roundTrip = (const NSDecimal *)roundTripData.bytes;
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertTrue(CPTDecimalEquals(samples[i], roundTrip[i]), @"Round trip");
	}

	[decimalData release];
	[roundTripData release];
}

@end
