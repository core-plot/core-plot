#import "CPTAxisLabel.h"
#import "CPTAxisLabelTests.h"
#import "CPTBorderedLayer.h"
#import "CPTMutableTextStyle.h"
#import "CPTUtilities.h"
#import <tgmath.h>

static const double precision = 1.0e-6;

@implementation CPTAxisLabelTests

static CGPoint roundPoint(CGPoint position, CGSize contentSize, CGPoint anchor);

static CGPoint roundPoint(CGPoint position, CGSize contentSize, CGPoint anchor)
{
    CGPoint newPosition = position;

    CGPoint newAnchor = CGPointMake(contentSize.width * anchor.x,
                                    contentSize.height * anchor.y);

    newPosition.x = round( position.x + anchor.x - newAnchor.x - CPTFloat(0.5) ) + newAnchor.x;
    newPosition.y = round( position.y + anchor.y - newAnchor.y - CPTFloat(0.5) ) + newAnchor.y;

    return newPosition;
}

-(void)testPositionRelativeToViewPointRaisesForInvalidDirection
{
    CPTAxisLabel *label;

    @try {
        label = [[CPTAxisLabel alloc] initWithText:@"CPTAxisLabelTests-testPositionRelativeToViewPointRaisesForInvalidDirection" textStyle:[CPTTextStyle textStyle]];

        STAssertThrowsSpecificNamed([label positionRelativeToViewPoint:CGPointZero forCoordinate:CPTCoordinateX inDirection:INT_MAX], NSException, NSInvalidArgumentException, @"Should raise NSInvalidArgumentException for invalid direction (type CPTSign)");
    }
    @finally {
        [label release];
    }
}

-(void)testPositionRelativeToViewPointPositionsForXCoordinate
{
    CPTAxisLabel *label;
    CGFloat start = 100.0;

    @try {
        label = [[CPTAxisLabel alloc] initWithText:@"CPTAxisLabelTests-testPositionRelativeToViewPointPositionsForXCoordinate" textStyle:[CPTTextStyle textStyle]];
        CPTLayer *contentLayer = label.contentLayer;
        CGSize contentSize     = contentLayer.bounds.size;
        label.offset = 20.0;

        CGPoint viewPoint = CGPointMake(start, start);

        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position    = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPTCoordinateX
                               inDirection:CPTSignNone];

        CGPoint newPosition = roundPoint(CGPointMake(start - label.offset, start), contentSize, contentLayer.anchorPoint);

        STAssertEqualsWithAccuracy( contentLayer.position.x, newPosition.x, precision, @"Should add negative offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy( contentLayer.position.y, newPosition.y, precision, @"Should add negative offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, CPTFloat(1.0), precision, @"Should anchor at (1.0, 0.5)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, CPTFloat(0.5), precision, @"Should anchor at (1.0, 0.5)");

        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position    = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPTCoordinateX
                               inDirection:CPTSignNegative];

        newPosition = roundPoint(CGPointMake(start - label.offset, start), contentSize, contentLayer.anchorPoint);

        STAssertEqualsWithAccuracy( contentLayer.position.x, newPosition.x, precision, @"Should add negative offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy( contentLayer.position.y, newPosition.y, precision, @"Should add negative offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, CPTFloat(1.0), precision, @"Should anchor at (1.0, 0.5)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, CPTFloat(0.5), precision, @"Should anchor at (1.0, 0.5)");

        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position    = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPTCoordinateX
                               inDirection:CPTSignPositive];

        newPosition = roundPoint(CGPointMake(start + label.offset, start), contentSize, contentLayer.anchorPoint);

        STAssertEqualsWithAccuracy( contentLayer.position.x, newPosition.x, precision, @"Should add positive offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy( contentLayer.position.y, newPosition.y, precision, @"Should add positive offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, CPTFloat(0.0), precision, @"Should anchor at (0.0, 0.5)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, CPTFloat(0.5), precision, @"Should anchor at (0.0, 0.5)");
    }
    @finally {
        [label release];
    }
}

-(void)testPositionRelativeToViewPointPositionsForYCoordinate
{
    CPTAxisLabel *label;
    CGFloat start = 100.0;

    @try {
        label = [[CPTAxisLabel alloc] initWithText:@"CPTAxisLabelTests-testPositionRelativeToViewPointPositionsForYCoordinate" textStyle:[CPTTextStyle textStyle]];
        CPTLayer *contentLayer = label.contentLayer;
        CGSize contentSize     = contentLayer.bounds.size;
        label.offset = 20.0;

        CGPoint viewPoint = CGPointMake(start, start);

        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position    = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPTCoordinateY
                               inDirection:CPTSignNone];

        CGPoint newPosition = roundPoint(CGPointMake(start, start - label.offset), contentSize, contentLayer.anchorPoint);

        STAssertEqualsWithAccuracy( contentLayer.position.x, newPosition.x, precision, @"Should add negative offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy( contentLayer.position.y, newPosition.y, precision, @"Should add negative offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, CPTFloat(0.5), precision, @"Should anchor at (0.5, 1.0)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, CPTFloat(1.0), precision, @"Should anchor at (0.5, 1.0)");

        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position    = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPTCoordinateY
                               inDirection:CPTSignNegative];

        newPosition = roundPoint(CGPointMake(start, start - label.offset), contentSize, contentLayer.anchorPoint);

        STAssertEqualsWithAccuracy( contentLayer.position.x, newPosition.x, precision, @"Should add negative offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy( contentLayer.position.y, newPosition.y, precision, @"Should add negative offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, CPTFloat(0.5), precision, @"Should anchor at (0.5, 1.0)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, CPTFloat(1.0), precision, @"Should anchor at (0.5, 1.0)");

        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position    = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPTCoordinateY
                               inDirection:CPTSignPositive];

        newPosition = roundPoint(CGPointMake(start, start + label.offset), contentSize, contentLayer.anchorPoint);

        STAssertEqualsWithAccuracy( contentLayer.position.x, newPosition.x, precision, @"Should add positive offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy( contentLayer.position.y, newPosition.y, precision, @"Should add positive offset, %@ != %@", CPTStringFromPoint(contentLayer.position), CPTStringFromPoint(newPosition) );
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, CPTFloat(0.5), precision, @"Should anchor at (0.5, 0.0)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, CPTFloat(0.0), precision, @"Should anchor at (0.5, 0.0)");
    }
    @finally {
        [label release];
    }
}

@end
