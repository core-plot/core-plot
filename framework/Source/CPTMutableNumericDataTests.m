#import "CPTMutableNumericDataTests.h"

#import "CPTExceptions.h"
#import "CPTMutableNumericData+TypeConversion.h"
#import "CPTNumericData+TypeConversion.h"

@implementation CPTMutableNumericDataTests

-(void)testNilShapeGivesSingleDimension
{
    CPTMutableNumericData *nd = [[CPTMutableNumericData alloc] initWithData:[NSMutableData dataWithLength:1 * sizeof(float)]
                                                             dataTypeString:@"=f4"
                                                                      shape:nil];
    NSUInteger actual   = nd.numberOfDimensions;
    NSUInteger expected = 1;

    STAssertEquals(actual, expected, @"numberOfDimensions == 1");
    expected = [nd.shape count];
    STAssertEquals(actual, expected, @"numberOfDimensions == 1");

    [nd release];
}

-(void)testNumberOfDimensionsGivesShapeCount
{
    id shape = [NSArray arrayWithObjects:
                [NSNumber numberWithUnsignedInt:2],
                [NSNumber numberWithUnsignedInt:2],
                [NSNumber numberWithUnsignedInt:2],
                nil
               ];

    NSUInteger nElems         = 2 * 2 * 2;
    CPTMutableNumericData *nd = [[CPTMutableNumericData alloc] initWithData:[NSMutableData dataWithLength:nElems * sizeof(float)]
                                                                   dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
                                                                      shape:shape];

    STAssertEquals(nd.numberOfDimensions, nd.shape.count, @"numberOfDimensions == shape.count == 3");

    [nd release];
}

-(void)testNilShapeCorrectElementCount
{
    NSUInteger nElems         = 13;
    CPTMutableNumericData *nd = [[CPTMutableNumericData alloc] initWithData:[NSMutableData dataWithLength:nElems * sizeof(float)]
                                                             dataTypeString:@"=f4"
                                                                      shape:nil];

    STAssertEquals(nd.numberOfDimensions, (NSUInteger)1, @"numberOfDimensions == 1");

    NSUInteger prod = 1;
    for ( NSNumber *num in nd.shape ) {
        prod *= [num unsignedIntValue];
    }

    STAssertEquals(prod, nElems, @"prod == nElems");

    [nd release];
}

-(void)testIllegalShapeRaisesException
{
    id shape = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:2],
                [NSNumber numberWithUnsignedInt:2],
                [NSNumber numberWithUnsignedInt:2],
                nil];
    NSUInteger nElems = 5;

    STAssertThrowsSpecificNamed([[CPTMutableNumericData alloc] initWithData:[NSMutableData dataWithLength:nElems * sizeof(NSUInteger)]
                                                                   dataType:CPTDataType( CPTUnsignedIntegerDataType, sizeof(NSUInteger), NSHostByteOrder() )
                                                                      shape:shape],
                                NSException,
                                CPTNumericDataException,
                                @"Illegal shape should throw");
}

-(void)testReturnsDataLength
{
    CPTMutableNumericData *nd = [[CPTMutableNumericData alloc] initWithData:[NSMutableData dataWithLength:10 * sizeof(float)]
                                                             dataTypeString:@"=f4"
                                                                      shape:nil];

    NSUInteger expected = 10 * sizeof(float);
    NSUInteger actual   = [nd length];

    STAssertEquals(expected, actual, @"data length");

    [nd release];
}

-(void)testBytesEqualDataBytes
{
    NSUInteger nElements = 10;
    NSMutableData *data  = [NSMutableData dataWithLength:nElements * sizeof(NSInteger)];
    NSInteger *intData   = (NSInteger *)[data mutableBytes];

    for ( NSUInteger i = 0; i < nElements; i++ ) {
        intData[i] = (NSInteger)i;
    }

    CPTMutableNumericData *nd = [[CPTMutableNumericData alloc] initWithData:data
                                                                   dataType:CPTDataType( CPTIntegerDataType, sizeof(NSInteger), NSHostByteOrder() )
                                                                      shape:nil];

    NSMutableData *expected = data;
    STAssertTrue([expected isEqualToData:nd.data], @"data isEqualToData:");

    [nd release];
}

-(void)testArchivingRoundTrip
{
    NSUInteger nElems   = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems * sizeof(float)];
    float *samples      = (float *)[data mutableBytes];

    for ( NSUInteger i = 0; i < nElems; i++ ) {
        samples[i] = sinf(i);
    }

    CPTMutableNumericData *nd = [[CPTMutableNumericData alloc] initWithData:data
                                                                   dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
                                                                      shape:nil];

    CPTMutableNumericData *nd2 = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:nd]];

    STAssertTrue([nd.data isEqualToData:nd2.data], @"equal data");

    CPTNumericDataType ndType  = nd.dataType;
    CPTNumericDataType nd2Type = nd2.dataType;

    STAssertEquals(ndType.dataTypeFormat, nd2Type.dataTypeFormat, @"dataType.dataTypeFormat equal");
    STAssertEquals(ndType.sampleBytes, nd2Type.sampleBytes, @"dataType.sampleBytes equal");
    STAssertEquals(ndType.byteOrder, nd2Type.byteOrder, @"dataType.byteOrder equal");
    STAssertEqualObjects(nd.shape, nd2.shape, @"shapes equal");

    [nd release];
}

