#import "CPTUtilitiesTests.h"

#import "CPTUtilities.h"

@implementation CPTUtilitiesTests

@synthesize context;

#pragma mark -
#pragma mark Setup

-(void)setUp
{
    const size_t width            = 50;
    const size_t height           = 50;
    const size_t bitsPerComponent = 8;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

    context = CGBitmapContextCreate(NULL,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    width * bitsPerComponent * 4,
                                    colorSpace,
                                    kCGImageAlphaNoneSkipLast);

    CGColorSpaceRelease(colorSpace);
}

-(void)tearDown
{
    CGContextRelease(context);
    context = NULL;
}

#pragma mark -
#pragma mark Decimal conversions

-(void)testCPTDecimalIntegerValue
{
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];

    STAssertEquals(CPTDecimalIntegerValue([d decimalValue]), (NSInteger)42, @"Result incorrect");

    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals( (NSInteger)CPTDecimalIntegerValue([d decimalValue]), (NSInteger)42, @"Result incorrect" );
}

-(void)testCPTDecimalFloatValue
{
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];

    STAssertEquals(CPTDecimalFloatValue([d decimalValue]), (float)42.0, @"Result incorrect");

    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals(CPTDecimalFloatValue([d decimalValue]), (float)42.1, @"Result incorrect");
}

-(void)testCPTDecimalDoubleValue
{
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithString:@"42"];

    STAssertEquals(CPTDecimalDoubleValue([d decimalValue]), (double)42.0, @"Result incorrect");

    d = [NSDecimalNumber decimalNumberWithString:@"42.1"];
    STAssertEquals(CPTDecimalDoubleValue([d decimalValue]), (double)42.1, @"Result incorrect");
}

-(void)testToDecimalConversion
{
    NSInteger i          = 100;
    NSUInteger unsignedI = 100;
    float f              = 3.141f;
    double d             = 42.1;

    STAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"100"], [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(i)], @"NSInteger to NSDecimal conversion failed");
    STAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"100"], [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromUnsignedInteger(unsignedI)], @"NSUInteger to NSDecimal conversion failed");
    STAssertEqualsWithAccuracy([[NSDecimalNumber numberWithFloat:f] floatValue], [[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromFloat(f)] floatValue], 1.0e-7, @"float to NSDecimal conversion failed");
    STAssertEqualObjects([NSDecimalNumber numberWithDouble:d], [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromDouble(d)], @"double to NSDecimal conversion failed.");
}

