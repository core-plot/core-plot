#import "CPTNumericDataTypeConversionPerformanceTests.h"

#import "CPTNumericData+TypeConversion.h"
#import <mach/mach_time.h>

static const size_t numberOfSamples  = 10000000;
static const NSUInteger numberOfReps = 5;

@implementation CPTNumericDataTypeConversionPerformanceTests

-(void)testFloatToDoubleConversion
{
    NSMutableData *data = [[NSMutableData alloc] initWithLength:numberOfSamples * sizeof(float)];
    float *samples      = (float *)[data mutableBytes];

    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        samples[i] = sinf(i);
    }

    CPTNumericData *floatNumericData = [[CPTNumericData alloc] initWithData:data
                                                                   dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), CFByteOrderGetCurrent() )
                                                                      shape:nil];

    mach_timebase_info_data_t time_base_info;
    mach_timebase_info(&time_base_info);

    NSUInteger iterations = 0;
    uint64_t elapsed      = 0;

    CPTNumericData *doubleNumericData = nil;

    for ( NSUInteger i = 0; i < numberOfReps; i++ ) {
        uint64_t start = mach_absolute_time();

        doubleNumericData = [floatNumericData dataByConvertingToType:CPTFloatingPointDataType sampleBytes:sizeof(double) byteOrder:CFByteOrderGetCurrent()];

        uint64_t now = mach_absolute_time();

        elapsed += now - start;

        iterations++;
    }

    double avgTime = 1.0e-6 * (double)(elapsed * time_base_info.numer / time_base_info.denom) / iterations;
    XCTAssertLessThanOrEqual(avgTime, 100.0, @"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
}

-(void)testDoubleToFloatConversion
{
    NSMutableData *data = [[NSMutableData alloc] initWithLength:numberOfSamples * sizeof(double)];
    double *samples     = (double *)[data mutableBytes];

    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        samples[i] = sin(i);
    }

    CPTNumericData *doubleNumericData = [[CPTNumericData alloc] initWithData:data
                                                                    dataType:CPTDataType( CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() )
                                                                       shape:nil];

    mach_timebase_info_data_t time_base_info;
    mach_timebase_info(&time_base_info);

    NSUInteger iterations = 0;
    uint64_t elapsed      = 0;

    CPTNumericData *floatNumericData = nil;

    for ( NSUInteger i = 0; i < numberOfReps; i++ ) {
        uint64_t start = mach_absolute_time();

        floatNumericData = [doubleNumericData dataByConvertingToType:CPTFloatingPointDataType sampleBytes:sizeof(float) byteOrder:CFByteOrderGetCurrent()];

        uint64_t now = mach_absolute_time();

        elapsed += now - start;

        iterations++;
    }

    double avgTime = 1.0e-6 * (double)(elapsed * time_base_info.numer / time_base_info.denom) / iterations;
    XCTAssertLessThanOrEqual(avgTime, 50.0, @"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
}

-(void)testIntegerToDoubleConversion
{
    NSMutableData *data = [[NSMutableData alloc] initWithLength:numberOfSamples * sizeof(NSInteger)];
    NSInteger *samples  = (NSInteger *)[data mutableBytes];

    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        samples[i] = (NSInteger)(sin(i) * 1000.0);
    }

    CPTNumericData *integerNumericData = [[CPTNumericData alloc] initWithData:data
                                                                     dataType:CPTDataType( CPTIntegerDataType, sizeof(NSInteger), CFByteOrderGetCurrent() )
                                                                        shape:nil];

    mach_timebase_info_data_t time_base_info;
    mach_timebase_info(&time_base_info);

    NSUInteger iterations = 0;
    uint64_t elapsed      = 0;

    CPTNumericData *doubleNumericData = nil;

    for ( NSUInteger i = 0; i < numberOfReps; i++ ) {
        uint64_t start = mach_absolute_time();

        doubleNumericData = [integerNumericData dataByConvertingToType:CPTFloatingPointDataType sampleBytes:sizeof(double) byteOrder:CFByteOrderGetCurrent()];

        uint64_t now = mach_absolute_time();

        elapsed += now - start;
        iterations++;
    }

    double avgTime = 1.0e-6 * (double)(elapsed * time_base_info.numer / time_base_info.denom) / iterations;
    XCTAssertLessThanOrEqual(avgTime, 75.0, @"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
}

-(void)testDoubleToIntegerConversion
{
    NSMutableData *data = [[NSMutableData alloc] initWithLength:numberOfSamples * sizeof(double)];
    double *samples     = (double *)[data mutableBytes];

    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        samples[i] = sin(i) * 1000.0;
    }

    CPTNumericData *doubleNumericData = [[CPTNumericData alloc] initWithData:data
                                                                    dataType:CPTDataType( CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() )
                                                                       shape:nil];

    mach_timebase_info_data_t time_base_info;
    mach_timebase_info(&time_base_info);

    NSUInteger iterations = 0;
    uint64_t elapsed      = 0;

    CPTNumericData *integerNumericData = nil;

    for ( NSUInteger i = 0; i < numberOfReps; i++ ) {
        uint64_t start = mach_absolute_time();

        integerNumericData = [doubleNumericData dataByConvertingToType:CPTIntegerDataType sampleBytes:sizeof(NSInteger) byteOrder:CFByteOrderGetCurrent()];

        uint64_t now = mach_absolute_time();

        elapsed += now - start;
        iterations++;
    }

    double avgTime = 1.0e-6 * (double)(elapsed * time_base_info.numer / time_base_info.denom) / iterations;
    XCTAssertLessThanOrEqual(avgTime, 75.0, @"Avg. time = %g ms for %lu points.", avgTime, (unsigned long)numberOfSamples);
}

@end