-(void)testNumberOfSamplesCorrectForDataType
{
    NSUInteger nElems   = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems * sizeof(float)];
    float *samples      = (float *)[data mutableBytes];

    for ( NSUInteger i = 0; i < nElems; i++ ) {
        samples[i] = sinf(i);
    }

    CPTMutableNumericData *nd = [[CPTMutableNumericData alloc] initWithData:data
                                                                   dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
                                                                      shape:nil];

    STAssertEquals([nd numberOfSamples], nElems, @"numberOfSamples == nElems");
    [nd release];

    nElems = 10;
    data   = [NSMutableData dataWithLength:nElems * sizeof(char)];
    char *charSamples = (char *)[data mutableBytes];
    for ( NSUInteger i = 0; i < nElems; i++ ) {
        charSamples[i] = (char)sin(i);
    }

    nd = [[CPTMutableNumericData alloc] initWithData:data
                                            dataType:CPTDataType( CPTIntegerDataType, sizeof(char), NSHostByteOrder() )
                                               shape:nil];

    STAssertEquals([nd numberOfSamples], nElems, @"numberOfSamples == nElems");
    [nd release];
}

-(void)testDataTypeAccessorsCorrectForDataType
{
    NSUInteger nElems   = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems * sizeof(float)];
    float *samples      = (float *)[data mutableBytes];

    for ( NSUInteger i = 0; i < nElems; i++ ) {
        samples[i] = sinf(i);
    }

    CPTMutableNumericData *nd = [[CPTMutableNumericData alloc] initWithData:data
                                                                   dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
                                                                      shape:nil];

    STAssertEquals([nd dataTypeFormat], CPTFloatingPointDataType, @"dataTypeFormat");
    STAssertEquals([nd sampleBytes], sizeof(float), @"sampleBytes");
    STAssertEquals([nd byteOrder], NSHostByteOrder(), @"byteOrder");

    [nd release];
}

-(void)testConvertTypeConvertsType
{
    NSUInteger numberOfSamples = 10;
    NSMutableData *data        = [NSMutableData dataWithLength:numberOfSamples * sizeof(float)];
    float *samples             = (float *)[data mutableBytes];

    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        samples[i] = sinf(i);
    }

    CPTMutableNumericData *fd = [[CPTMutableNumericData alloc] initWithData:data
                                                                   dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
                                                                      shape:nil];

    CPTNumericData *dd = [fd dataByConvertingToType:CPTFloatingPointDataType
                                        sampleBytes:sizeof(double)
                                          byteOrder:NSHostByteOrder()];

    [fd release];

    const double *doubleSamples = (const double *)[dd.data bytes];
    for ( NSUInteger i = 0; i < numberOfSamples; i++ ) {
        STAssertTrue(samples[i] == doubleSamples[i], @"(float)%g != (double)%g", samples[i], doubleSamples[i]);
    }
}

-(void)testSamplePointerCorrect
{
    NSUInteger nElems   = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems * sizeof(float)];
    float *samples      = (float *)[data mutableBytes];

    for ( NSUInteger i = 0; i < nElems; i++ ) {
        samples[i] = sinf(i);
    }

    CPTMutableNumericData *fd = [[CPTMutableNumericData alloc] initWithData:data
                                                                   dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
                                                                      shape:nil];

    STAssertEquals( ( (float *)[fd mutableBytes] ) + 4, (float *)[fd samplePointer:4], @"%p,%p", samples + 4, (float *)[fd samplePointer:4] );
    STAssertEquals( ( (float *)[fd mutableBytes] ), (float *)[fd samplePointer:0], @"" );
    STAssertEquals( ( (float *)[fd mutableBytes] ) + nElems - 1, (float *)[fd samplePointer:nElems - 1], @"" );
    STAssertNil([fd samplePointer:nElems], @"too many samples");

    [fd release];
}

-(void)testSampleValueCorrect
{
    NSUInteger nElems   = 10;
    NSMutableData *data = [NSMutableData dataWithLength:nElems * sizeof(float)];
    float *samples      = (float *)[data mutableBytes];

    for ( NSUInteger i = 0; i < nElems; i++ ) {
        samples[i] = sinf(i);
    }

    CPTMutableNumericData *fd = [[CPTMutableNumericData alloc] initWithData:data
                                                                   dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
                                                                      shape:nil];

    STAssertEqualsWithAccuracy([[fd sampleValue:0] doubleValue], sin(0), 0.01, @"sample value");
    STAssertEqualsWithAccuracy([[fd sampleValue:1] doubleValue], sin(1), 0.01, @"sample value");

    [fd release];
}

-(void)testMutableCopy
{
    const NSUInteger nElems = 10;
    CPTNumericData *nd      = [[CPTNumericData alloc] initWithData:[NSMutableData dataWithLength:nElems * sizeof(float)]
                                                          dataType:CPTDataType( CPTFloatingPointDataType, sizeof(float), NSHostByteOrder() )
                                                             shape:nil];

    CPTMutableNumericData *ndCopy = [nd mutableCopy];

    // should be mutable--if not, this will error
    ndCopy.dataType = CPTDataType( CPTFloatingPointDataType, sizeof(double), NSHostByteOrder() );

    [nd release];
    [ndCopy release];
}

@end
