
#import "TestCPNumericData.h"
#import "CPNumericData.h"
#import "CPNumericData+TypeConversion.h"
#import "NumericDataTypeConversions.h"

@implementation TestCPNumericData
- (void)testNilShapeGivesSingleDimension {
    
    CPNumericData *nd = [[CPNumericData alloc] initWithData:[NSMutableData dataWithLength:1*sizeof(float)]
                                                dtypeString:@"=f4"
                                                      shape:nil];
    NSUInteger actual = nd.ndims;
    NSUInteger expected = 1;
    STAssertEquals(actual, expected, @"ndims == 1");
    expected = [nd.shape count];
    STAssertEquals(actual, expected, @"ndims == 1");
    
    [nd release];
}

- (void)testNdimsGivesShapeCount {
    id shape = [NSArray arrayWithObjects:
                [NSNumber numberWithUnsignedInt:2],
                [NSNumber numberWithUnsignedInt:2],
                [NSNumber numberWithUnsignedInt:2],
                (id)nil
                ];
    
    NSUInteger nElems = 2*2*2;
    CPNumericData *nd = [[CPNumericData alloc] initWithData:[NSMutableData dataWithLength:nElems*sizeof(float)]
                                                      dtype:[CPNumericDataType dataType:CPFloatingPointDataType
                                                                            sampleBytes:sizeof(float)
                                                                              byteOrder:NSHostByteOrder()]
                                                      shape:shape];
    
    STAssertEquals(nd.ndims, nd.shape.count, @"ndims == shape.count == 3");
    
    [nd release];

}

- (void)testNilShapeCorrectElementCount {
    NSUInteger nElems = 13;
    CPNumericData *nd = [[CPNumericData alloc] initWithData:[NSMutableData dataWithLength:nElems*sizeof(float)]
                                                dtypeString:@"=f4"
                                                      shape:nil];
    
    STAssertEquals(nd.ndims, (NSUInteger)1, @"ndims == 1");
    
    NSUInteger prod = 1;
    for(NSNumber *num in nd.shape) {
        prod *= [num unsignedIntValue];
    }
    
    STAssertEquals(prod, nElems, @"prod == nElems");
    
    [nd release];
}

- (void)testIllegalShapeRaisesException {
    id shape = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:2],
                [NSNumber numberWithUnsignedInt:2],
                [NSNumber numberWithUnsignedInt:2],
                (id)nil];
    NSUInteger nElems = 5;
    STAssertThrowsSpecificNamed([[CPNumericData alloc] initWithData:[NSMutableData dataWithLength:nElems*sizeof(NSUInteger)]
                                                              dtype:[CPNumericDataType dataType:CPUnsignedIntegerDataType
                                                                                    sampleBytes:sizeof(NSUInteger)
                                                                                      byteOrder:NSHostByteOrder()]
                                                 shape:shape],
                                NSException,
                                CPNumericDataException,
                                @"Illegal shape should throw");
    
}

- (void)testReturnsDataLength {
    CPNumericData* nd = [[CPNumericData alloc] initWithData:[NSMutableData dataWithLength:10*sizeof(float)]
                                                dtypeString:@"=f4"
                                                      shape:nil];
    
    NSUInteger expected = 10*sizeof(float);
    NSUInteger actual = [nd length];
    STAssertEquals(expected, actual, @"data length");
    
    [nd release];
    
}

- (void)testBytesEqualDataBytes {
    NSUInteger nElements = 10;
    NSMutableData* data = [NSMutableData dataWithLength:nElements*sizeof(NSInteger)];
    NSInteger *intData = (NSInteger*)[data mutableBytes];
    for(NSUInteger i=0; i<nElements; i++) {
        intData[i] = i;
    }
    
    CPNumericData* nd = [[CPNumericData alloc] initWithData:data
                                                      dtype:[CPNumericDataType dataType:CPIntegerDataType
                                                                            sampleBytes:sizeof(NSInteger)
                                                                              byteOrder:NSHostByteOrder()]
                                                      shape:nil];
    
    NSData *expected = data;
    STAssertEqualObjects(data, nd, @"equal objects");
    STAssertTrue([expected isEqualToData:nd], @"data isEqualToData:");
    
    [nd release];
}    

- (void)testArchivingRoundTrip {
    NSUInteger nElems = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems*sizeof(float)];
    float *samples = (float*)[data mutableBytes];
    for(NSUInteger i=0; i<nElems; i++) {
        samples[i] = sin(i);
    }
    
    CPNumericData *nd = [[CPNumericData alloc] initWithData:data
                                                      dtype:[CPNumericDataType dataType:CPFloatingPointDataType
                                                                            sampleBytes:sizeof(float)
                                                                              byteOrder:NSHostByteOrder()]
                                                      shape:nil];
    
    CPNumericData *nd2 = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:nd]];
    
    STAssertTrue([nd isEqualToData:nd2], @"equal data");
    STAssertEqualObjects(nd.dtype.dtypeString, nd2.dtype.dtypeString, @"dtypeStrings equal");
    STAssertEqualObjects(nd.shape, nd2.shape, @"shapes equal");
    
    [nd release];
        
}

