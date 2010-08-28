#import "CPNumericDataTypeConversionPerformanceTests.h"
#import "CPNumericData.h"
#import "CPNumericData+TypeConversion.h"
#import <mach/mach_time.h>

static const size_t numberOfSamples = 10000000;
static const NSUInteger numberOfReps = 5;

@implementation CPNumericDataTypeConversionPerformanceTests

-(void)testFloatToDoubleConversion
{
	NSMutableData *data = [[NSMutableData alloc] initWithLength:numberOfSamples * sizeof(float)];
	float *samples = (float *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sinf(i);
	}
	
	CPNumericData *floatNumericData = [[CPNumericData alloc] initWithData:data
												   dataType:CPDataType(CPFloatingPointDataType, sizeof(float), CFByteOrderGetCurrent())
													  shape:nil];
	
	[data release];
	
	mach_timebase_info_data_t time_base_info;
	mach_timebase_info(&time_base_info);
	
    NSUInteger iterations = 0;
	uint64_t elapsed = 0;
	
    for ( NSUInteger i = 0; i < numberOfReps; i++ ) {
		uint64_t start = mach_absolute_time();
		
		CPNumericData *doubleNumericData = [floatNumericData dataByConvertingToType:CPFloatingPointDataType sampleBytes:sizeof(double) byteOrder:CFByteOrderGetCurrent()];
		
		uint64_t now = mach_absolute_time();
		
		elapsed += now - start;
		
		[[doubleNumericData retain] release];
		iterations++;
	}
	
	double avgTime = 1.0e-6 * (double)(elapsed * time_base_info.numer / time_base_info.denom) / iterations;
    STFail(@"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
	
	[floatNumericData release];
}

-(void)testDoubleToFloatConversion
{
	NSMutableData *data = [[NSMutableData alloc] initWithLength:numberOfSamples * sizeof(double)];
	double *samples = (double *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i);
	}
	
	CPNumericData *doubleNumericData = [[CPNumericData alloc] initWithData:data
																  dataType:CPDataType(CPFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
																	 shape:nil];
	
	[data release];
	
	mach_timebase_info_data_t time_base_info;
	mach_timebase_info(&time_base_info);
	
    NSUInteger iterations = 0;
	uint64_t elapsed = 0;
	
    for ( NSUInteger i = 0; i < numberOfReps; i++ ) {
		uint64_t start = mach_absolute_time();
		
		CPNumericData *floatNumericData = [doubleNumericData dataByConvertingToType:CPFloatingPointDataType sampleBytes:sizeof(float) byteOrder:CFByteOrderGetCurrent()];
		
		uint64_t now = mach_absolute_time();
		
		elapsed += now - start;
		
		[[floatNumericData retain] release];
		iterations++;
	}
	
	double avgTime = 1.0e-6 * (double)(elapsed * time_base_info.numer / time_base_info.denom) / iterations;
    STFail(@"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
	
	[doubleNumericData release];
}

-(void)testIntegerToDoubleConversion
{
	NSMutableData *data = [[NSMutableData alloc] initWithLength:numberOfSamples * sizeof(NSInteger)];
	NSInteger *samples = (NSInteger *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i) * 1000.0;
	}
	
	CPNumericData *integerNumericData = [[CPNumericData alloc] initWithData:data
																  dataType:CPDataType(CPIntegerDataType, sizeof(NSInteger), CFByteOrderGetCurrent())
																	 shape:nil];
	
	[data release];
	
	mach_timebase_info_data_t time_base_info;
	mach_timebase_info(&time_base_info);
	
    NSUInteger iterations = 0;
	uint64_t elapsed = 0;
	
    for ( NSUInteger i = 0; i < numberOfReps; i++ ) {
		uint64_t start = mach_absolute_time();
		
		CPNumericData *doubleNumericData = [integerNumericData dataByConvertingToType:CPFloatingPointDataType sampleBytes:sizeof(double) byteOrder:CFByteOrderGetCurrent()];
		
		uint64_t now = mach_absolute_time();
		
		elapsed += now - start;
		
		[[doubleNumericData retain] release];
		iterations++;
	}
	
	double avgTime = 1.0e-6 * (double)(elapsed * time_base_info.numer / time_base_info.denom) / iterations;
    STFail(@"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
	
	[integerNumericData release];
}

-(void)testDoubleToIntegerConversion
{
	NSMutableData *data = [[NSMutableData alloc] initWithLength:numberOfSamples * sizeof(double)];
	double *samples = (double *)[data mutableBytes];
	for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
		samples[i] = sin(i) * 1000.0;
	}
	
	CPNumericData *doubleNumericData = [[CPNumericData alloc] initWithData:data
																  dataType:CPDataType(CPFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
																	 shape:nil];
	
	[data release];
	
	mach_timebase_info_data_t time_base_info;
	mach_timebase_info(&time_base_info);
	
    NSUInteger iterations = 0;
	uint64_t elapsed = 0;
	
    for ( NSUInteger i = 0; i < numberOfReps; i++ ) {
		uint64_t start = mach_absolute_time();
		
		CPNumericData *integerNumericData = [doubleNumericData dataByConvertingToType:CPIntegerDataType sampleBytes:sizeof(NSInteger) byteOrder:CFByteOrderGetCurrent()];
		
		uint64_t now = mach_absolute_time();
		
		elapsed += now - start;
		
		[[integerNumericData retain] release];
		iterations++;
	}
	
	double avgTime = 1.0e-6 * (double)(elapsed * time_base_info.numer / time_base_info.denom) / iterations;
    STFail(@"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
	
	[doubleNumericData release];
}

@end
