#import "TestCPNumericDataConversion.h"
#import "NumericDataTypeConversions.h"

static const NSUInteger numberOfSamples = 5;

@implementation TestNSDataTypeConversions

-(void)testFloatToDoubleConversion
{
    float floatArr[numberOfSamples];
    double doubleArr[numberOfSamples];
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        floatArr[i] = sinf(i);
    }
    
    NSData *floatData = [NSData dataWithBytesNoCopy:floatArr
                                             length:numberOfSamples*sizeof(float)
                                       freeWhenDone:NO];
    
    NSData *doubleData = coreplot::convert_numeric_data_type<float,double>(floatData);
    
    [doubleData getBytes:doubleArr length:numberOfSamples*sizeof(double)];
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        STAssertTrue(floatArr[i] == doubleArr[i], @"");
    }
}

-(void)testDoubleToFloatConversion
{
    float floatArr[numberOfSamples];
    double doubleArr[numberOfSamples];
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        doubleArr[i] = sin(i);
    }
    
    NSData *doubleData = [NSData dataWithBytesNoCopy:doubleArr
											  length:numberOfSamples*sizeof(double)
										freeWhenDone:NO];
    
    NSData *floatData = coreplot::convert_numeric_data_type<double,float>(doubleData);
    
    [floatData getBytes:floatArr length:numberOfSamples*sizeof(float)];
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        STAssertTrue(floatArr[i] == (float)doubleArr[i], @"");
    }
}

-(void)testFloatToIntegerConversion
{
    float floatArr[numberOfSamples];
    NSInteger intArr[numberOfSamples];
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        floatArr[i] = i;
    }
    
    NSData *floatData = [NSData dataWithBytesNoCopy:floatArr
                                             length:numberOfSamples*sizeof(float)
                                       freeWhenDone:NO];
    
    NSData *intData = coreplot::convert_numeric_data_type<float,NSInteger>(floatData);
    
    [intData getBytes:intArr length:numberOfSamples*sizeof(NSInteger)];
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        STAssertTrue(floatArr[i] == intArr[i],@"");
    }
}

-(void)testIntegerToFloatConversion
{
    float floatArr[numberOfSamples];
    NSInteger intArr[numberOfSamples];
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        intArr[i] = i;
    }
    
    NSData *intData = [NSData dataWithBytesNoCopy:intArr
										   length:numberOfSamples*sizeof(NSInteger)
									 freeWhenDone:NO];
    
    NSData *floatData = coreplot::convert_numeric_data_type<NSInteger,float>(intData);
    
    [floatData getBytes:floatArr length:numberOfSamples*sizeof(float)];
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        STAssertTrue(floatArr[i] == intArr[i],@"");
    }
}

-(void)testTypeConversionSwapsByteOrder
{
    using namespace coreplot;
    NSUInteger start = 1000;
    NSData *startData = [NSData dataWithBytesNoCopy:&start
                                             length:sizeof(NSUInteger)
                                       freeWhenDone:NO];
    NSData *endData = swap_numeric_data_byte_order<NSUInteger>(startData);
    
    NSUInteger end = *(NSUInteger *)[endData bytes];
    STAssertEquals(start, (NSUInteger)NSSwapLong(end), @"bytes swapped");
    
    STAssertEqualObjects(startData, swap_numeric_data_byte_order<NSUInteger>(endData), @"Round trip");
    
    float startFloat = (float)1000.;
    startData = [NSData dataWithBytesNoCopy:&startFloat
									 length:sizeof(NSUInteger)
							   freeWhenDone:NO];
    endData = coreplot::swap_numeric_data_byte_order<float>(startData);
    
    float endFloat = *(float *)[endData bytes];
    STAssertEquals(startFloat, NSConvertSwappedFloatToHost(NSHostByteOrder() == NS_LittleEndian ? NSSwapHostFloatToBig(endFloat)
                                                           : NSSwapHostFloatToLittle(endFloat)), @"bytes swapped");
    
    STAssertEqualObjects(startData,  swap_numeric_data_byte_order<float>(endData), @"Round trip");
}

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

-(void)testTypeConversionConvertsTypes
{
    NSInteger intArr[numberOfSamples];
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        intArr[i] = i;
    }
    
    NSData *inData = [NSData dataWithBytesNoCopy:intArr
                                          length:numberOfSamples*sizeof(NSInteger)
                                    freeWhenDone:NO];
    
    using namespace coreplot;
    NSData *outData = vector_to_numeric_data(convert_data_type<NSInteger,float>(numeric_data_to_vector<NSInteger>(inData)));
    
    STAssertTrue([outData length] == numberOfSamples*sizeof(float), @"data size");
    float *floatArr = (float *)[outData bytes];
    
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        STAssertTrue(intArr[i] == floatArr[i], @"Numerical equality");
    }
    
    STAssertEqualObjects(inData, vector_to_numeric_data(convert_data_type<float,NSInteger>(numeric_data_to_vector<float>(outData))),
                         @"round trip data equality");
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
            case NS_UnknownByteOrder:
                STFail(@"Unknow host byte order");
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

@end
