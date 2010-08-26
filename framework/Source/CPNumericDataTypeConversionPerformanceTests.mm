#import "CPNumericDataTypeConversionPerformanceTests.h"
#import "CPNumericData.h"
#import "CPNumericData+TypeConversion.h"
#import <mach/mach_time.h>

static const size_t numberOfSamples = 10000000;
static const NSUInteger numberOfReps = 5;

@implementation CPNumericDataTypeConversionPerformanceTests

-(void)testFloatToDoubleConversion
{
    float *floatArr = (float *)malloc(numberOfSamples * sizeof(float));
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        floatArr[i] = sinf(i);
    }
    
    NSData *floatData = [NSData dataWithBytesNoCopy:floatArr
                                             length:numberOfSamples * sizeof(float)
                                       freeWhenDone:NO];
	CPNumericData *floatNumericData = [CPNumericData numericDataWithData:floatData
																dataType:CPDataType(CPFloatingPointDataType, sizeof(float), CFByteOrderGetCurrent())
																   shape:nil];
	
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
    STAssertTrue(false, @"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
	
	free(floatArr);
}

-(void)testDoubleToFloatConversion
{
    double *doubleArr = (double *)malloc(numberOfSamples * sizeof(double));
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        doubleArr[i] = sin(i);
    }
    
    NSData *doubleData = [NSData dataWithBytesNoCopy:doubleArr
											  length:numberOfSamples * sizeof(double)
										freeWhenDone:NO];
	CPNumericData *doubleNumericData = [CPNumericData numericDataWithData:doubleData
																 dataType:CPDataType(CPFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
																	shape:nil];
	
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
    STAssertTrue(false, @"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
	
	free(doubleArr);
}

-(void)testIntegerToDoubleConversion
{
    NSInteger *integerArr = (NSInteger *)malloc(numberOfSamples * sizeof(NSInteger));
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        integerArr[i] = sin(i) * 1000.0;
    }
    
    NSData *integerData = [NSData dataWithBytesNoCopy:integerArr
                                             length:numberOfSamples * sizeof(NSInteger)
                                       freeWhenDone:NO];
	CPNumericData *integerNumericData = [CPNumericData numericDataWithData:integerData
																dataType:CPDataType(CPIntegerDataType, sizeof(NSInteger), CFByteOrderGetCurrent())
																   shape:nil];
	
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
    STAssertTrue(false, @"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
	
	free(integerArr);
}

-(void)testDoubleToIntegerConversion
{
    double *doubleArr = (double *)malloc(numberOfSamples * sizeof(double));
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        doubleArr[i] = sin(i) * 1000.0;
    }
    
    NSData *doubleData = [NSData dataWithBytesNoCopy:doubleArr
											  length:numberOfSamples * sizeof(double)
										freeWhenDone:NO];
	CPNumericData *doubleNumericData = [CPNumericData numericDataWithData:doubleData
																 dataType:CPDataType(CPFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
																	shape:nil];
	
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
    STAssertTrue(false, @"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
	
	free(doubleArr);
}

@end
