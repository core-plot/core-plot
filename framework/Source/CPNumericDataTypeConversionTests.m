#import "CPNumericDataTypeConversionTests.h"
#import "CPNumericData.h"
#import "CPNumericData+TypeConversion.h"
#import "CPUtilities.h"

static const NSUInteger numberOfSamples = 5;
static const double precision = 1.0e-6;

@implementation CPNumericDataTypeConversionTests

-(void)testFloatToDoubleConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(float)];
	float *samples = (float *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sinf(i);
	}
	
	CPNumericData *fd = [[CPNumericData alloc] initWithData:data
												   dataType:CPDataType(CPFloatingPointDataType, sizeof(float), NSHostByteOrder())
													  shape:nil];
	
	CPNumericData *dd = [fd dataByConvertingToType:CPFloatingPointDataType
									   sampleBytes:sizeof(double)
										 byteOrder:NSHostByteOrder()];
	
	[fd release];
	
	const double *doubleSamples = (const double *)[dd.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy((double)samples[i], doubleSamples[i], precision, @"(float)%g != (double)%g", samples[i], doubleSamples[i]);
	}
}

-(void)testDoubleToFloatConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(double)];
	double *samples = (double *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}
	
	CPNumericData *dd = [[CPNumericData alloc] initWithData:data
												   dataType:CPDataType(CPFloatingPointDataType, sizeof(double), NSHostByteOrder())
													  shape:nil];
	
	CPNumericData *fd = [dd dataByConvertingToType:CPFloatingPointDataType
									   sampleBytes:sizeof(float)
										 byteOrder:NSHostByteOrder()];
	
	[dd release];
	
	const float *floatSamples = (const float *)[fd.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy((double)floatSamples[i], samples[i], precision, @"(float)%g != (double)%g", floatSamples[i], samples[i]);
	}
}

-(void)testFloatToIntegerConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(float)];
	float *samples = (float *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sinf(i) * 1000.0f;
	}
	
	CPNumericData *fd = [[CPNumericData alloc] initWithData:data
												   dataType:CPDataType(CPFloatingPointDataType, sizeof(float), NSHostByteOrder())
													  shape:nil];
	
	CPNumericData *intData = [fd dataByConvertingToType:CPIntegerDataType
											sampleBytes:sizeof(NSInteger)
											  byteOrder:NSHostByteOrder()];
	
	[fd release];
	
	const NSInteger *intSamples = (const NSInteger *)[intData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy((NSInteger)samples[i], intSamples[i], precision, @"(float)%g != (NSInteger)%ld", samples[i], (long)intSamples[i]);
	}
}

-(void)testIntegerToFloatConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(NSInteger)];
	NSInteger *samples = (NSInteger *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i) * 1000.0;
	}
	
	CPNumericData *intData = [[CPNumericData alloc] initWithData:data
														dataType:CPDataType(CPIntegerDataType, sizeof(NSInteger), NSHostByteOrder())
														   shape:nil];
	
	CPNumericData *fd = [intData dataByConvertingToType:CPFloatingPointDataType
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
	CFByteOrder hostByteOrder = CFByteOrderGetCurrent();
	CFByteOrder swappedByteOrder = (hostByteOrder == CFByteOrderBigEndian) ? CFByteOrderLittleEndian : CFByteOrderBigEndian;
	
    uint32_t start = 1000;
    NSData *startData = [NSData dataWithBytesNoCopy:&start
                                             length:sizeof(uint32_t)
                                       freeWhenDone:NO];
	
	CPNumericData *intData = [[CPNumericData alloc] initWithData:startData
														dataType:CPDataType(CPUnsignedIntegerDataType, sizeof(uint32_t), hostByteOrder)
														   shape:nil];
	
	CPNumericData *swappedData = [intData dataByConvertingToType:CPUnsignedIntegerDataType
													 sampleBytes:sizeof(uint32_t)
													   byteOrder:swappedByteOrder];
	
	[intData release];
	
    uint32_t end = *(const uint32_t *)swappedData.bytes;
    STAssertEquals(CFSwapInt32(start), end, @"Bytes swapped");
    
	CPNumericData *roundTripData = [swappedData dataByConvertingToType:CPUnsignedIntegerDataType
														   sampleBytes:sizeof(uint32_t)
															 byteOrder:hostByteOrder];
	
    uint32_t startRoundTrip = *(const uint32_t *)roundTripData.bytes;
    STAssertEquals(start, startRoundTrip, @"Round trip");
}

-(void)testDecimalToDoubleConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(NSDecimal)];
	NSDecimal *samples = (NSDecimal *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = CPDecimalFromDouble(sin(i));
	}
	
	CPNumericData *decimalData = [[CPNumericData alloc] initWithData:data
												   dataType:CPDataType(CPDecimalDataType, sizeof(NSDecimal), NSHostByteOrder())
													  shape:nil];
	
	CPNumericData *doubleData = [decimalData dataByConvertingToType:CPFloatingPointDataType
									   sampleBytes:sizeof(double)
										 byteOrder:NSHostByteOrder()];
	
	[decimalData release];
	
	const double *doubleSamples = (const double *)[doubleData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEquals(CPDecimalDoubleValue(samples[i]), doubleSamples[i], @"(NSDecimal)%@ != (double)%g", CPDecimalStringValue(samples[i]), doubleSamples[i]);
	}
}

