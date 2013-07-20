#import "CPTLayerTests.h"

#import "CPTLayer.h"
#import "CPTUtilities.h"
#import "NSNumberExtensions.h"

static const double precision = 1.0e-6;

@interface CPTLayerTests()

-(void)testPositionsWithScale:(CGFloat)scale anchorPoint:(CGPoint)anchor expected:(NSArray *)expected;

@end

#pragma mark -

@implementation CPTLayerTests

@synthesize layer;
@synthesize positions;

#pragma mark -
#pragma mark Setup

-(void)setUp
{
    // starting layer positions for each test
    self.positions = [NSArray arrayWithObjects:
                      [NSNumber numberWithDouble:10.49999],
                      [NSNumber numberWithDouble:10.5],
                      [NSNumber numberWithDouble:10.50001],
                      [NSNumber numberWithDouble:10.99999],
                      [NSNumber numberWithDouble:11.0],
                      [NSNumber numberWithDouble:11.00001],
                      nil];

    CPTLayer *newLayer = [[CPTLayer alloc] initWithFrame:CPTRectMake(0.0, 0.0, 99.0, 99.0)];

    self.layer = newLayer;

    [newLayer release];
}

-(void)tearDown
{
    [layer release];
    [positions release];
}

#pragma mark - Pixel alignment @1x

-(void)testPixelAlign1xLeft
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.0],
                         [NSNumber numberWithDouble:10.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         nil];

    [self testPositionsWithScale:CPTFloat(1.0)
                     anchorPoint:CPTPointMake(0.0, 0.0)
                        expected:expected];
}

-(void)testPixelAlign1xLeftMiddle
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         nil];

    [self testPositionsWithScale:CPTFloat(1.0)
                     anchorPoint:CPTPointMake(0.25, 0.25)
                        expected:expected];
}

-(void)testPixelAlign1xMiddle
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:11.5],
                         nil];

    [self testPositionsWithScale:CPTFloat(1.0)
                     anchorPoint:CPTPointMake(0.5, 0.5)
                        expected:expected];
}

-(void)testPixelAlign1xRightMiddle
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.25],
                         [NSNumber numberWithDouble:10.25],
                         [NSNumber numberWithDouble:10.25],
                         [NSNumber numberWithDouble:11.25],
                         [NSNumber numberWithDouble:11.25],
                         [NSNumber numberWithDouble:11.25],
                         nil];

    [self testPositionsWithScale:CPTFloat(1.0)
                     anchorPoint:CPTPointMake(0.75, 0.75)
                        expected:expected];
}

-(void)testPixelAlign1xRight
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.0],
                         [NSNumber numberWithDouble:10.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         nil];

    [self testPositionsWithScale:CPTFloat(1.0)
                     anchorPoint:CPTPointMake(1.0, 1.0)
                        expected:expected];
}

#pragma mark - Pixel alignment @2x

-(void)testPixelAlign2xLeft
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         nil];

    [self testPositionsWithScale:CPTFloat(2.0)
                     anchorPoint:CPTPointMake(0.0, 0.0)
                        expected:expected];
}

-(void)testPixelAlign2xLeftMiddle
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.25],
                         [NSNumber numberWithDouble:10.25],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:11.25],
                         nil];

    [self testPositionsWithScale:CPTFloat(2.0)
                     anchorPoint:CPTPointMake(0.25, 0.25)
                        expected:expected];
}

-(void)testPixelAlign2xMiddle
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         nil];

    [self testPositionsWithScale:CPTFloat(2.0)
                     anchorPoint:CPTPointMake(0.5, 0.5)
                        expected:expected];
}

-(void)testPixelAlign2xRightMiddle
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.25],
                         [NSNumber numberWithDouble:10.25],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:10.75],
                         [NSNumber numberWithDouble:11.25],
                         nil];

    [self testPositionsWithScale:CPTFloat(2.0)
                     anchorPoint:CPTPointMake(0.75, 0.75)
                        expected:expected];
}

-(void)testPixelAlign2xRight
{
    NSArray *expected = [NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:10.5],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         [NSNumber numberWithDouble:11.0],
                         nil];

    [self testPositionsWithScale:CPTFloat(2.0)
                     anchorPoint:CPTPointMake(1.0, 1.0)
                        expected:expected];
}

#pragma mark - Utility methods

-(void)testPositionsWithScale:(CGFloat)scale anchorPoint:(CGPoint)anchor expected:(NSArray *)expectedValues
{
    NSUInteger positionCount = self.positions.count;

    NSParameterAssert(expectedValues.count == positionCount);

    self.layer.contentsScale = scale;
    self.layer.anchorPoint   = anchor;

    for ( NSUInteger i = 0; i < positionCount; i++ ) {
        CGFloat position      = [(NSNumber *)[self.positions objectAtIndex:i] cgFloatValue];
        CGPoint layerPosition = CGPointMake(position, position);
        self.layer.position = layerPosition;

        [self.layer pixelAlign];

        CGPoint alignedPoint = self.layer.position;
        CGFloat expected     = [(NSNumber *)[expectedValues objectAtIndex:i] cgFloatValue];

        NSString *message = [NSString stringWithFormat:@"pixelAlign at %%@ = %f with scale %g and anchor %@", position, scale, CPTStringFromPoint(anchor)];

        STAssertEqualsWithAccuracy(alignedPoint.x, expected, precision, message, @"x");
        STAssertEqualsWithAccuracy(alignedPoint.y, expected, precision, message, @"y");
    }
}

@end
