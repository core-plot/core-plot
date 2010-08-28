#import "CPNumericDataTypeConversionTests.h"
#import "CPNumericData.h"
#import "CPNumericData+TypeConversion.h"

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

/*
 -(void)testRoundTripToSTLVector
 {
 double doubleArr[numberOfSamples];
 NSData *inData = [NSData dataWithBytesNoCopy:doubleArr
 length:numberOfSamples*sizeof(double)
 freeWhenDone:NO];
 
 auto_ptr<vector<double> > vptr(coreplot::numeric_data_to_vector<double>(inData));
 
 NSData *roundTripData = coreplot::vector_to_numeric_data(vptr);
 
 STAssertTrue([inData isEqualToData:roundTripData], @"double round trip");
 
 NSInteger intArr[numberOfSamples];
 inData = [NSData dataWithBytesNoCopy:intArr
 length:numberOfSamples*sizeof(NSInteger)
 freeWhenDone:NO];
 
 auto_ptr<vector<NSInteger> > ivptr(coreplot::numeric_data_to_vector<NSInteger>(inData));
 
 roundTripData = coreplot::vector_to_numeric_data(ivptr);
 
 STAssertTrue([inData isEqualToData:roundTripData], @"NSInteger round trip");
 }

 -(void)testInplaceNumericDataDoubleByteSwap
 {
 using namespace coreplot;
 double doubleArr[numberOfSamples];
 
 for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
 doubleArr[i] = i*3.141+1;
 }
 
 NSMutableData *inData = [NSMutableData dataWithBytesNoCopy:doubleArr
 length:numberOfSamples*sizeof(double)
 freeWhenDone:NO];
 NSData *originalData = [NSData dataWithBytes:doubleArr
 length:numberOfSamples*sizeof(double)];
 
 swap_numeric_data_byte_order<double>(inData); //byte-swap
 STAssertFalse([originalData isEqualToData:inData], @"swap changes data");
 
 double expectedArr[numberOfSamples];
 for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
 switch ( NSHostByteOrder() ) {
 case NS_LittleEndian:
 expectedArr[i] = NSConvertSwappedDoubleToHost(NSSwapHostDoubleToBig(doubleArr[i]));
 STAssertFalse(expectedArr[i] == doubleArr[i], 
 @"swap changes data %g, %g", expectedArr[i],
 doubleArr[i]);
 break;
 case NS_BigEndian:
 expectedArr[i] = NSConvertSwappedDoubleToHost(NSSwapHostDoubleToLittle(doubleArr[i]));
 STAssertFalse(expectedArr[i] == doubleArr[i], 
 @"swap changes data %g, %g", expectedArr[i], 
 doubleArr[i]);
 break;
 default:
 STFail(@"Unknown host byte order");
 break;
 }
 }
 
 STAssertEqualObjects(inData, [NSData dataWithBytesNoCopy:expectedArr
 length:[inData length]
 freeWhenDone:NO],
 @"swap swaps bytes");
 
 swap_numeric_data_byte_order<double>(inData); //back to original
 STAssertEqualObjects(originalData, inData, @"round trip");
 }
 
 -(void)testInplaceNumericDataFloatByteSwap
 {
 using namespace coreplot;
 float floatArr[numberOfSamples];
 
 for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
 floatArr[i] = i*3.141+1;
 }
 
 NSMutableData *inData = [NSMutableData dataWithBytesNoCopy:floatArr
 length:numberOfSamples*sizeof(float)
 freeWhenDone:NO];
 NSData *originalData = [NSData dataWithBytes:floatArr
 length:numberOfSamples*sizeof(float)];
 
 swap_numeric_data_byte_order<float>(inData); //byte-swap
 STAssertFalse([originalData isEqualToData:inData], @"swap changes data");
 
 float expectedArr[numberOfSamples];
 for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
 switch ( NSHostByteOrder() ) {
 case NS_LittleEndian:
 expectedArr[i] = NSConvertSwappedFloatToHost(NSSwapHostFloatToBig(floatArr[i]));
 STAssertFalse(expectedArr[i] == floatArr[i], 
 @"swap changes data %g, %g", expectedArr[i],
 floatArr[i]);
 break;
 case NS_BigEndian:
 expectedArr[i] = NSConvertSwappedFloatToHost(NSSwapHostFloatToLittle(floatArr[i]));
 STAssertFalse(expectedArr[i] == floatArr[i], 
 @"swap changes data %g, %g", expectedArr[i], 
 floatArr[i]);
 break;
 case NS_UnknownByteOrder:
 STFail(@"Unknow host byte order");
 break;
 }
 }
 
 STAssertEqualObjects(inData, [NSData dataWithBytesNoCopy:expectedArr
 length:[inData length]
 freeWhenDone:NO],
 @"swap swaps bytes");
 
 swap_numeric_data_byte_order<float>(inData); //back to original
 STAssertEqualObjects(originalData, inData, @"round trip");
 }
 */
@end