-(void)testDoubleToDecimalConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(double)];
	double *samples = (double *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}
	
	CPNumericData *doubleData = [[CPNumericData alloc] initWithData:data
												   dataType:CPDataType(CPFloatingPointDataType, sizeof(double), NSHostByteOrder())
													  shape:nil];
	
	CPNumericData *decimalData = [doubleData dataByConvertingToType:CPDecimalDataType
									   sampleBytes:sizeof(NSDecimal)
										 byteOrder:NSHostByteOrder()];
	
	[doubleData release];
	
	const NSDecimal *decimalSamples = (const NSDecimal *)[decimalData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertTrue(CPDecimalEquals(decimalSamples[i], CPDecimalFromDouble(samples[i])), @"(NSDecimal)%@ != (double)%g", CPDecimalStringValue(decimalSamples[i]), samples[i]);
	}
}

-(void)testTypeConversionSwapsByteOrderDouble
{
	CFByteOrder hostByteOrder = CFByteOrderGetCurrent();
	CFByteOrder swappedByteOrder = (hostByteOrder == CFByteOrderBigEndian) ? CFByteOrderLittleEndian : CFByteOrderBigEndian;
	
    double start = 1000.0;
    NSData *startData = [NSData dataWithBytesNoCopy:&start
                                             length:sizeof(double)
                                       freeWhenDone:NO];
	
	CPNumericData *doubleData = [[CPNumericData alloc] initWithData:startData
														   dataType:CPDataType(CPFloatingPointDataType, sizeof(double), hostByteOrder)
															  shape:nil];
	
	CPNumericData *swappedData = [doubleData dataByConvertingToType:CPFloatingPointDataType
														sampleBytes:sizeof(double)
														  byteOrder:swappedByteOrder];
	
	[doubleData release];
	
    uint64_t end = *(const uint64_t *)swappedData.bytes;
    union swap {
		double v;
		CFSwappedFloat64 sv;
    } result;
    result.v = start;
    STAssertEquals(CFSwapInt64(result.sv.v), end, @"Bytes swapped");
    
	CPNumericData *roundTripData = [swappedData dataByConvertingToType:CPFloatingPointDataType
														   sampleBytes:sizeof(double)
															 byteOrder:hostByteOrder];
	
    double startRoundTrip = *(const double *)roundTripData.bytes;
    STAssertEquals(start, startRoundTrip, @"Round trip");
}

-(void)testRoundTripToDoubleArray
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(double)];
	double *samples = (double *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}
	CPNumericDataType theDataType = CPDataType(CPFloatingPointDataType, sizeof(double), NSHostByteOrder());
	
	CPNumericData *doubleData = [[CPNumericData alloc] initWithData:data
														   dataType:theDataType
															  shape:nil];
	
	NSArray *doubleArray = [doubleData sampleArray];
	STAssertEquals(doubleArray.count, numberOfSamples, @"doubleArray size");
	
	CPNumericData *roundTripData = [[CPNumericData alloc] initWithArray:doubleArray
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
	NSInteger *samples = (NSInteger *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i) * 1000.0;
	}
	CPNumericDataType theDataType = CPDataType(CPIntegerDataType, sizeof(NSInteger), NSHostByteOrder());
	
	CPNumericData *intData = [[CPNumericData alloc] initWithData:data
														dataType:theDataType
														   shape:nil];
	
	NSArray *integerArray = [intData sampleArray];
	STAssertEquals(integerArray.count, numberOfSamples, @"integerArray size");
	
	CPNumericData *roundTripData = [[CPNumericData alloc] initWithArray:integerArray
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
	NSDecimal *samples = (NSDecimal *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = CPDecimalFromDouble(sin(i));
	}
	CPNumericDataType theDataType = CPDataType(CPDecimalDataType, sizeof(NSDecimal), NSHostByteOrder());
	
	CPNumericData *decimalData = [[CPNumericData alloc] initWithData:data
														   dataType:theDataType
															  shape:nil];
	
	NSArray *decimalArray = [decimalData sampleArray];
	STAssertEquals(decimalArray.count, numberOfSamples, @"doubleArray size");
	
	CPNumericData *roundTripData = [[CPNumericData alloc] initWithArray:decimalArray
															   dataType:theDataType 
																  shape:nil];
	STAssertEquals(roundTripData.numberOfSamples, numberOfSamples, @"roundTripData size");
	
	const NSDecimal *roundTrip = (const NSDecimal *)roundTripData.bytes;
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertTrue(CPDecimalEquals(samples[i], roundTrip[i]), @"Round trip");
	}
	
	[decimalData release];
	[roundTripData release];
}

@end