-(void)testConvertNegativeOne
{
    NSDecimal zero = [[NSDecimalNumber zero] decimalValue];
    NSDecimal one  = [[NSDecimalNumber one] decimalValue];
    NSDecimal negativeOne;

    NSDecimalSubtract(&negativeOne, &zero, &one, NSRoundPlain);
    NSDecimal testValue;
    NSString *errMessage;

    // signed conversions
    testValue  = CPTDecimalFromChar(-1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromShort(-1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromLong(-1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromLongLong(-1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromInt(-1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromInteger(-1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&negativeOne, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &negativeOne) == NSOrderedSame, errMessage);
}

#pragma mark -
#pragma mark Cached values

-(void)testCachedZero
{
    NSDecimal zero = [[NSDecimalNumber zero] decimalValue];
    NSDecimal testValue;
    NSString *errMessage;

    // signed conversions
    testValue  = CPTDecimalFromChar(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromShort(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromLong(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromLongLong(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromInt(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromInteger(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    // unsigned conversions
    testValue  = CPTDecimalFromUnsignedChar(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedShort(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedLong(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedLongLong(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedInt(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedInteger(0);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&zero, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &zero) == NSOrderedSame, errMessage);
}

-(void)testCachedOne
{
    NSDecimal one = [[NSDecimalNumber one] decimalValue];
    NSDecimal testValue;
    NSString *errMessage;

    // signed conversions
    testValue  = CPTDecimalFromChar(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromShort(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromLong(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromLongLong(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromInt(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromInteger(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    // unsigned conversions
    testValue  = CPTDecimalFromUnsignedChar(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedShort(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedLong(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedLongLong(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedInt(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);

    testValue  = CPTDecimalFromUnsignedInteger(1);
    errMessage = [NSString stringWithFormat:@"test value was %@, expected %@", NSDecimalString(&testValue, nil), NSDecimalString(&one, nil)];
    STAssertTrue(NSDecimalCompare(&testValue, &one) == NSOrderedSame, errMessage);
}

#pragma mark -
#pragma mark Pixel alignment

-(void)testCPTAlignPointToUserSpace
{
    CGPoint point, alignedPoint;

    point        = CPTPointMake(10.49999, 10.49999);
    alignedPoint = CPTAlignPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(10.5), @"round x (10.49999, 10.49999)");
    STAssertEquals(alignedPoint.y, CPTFloat(10.5), @"round y (10.49999, 10.49999)");

    point        = CPTPointMake(10.5, 10.5);
    alignedPoint = CPTAlignPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(10.5), @"round x (10.5, 10.5)");
    STAssertEquals(alignedPoint.y, CPTFloat(10.5), @"round y (10.5, 10.5)");

    point        = CPTPointMake(10.50001, 10.50001);
    alignedPoint = CPTAlignPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(10.5), @"round x (10.50001, 10.50001)");
    STAssertEquals(alignedPoint.y, CPTFloat(10.5), @"round y (10.50001, 10.50001)");

    point        = CPTPointMake(10.99999, 10.99999);
    alignedPoint = CPTAlignPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(10.5), @"round x (10.99999, 10.99999)");
    STAssertEquals(alignedPoint.y, CPTFloat(10.5), @"round y (10.99999, 10.99999)");

    point        = CPTPointMake(11.0, 11.0);
    alignedPoint = CPTAlignPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(11.5), @"round x (11.0, 11.0)");
    STAssertEquals(alignedPoint.y, CPTFloat(11.5), @"round y (11.0, 11.0)");

    point        = CPTPointMake(11.00001, 11.00001);
    alignedPoint = CPTAlignPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(11.5), @"round x (11.00001, 11.00001)");
    STAssertEquals(alignedPoint.y, CPTFloat(11.5), @"round y (11.00001, 11.00001)");
}

-(void)testCPTAlignSizeToUserSpace
{
    CGSize size, alignedSize;

    size        = CPTSizeMake(10.49999, 10.49999);
    alignedSize = CPTAlignSizeToUserSpace(self.context, size);
    STAssertEquals(alignedSize.width, CPTFloat(10.0), @"round width (10.49999, 10.49999)");
    STAssertEquals(alignedSize.height, CPTFloat(10.0), @"round height (10.49999, 10.49999)");

    size        = CPTSizeMake(10.5, 10.5);
    alignedSize = CPTAlignSizeToUserSpace(self.context, size);
    STAssertEquals(alignedSize.width, CPTFloat(11.0), @"round width (10.5, 10.5)");
    STAssertEquals(alignedSize.height, CPTFloat(11.0), @"round height (10.5, 10.5)");

    size        = CPTSizeMake(10.50001, 10.50001);
    alignedSize = CPTAlignSizeToUserSpace(self.context, size);
    STAssertEquals(alignedSize.width, CPTFloat(11.0), @"round width (10.50001, 10.50001)");
    STAssertEquals(alignedSize.height, CPTFloat(11.0), @"round height (10.50001, 10.50001)");
}

-(void)testCPTAlignRectToUserSpace
{
    CGRect rect, alignedRect;

    rect        = CPTRectMake(10.49999, 10.49999, 10.49999, 10.49999);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (10.49999, 10.49999, 10.49999, 10.49999)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (10.49999, 10.49999, 10.49999, 10.49999)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.49999, 10.49999, 10.49999, 10.49999)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.49999, 10.49999, 10.49999, 10.49999)");

    rect        = CPTRectMake(10.5, 10.5, 10.5, 10.5);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (10.5, 10.5, 10.5, 10.5)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (10.5, 10.5, 10.5, 10.5)");
    STAssertEquals(alignedRect.size.width, CPTFloat(11.0), @"round width (10.5, 10.5, 10.5, 10.5)");
    STAssertEquals(alignedRect.size.height, CPTFloat(11.0), @"round height (10.5, 10.5, 10.5, 10.5)");

    rect        = CPTRectMake(10.50001, 10.50001, 10.50001, 10.50001);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (10.50001, 10.50001, 10.50001, 10.50001)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (10.50001, 10.50001, 10.50001, 10.50001)");
    STAssertEquals(alignedRect.size.width, CPTFloat(11.0), @"round width (10.50001, 10.50001, 10.50001, 10.50001)");
    STAssertEquals(alignedRect.size.height, CPTFloat(11.0), @"round height (10.50001, 10.50001, 10.50001, 10.50001)");

    rect        = CPTRectMake(10.49999, 10.49999, 10.0, 10.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (10.49999, 10.49999, 10.0, 10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (10.49999, 10.49999, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.49999, 10.49999, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.49999, 10.49999, 10.0, 10.0)");

    rect        = CPTRectMake(10.5, 10.5, 10.0, 10.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (10.5, 10.5, 10.0, 10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (10.5, 10.5, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.5, 10.5, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.5, 10.5, 10.0, 10.0)");

    rect        = CPTRectMake(10.50001, 10.50001, 10.0, 10.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (10.50001, 10.50001, 10.0, 10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (10.50001, 10.50001, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.50001, 10.50001, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.50001, 10.50001, 10.0, 10.0)");

    rect        = CPTRectMake(10.772727, 10.772727, 10.363636, 10.363636);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (10.772727, 10.772727, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (10.772727, 10.772727, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.size.width, CPTFloat(11.0), @"round width (10.772727, 10.772727, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.size.height, CPTFloat(11.0), @"round height (10.772727, 10.772727, 10.363636, 10.363636);");

    rect        = CPTRectMake(10.136363, 10.136363, 10.363636, 10.363636);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (10.136363, 10.136363, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (10.136363, 10.136363, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.136363, 10.136363, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.136363, 10.136363, 10.363636, 10.363636);");

    rect        = CPTRectMake(20.49999, 20.49999, -10.0, -10.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (20.49999, 20.49999, -10.0, -10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (20.49999, 20.49999, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (20.49999, 20.49999, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (20.49999, 20.49999, -10.0, -10.0)");

    rect        = CPTRectMake(20.5, 20.5, -10.0, -10.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (20.5, 20.5, -10.0, -10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (20.5, 20.5, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (20.5, 20.5, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (20.5, 20.5, -10.0, -10.0)");

    rect        = CPTRectMake(20.50001, 20.50001, -10.0, -10.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.5), @"round x (20.50001, 20.50001, -10.0, -10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.5), @"round y (20.50001, 20.50001, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (20.50001, 20.50001, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (20.50001, 20.50001, -10.0, -10.0)");

    rect        = CPTRectMake(19.6364, 15.49999, 20.2727, 0.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(19.5), @"round x (19.6364, 15.49999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(15.5), @"round y (19.6364, 15.49999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 15.49999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 15.49999, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 15.5, 20.2727, 0.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(19.5), @"round x (19.6364, 15.5, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(15.5), @"round y (19.6364, 15.5, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 15.5, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 15.5, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 15.50001, 20.2727, 0.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(19.5), @"round x (19.6364, 15.50001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(15.5), @"round y (19.6364, 15.50001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 15.50001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 15.50001, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 15.99999, 20.2727, 0.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(19.5), @"round x (19.6364, 15.99999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(15.5), @"round y (19.6364, 15.99999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 15.99999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 15.99999, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 16.0, 20.2727, 0.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(19.5), @"round x (19.6364, 16.0, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(16.5), @"round y (19.6364, 16.0, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 16.0, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 16.0, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 16.00001, 20.2727, 0.0);
    alignedRect = CPTAlignRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(19.5), @"round x (19.6364, 16.00001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(16.5), @"round y (19.6364, 16.00001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 16.00001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 16.00001, 20.2727, 0.0)");
}

-(void)testCPTAlignIntegralPointToUserSpace
{
    CGPoint point, alignedPoint;

    point        = CPTPointMake(10.49999, 10.49999);
    alignedPoint = CPTAlignIntegralPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(10.0), @"round x (10.49999, 10.49999)");
    STAssertEquals(alignedPoint.y, CPTFloat(10.0), @"round y (10.49999, 10.49999)");

    point        = CPTPointMake(10.5, 10.5);
    alignedPoint = CPTAlignIntegralPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(11.0), @"round x (10.5, 10.5)");
    STAssertEquals(alignedPoint.y, CPTFloat(11.0), @"round y (10.5, 10.5)");

    point        = CPTPointMake(10.50001, 10.50001);
    alignedPoint = CPTAlignIntegralPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(11.0), @"round x (10.50001, 10.50001)");
    STAssertEquals(alignedPoint.y, CPTFloat(11.0), @"round y (10.50001, 10.50001)");

    point        = CPTPointMake(10.99999, 10.99999);
    alignedPoint = CPTAlignIntegralPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(11.0), @"round x (10.99999, 10.99999)");
    STAssertEquals(alignedPoint.y, CPTFloat(11.0), @"round y (10.99999, 10.99999)");

    point        = CPTPointMake(11.0, 11.0);
    alignedPoint = CPTAlignIntegralPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(11.0), @"round x (11.0, 11.0)");
    STAssertEquals(alignedPoint.y, CPTFloat(11.0), @"round y (11.0, 11.0)");

    point        = CPTPointMake(11.00001, 11.00001);
    alignedPoint = CPTAlignIntegralPointToUserSpace(self.context, point);
    STAssertEquals(alignedPoint.x, CPTFloat(11.0), @"round x (11.00001, 11.00001)");
    STAssertEquals(alignedPoint.y, CPTFloat(11.0), @"round y (11.00001, 11.00001)");
}

-(void)testCPTAlignIntegralRectToUserSpace
{
    CGRect rect, alignedRect;

    rect        = CPTRectMake(10.49999, 10.49999, 10.49999, 10.49999);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.0), @"round x (10.49999, 10.49999, 10.49999, 10.49999)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.0), @"round y (10.49999, 10.49999, 10.49999, 10.49999)");
    STAssertEquals(alignedRect.size.width, CPTFloat(11.0), @"round width (10.49999, 10.49999, 10.49999, 10.49999)");
    STAssertEquals(alignedRect.size.height, CPTFloat(11.0), @"round height (10.49999, 10.49999, 10.49999, 10.49999)");

    rect        = CPTRectMake(10.5, 10.5, 10.5, 10.5);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(11.0), @"round x (10.5, 10.5, 10.5, 10.5)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(11.0), @"round y (10.5, 10.5, 10.5, 10.5)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.5, 10.5, 10.5, 10.5)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.5, 10.5, 10.5, 10.5)");

    rect        = CPTRectMake(10.50001, 10.50001, 10.50001, 10.50001);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(11.0), @"round x (10.50001, 10.50001, 10.50001, 10.50001)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(11.0), @"round y (10.50001, 10.50001, 10.50001, 10.50001)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.50001, 10.50001, 10.50001, 10.50001)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.50001, 10.50001, 10.50001, 10.50001)");

    rect        = CPTRectMake(10.49999, 10.49999, 10.0, 10.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.0), @"round x (10.49999, 10.49999, 10.0, 10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.0), @"round y (10.49999, 10.49999, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.49999, 10.49999, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.49999, 10.49999, 10.0, 10.0)");

    rect        = CPTRectMake(10.5, 10.5, 10.0, 10.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(11.0), @"round x (10.5, 10.5, 10.0, 10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(11.0), @"round y (10.5, 10.5, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.5, 10.5, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.5, 10.5, 10.0, 10.0)");

    rect        = CPTRectMake(10.50001, 10.50001, 10.0, 10.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(11.0), @"round x (10.50001, 10.50001, 10.0, 10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(11.0), @"round y (10.50001, 10.50001, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.50001, 10.50001, 10.0, 10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.50001, 10.50001, 10.0, 10.0)");

    rect        = CPTRectMake(10.772727, 10.772727, 10.363636, 10.363636);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(11.0), @"round x (10.772727, 10.772727, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.origin.y, CPTFloat(11.0), @"round y (10.772727, 10.772727, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.772727, 10.772727, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.772727, 10.772727, 10.363636, 10.363636);");

    rect        = CPTRectMake(10.13636, 10.13636, 10.36363, 10.36363);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.0), @"round x (10.136363, 10.136363, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.0), @"round y (10.136363, 10.136363, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (10.136363, 10.136363, 10.363636, 10.363636);");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (10.136363, 10.136363, 10.363636, 10.363636);");

    rect        = CPTRectMake(20.49999, 20.49999, -10.0, -10.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(10.0), @"round x (20.49999, 20.49999, -10.0, -10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(10.0), @"round y (20.49999, 20.49999, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (20.49999, 20.49999, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (20.49999, 20.49999, -10.0, -10.0)");

    rect        = CPTRectMake(20.5, 20.5, -10.0, -10.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(11.0), @"round x (20.5, 20.5, -10.0, -10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(11.0), @"round y (20.5, 20.5, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (20.5, 20.5, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (20.5, 20.5, -10.0, -10.0)");

    rect        = CPTRectMake(20.50001, 20.50001, -10.0, -10.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(11.0), @"round x (20.50001, 20.50001, -10.0, -10.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(11.0), @"round y (20.50001, 20.50001, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(10.0), @"round width (20.50001, 20.50001, -10.0, -10.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(10.0), @"round height (20.50001, 20.50001, -10.0, -10.0)");

    rect        = CPTRectMake(19.6364, 15.49999, 20.2727, 0.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(20.0), @"round x (19.6364, 15.49999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(15.0), @"round y (19.6364, 15.49999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 15.49999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 15.49999, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 15.5, 20.2727, 0.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(20.0), @"round x (19.6364, 15.5, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(16.0), @"round y (19.6364, 15.5, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 15.5, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 15.5, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 15.50001, 20.2727, 0.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(20.0), @"round x (19.6364, 15.50001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(16.0), @"round y (19.6364, 15.50001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 15.50001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 15.50001, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 15.99999, 20.2727, 0.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(20.0), @"round x (19.6364, 15.99999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(16.0), @"round y (19.6364, 15.99999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 15.99999, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 15.99999, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 16.0, 20.2727, 0.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(20.0), @"round x (19.6364, 16.0, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(16.0), @"round y (19.6364, 16.0, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 16.0, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 16.0, 20.2727, 0.0)");

    rect        = CPTRectMake(19.6364, 16.00001, 20.2727, 0.0);
    alignedRect = CPTAlignIntegralRectToUserSpace(self.context, rect);
    STAssertEquals(alignedRect.origin.x, CPTFloat(20.0), @"round x (19.6364, 16.00001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.origin.y, CPTFloat(16.0), @"round y (19.6364, 16.00001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.width, CPTFloat(20.0), @"round width (19.6364, 16.00001, 20.2727, 0.0)");
    STAssertEquals(alignedRect.size.height, CPTFloat(0.0), @"round height (19.6364, 16.00001, 20.2727, 0.0)");
}

@end
