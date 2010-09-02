#import "CPMutableNumericDataTypeConversionTests.h"
#import "CPMutableNumericData.h"
#import "CPMutableNumericData+TypeConversion.h"
#import "CPUtilities.h"

static const NSUInteger numberOfSamples = 5;
static const double precision = 1.0e-6;

@implementation CPMutableNumericDataTypeConversionTests

-(void)testFloatToDoubleInPlaceConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(float)];
	float *samples = (float *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sinf(i);
	}
	
	CPMutableNumericData *numericData = [[CPMutableNumericData alloc] initWithData:data
																		  dataType:CPDataType(CPFloatingPointDataType, sizeof(float), NSHostByteOrder())
																			 shape:nil];
	
	numericData.sampleBytes = sizeof(double);
	
	const double *doubleSamples = (const double *)[numericData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy((double)samples[i], doubleSamples[i], precision, @"(float)%g != (double)%g", samples[i], doubleSamples[i]);
	}
	[numericData release];
}

-(void)testDoubleToFloatInPlaceConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(double)];
	double *samples = (double *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}
	
	CPMutableNumericData *numericData = [[CPMutableNumericData alloc] initWithData:data
																		  dataType:CPDataType(CPFloatingPointDataType, sizeof(double), NSHostByteOrder())
																			 shape:nil];
	
	numericData.sampleBytes = sizeof(float);
	
	const float *floatSamples = (const float *)[numericData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy((double)floatSamples[i], samples[i], precision, @"(float)%g != (double)%g", floatSamples[i], samples[i]);
	}
	[numericData release];
}

-(void)testFloatToIntegerInPlaceConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(float)];
	float *samples = (float *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sinf(i) * 1000.0f;
	}
	
	CPMutableNumericData *numericData = [[CPMutableNumericData alloc] initWithData:data
																		  dataType:CPDataType(CPFloatingPointDataType, sizeof(float), NSHostByteOrder())
																			 shape:nil];
	
	numericData.dataType = CPDataType(CPIntegerDataType, sizeof(NSInteger), NSHostByteOrder());
	
	const NSInteger *intSamples = (const NSInteger *)[numericData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy((NSInteger)samples[i], intSamples[i], precision, @"(float)%g != (NSInteger)%ld", samples[i], (long)intSamples[i]);
	}
	[numericData release];
}

-(void)testIntegerToFloatInPlaceConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(NSInteger)];
	NSInteger *samples = (NSInteger *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i) * 1000.0;
	}
	
	CPMutableNumericData *numericData = [[CPMutableNumericData alloc] initWithData:data
																		  dataType:CPDataType(CPIntegerDataType, sizeof(NSInteger), NSHostByteOrder())
																			 shape:nil];
	
	numericData.dataType = CPDataType(CPFloatingPointDataType, sizeof(float), NSHostByteOrder());
	
	const float *floatSamples = (const float *)[numericData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEqualsWithAccuracy(floatSamples[i], (float)samples[i], precision, @"(float)%g != (NSInteger)%ld", floatSamples[i], (long)samples[i]);
	}
	[numericData release];
}

-(void)testDecimalToDoubleInPlaceConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(NSDecimal)];
	NSDecimal *samples = (NSDecimal *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = CPDecimalFromDouble(sin(i));
	}
	
	CPMutableNumericData *numericData = [[CPMutableNumericData alloc] initWithData:data
																		  dataType:CPDataType(CPDecimalDataType, sizeof(NSDecimal), NSHostByteOrder())
																			 shape:nil];
	
	numericData.dataType = CPDataType(CPFloatingPointDataType, sizeof(double), NSHostByteOrder());
	
	const double *doubleSamples = (const double *)[numericData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertEquals(CPDecimalDoubleValue(samples[i]), doubleSamples[i], @"(NSDecimal)%@ != (double)%g", CPDecimalStringValue(samples[i]), doubleSamples[i]);
	}
	[numericData release];
}

-(void)testDoubleToDecimalInPlaceConversion
{
	NSMutableData *data = [NSMutableData dataWithLength:numberOfSamples * sizeof(double)];
	double *samples = (double *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}
	
	CPMutableNumericData *numericData = [[CPMutableNumericData alloc] initWithData:data
																		  dataType:CPDataType(CPFloatingPointDataType, sizeof(double), NSHostByteOrder())
																			 shape:nil];

	numericData.dataType = CPDataType(CPDecimalDataType, sizeof(NSDecimal), NSHostByteOrder());
	
	const NSDecimal *decimalSamples = (const NSDecimal *)[numericData.data bytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		STAssertTrue(CPDecimalEquals(decimalSamples[i], CPDecimalFromDouble(samples[i])), @"(NSDecimal)%@ != (double)%g", CPDecimalStringValue(decimalSamples[i]), samples[i]);
	}
	[numericData release];
}

-(void)testTypeConversionSwapsByteOrderIntegerInPlace
{
	CFByteOrder hostByteOrder = CFByteOrderGetCurrent();
	CFByteOrder swappedByteOrder = (hostByteOrder == CFByteOrderBigEndian) ? CFByteOrderLittleEndian : CFByteOrderBigEndian;
	
    uint32_t start = 1000;
    NSData *startData = [NSData dataWithBytesNoCopy:&start
                                             length:sizeof(uint32_t)
                                       freeWhenDone:NO];
	
	CPMutableNumericData *numericData = [[CPMutableNumericData alloc] initWithData:startData
																		  dataType:CPDataType(CPUnsignedIntegerDataType, sizeof(uint32_t), hostByteOrder)
																			 shape:nil];
	
	numericData.byteOrder = swappedByteOrder;
	
    uint32_t end = *(const uint32_t *)numericData.bytes;
    STAssertEquals(CFSwapInt32(start), end, @"Bytes swapped");
    
	numericData.byteOrder = hostByteOrder;
	
    uint32_t startRoundTrip = *(const uint32_t *)numericData.bytes;
    STAssertEquals(start, startRoundTrip, @"Round trip");
	[numericData release];
}

-(void)testTypeConversionSwapsByteOrderDoubleInPlace
{
	CFByteOrder hostByteOrder = CFByteOrderGetCurrent();
	CFByteOrder swappedByteOrder = (hostByteOrder == CFByteOrderBigEndian) ? CFByteOrderLittleEndian : CFByteOrderBigEndian;
	
    double start = 1000.0;
    NSData *startData = [NSData dataWithBytesNoCopy:&start
                                             length:sizeof(double)
                                       freeWhenDone:NO];
	
	CPMutableNumericData *numericData = [[CPMutableNumericData alloc] initWithData:startData
																		  dataType:CPDataType(CPFloatingPointDataType, sizeof(double), hostByteOrder)
																			 shape:nil];
	
	numericData.byteOrder = swappedByteOrder;
	
    uint64_t end = *(const uint64_t *)numericData.bytes;
    union swap {
		double v;
		CFSwappedFloat64 sv;
    } result;
    result.v = start;
    STAssertEquals(CFSwapInt64(result.sv.v), end, @"Bytes swapped");
    
	numericData.byteOrder = hostByteOrder;
	
    double startRoundTrip = *(const double *)numericData.bytes;
    STAssertEquals(start, startRoundTrip, @"Round trip");
	[numericData release];
}

@end