- (void)testNSamplesCorrectForDataType {
    NSUInteger nElems = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems*sizeof(float)];
    float *samples = (float*)[data mutableBytes];
    for(NSUInteger i=0; i<nElems; i++) {
        samples[i] = sin(i);
    }
    
    CPNumericData *nd = [[CPNumericData alloc] initWithData:data
                                                      dtype:[CPNumericDataType dataType:CPFloatingPointDataType
                                                                            sampleBytes:sizeof(float)
                                                                              byteOrder:NSHostByteOrder()]
                                                      shape:nil];
    
    STAssertEquals([nd nSamples], nElems, @"nSamples==nElems");
    
    nElems = 10;
    data = [NSMutableData dataWithLength:nElems*sizeof(char)];
    char *charSamples = (char*)[data mutableBytes];
    for(NSUInteger i=0; i<nElems; i++) {
        charSamples[i] = sin(i);
    }
    
    nd = [[CPNumericData alloc] initWithData:data
                                       dtype:[CPNumericDataType dataType:CPIntegerDataType
                                                             sampleBytes:sizeof(char)
                                                               byteOrder:NSHostByteOrder()]
                                       shape:nil];
    
    STAssertEquals([nd nSamples], nElems, @"nSamples==nElems");
}

- (void)testDTypeAccessorsCorrectForDataType {
    NSUInteger nElems = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems*sizeof(float)];
    float *samples = (float*)[data mutableBytes];
    for(NSUInteger i=0; i<nElems; i++) {
        samples[i] = sin(i);
    }
    
    CPNumericData *nd = [[CPNumericData alloc] initWithData:data
                                                      dtype:[CPNumericDataType dataType:CPFloatingPointDataType
                                                                            sampleBytes:sizeof(float)
                                                                              byteOrder:NSHostByteOrder()]
                                                      shape:nil];
    
    STAssertEquals([nd dataType], CPFloatingPointDataType, @"dataType");
    STAssertEquals([nd sampleBytes], ((NSUInteger)sizeof(float)), @"sampleBytes");
    STAssertEquals([nd byteOrder], NSHostByteOrder(), @"byteOrder");
}

- (void)testConvertTypeConvertsType {
    NSUInteger nElems = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems*sizeof(float)];
    float *samples = (float*)[data mutableBytes];
    for(NSUInteger i=0; i<nElems; i++) {
        samples[i] = sin(i);
    }
    
    CPNumericData *fd = [[CPNumericData alloc] initWithData:data
                                                      dtype:[CPNumericDataType dataType:CPFloatingPointDataType
                                                                            sampleBytes:sizeof(float)
                                                                              byteOrder:NSHostByteOrder()]
                                                      shape:nil];
    
    CPNumericData *dd = [fd dataByConvertingToType:CPFloatingPointDataType
                                       sampleBytes:sizeof(double)
                                         byteOrder:NSHostByteOrder()];
    
    NSData *ddExpected = coreplot::convert_numeric_data_type<float,double>(fd, NSHostByteOrder(), NSHostByteOrder());
    
    STAssertTrue([dd isEqualToData:ddExpected], @"%@ =? %@", dd, ddExpected);
}

- (void)testSamplePointerCorrect {
    NSUInteger nElems = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems*sizeof(float)];
    float *samples = (float*)[data mutableBytes];
    for(NSUInteger i=0; i<nElems; i++) {
        samples[i] = sin(i);
    }
    
    CPNumericData *fd = [[CPNumericData alloc] initWithData:data
                                                      dtype:[CPNumericDataType dataType:CPFloatingPointDataType
                                                                            sampleBytes:sizeof(float)
                                                                              byteOrder:NSHostByteOrder()]
                                                      shape:nil];
    
    STAssertEquals(((float*)[fd bytes])+4, (float*)[fd samplePointer:4], @"%p,%p",samples+4, (float*)[fd samplePointer:4]);
    STAssertEquals(((float*)[fd bytes]), (float*)[fd samplePointer:0], @"");
    STAssertEquals(((float*)[fd bytes])+nElems-1, (float*)[fd samplePointer:nElems-1], @"");
    STAssertThrows([fd samplePointer:nElems], @"too many samples");
}

- (void)testSampleValueCorect {
    NSUInteger nElems = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems*sizeof(float)];
    float *samples = (float*)[data mutableBytes];
    for(NSUInteger i=0; i<nElems; i++) {
        samples[i] = sin(i);
    }
    
    CPNumericData *fd = [[CPNumericData alloc] initWithData:data
                                                      dtype:[CPNumericDataType dataType:CPFloatingPointDataType
                                                                            sampleBytes:sizeof(float)
                                                                              byteOrder:NSHostByteOrder()]
                                                      shape:nil];
    
    STAssertEqualsWithAccuracy([[fd sampleValue:0] doubleValue], sin(0), .01, @"sample value");
    STAssertEqualsWithAccuracy([[fd sampleValue:1] doubleValue], sin(1), .01, @"sample value");
}
@end
