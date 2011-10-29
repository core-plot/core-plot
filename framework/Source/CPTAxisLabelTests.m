#import "CPTAxisLabel.h"
#import "CPTAxisLabelTests.h"
#import "CPTBorderedLayer.h"
#import "CPTColor.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTMutableTextStyle.h"
#import <tgmath.h>

static const double precision = 1.0e-6;

@implementation CPTAxisLabelTests

static CGPoint roundPoint(CGPoint position, CGSize contentSize, CGPoint anchor);

static CGPoint roundPoint(CGPoint position, CGSize contentSize, CGPoint anchor)
{
	CGPoint newPosition = position;

	newPosition.x = round(newPosition.x) - round(contentSize.width * anchor.x) + (contentSize.width * anchor.x);
	newPosition.y = round(newPosition.y) - round(contentSize.height * anchor.y) + (contentSize.height * anchor.y);
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
		CGSize contentSize	   = contentLayer.bounds.size;
		label.offset = 20.0;

		CGPoint viewPoint = CGPointMake(start, start);

		contentLayer.anchorPoint = CGPointZero;
		contentLayer.position	 = CGPointZero;
		[label positionRelativeToViewPoint:viewPoint
							 forCoordinate:CPTCoordinateX
							   inDirection:CPTSignNone];

		CGPoint newPosition = roundPoint(CGPointMake(start - label.offset, start), contentSize, contentLayer.anchorPoint);

		STAssertEquals( contentLayer.position, newPosition, @"Should add negative offset, %@ != %@", NSStringFromPoint( NSPointFromCGPoint(contentLayer.position) ), NSStringFromPoint( NSPointFromCGPoint(newPosition) ) );
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)1.0, precision, @"Should anchor at (1.0,0.5)");
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)0.5, precision, @"Should anchor at (1.0,0.5)");

		contentLayer.anchorPoint = CGPointZero;
		contentLayer.position	 = CGPointZero;
		[label positionRelativeToViewPoint:viewPoint
							 forCoordinate:CPTCoordinateX
							   inDirection:CPTSignNegative];

		newPosition = roundPoint(CGPointMake(start - label.offset, start), contentSize, contentLayer.anchorPoint);

		STAssertEquals( contentLayer.position, newPosition, @"Should add negative offset, %@ != %@", NSStringFromPoint( NSPointFromCGPoint(contentLayer.position) ), NSStringFromPoint( NSPointFromCGPoint(newPosition) ) );
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)1.0, precision, @"Should anchor at (1.0,0.5)");
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)0.5, precision, @"Should anchor at (1.0,0.5)");

		contentLayer.anchorPoint = CGPointZero;
		contentLayer.position	 = CGPointZero;
		[label positionRelativeToViewPoint:viewPoint
							 forCoordinate:CPTCoordinateX
							   inDirection:CPTSignPositive];

		newPosition = roundPoint(CGPointMake(start + label.offset, start), contentSize, contentLayer.anchorPoint);

		STAssertEquals( contentLayer.position, newPosition, @"Should add positive offset, %@ != %@", NSStringFromPoint( NSPointFromCGPoint(contentLayer.position) ), NSStringFromPoint( NSPointFromCGPoint(newPosition) ) );
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)0.0, precision, @"Should anchor at (0.0,0.5)");
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)0.5, precision, @"Should anchor at (0.0,0.5)");
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
		CGSize contentSize	   = contentLayer.bounds.size;
		label.offset = 20.0;

		CGPoint viewPoint = CGPointMake(start, start);

		contentLayer.anchorPoint = CGPointZero;
		contentLayer.position	 = CGPointZero;
		[label positionRelativeToViewPoint:viewPoint
							 forCoordinate:CPTCoordinateY
							   inDirection:CPTSignNone];

		CGPoint newPosition = roundPoint(CGPointMake(start, start - label.offset), contentSize, contentLayer.anchorPoint);

		STAssertEquals( contentLayer.position, newPosition, @"Should add negative offset, %@ != %@", NSStringFromPoint( NSPointFromCGPoint(contentLayer.position) ), NSStringFromPoint( NSPointFromCGPoint(newPosition) ) );
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)0.5, precision, @"Should anchor at (0.5,1.0)");
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)1.0, precision, @"Should anchor at (0.5,1.0)");

		contentLayer.anchorPoint = CGPointZero;
		contentLayer.position	 = CGPointZero;
		[label positionRelativeToViewPoint:viewPoint
							 forCoordinate:CPTCoordinateY
							   inDirection:CPTSignNegative];

		newPosition = roundPoint(CGPointMake(start, start - label.offset), contentSize, contentLayer.anchorPoint);

		STAssertEquals( contentLayer.position, newPosition, @"Should add negative offset, %@ != %@", NSStringFromPoint( NSPointFromCGPoint(contentLayer.position) ), NSStringFromPoint( NSPointFromCGPoint(newPosition) ) );
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)0.5, precision, @"Should anchor at (0.5,1.0)");
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)1.0, precision, @"Should anchor at (0.5,1.0)");

		contentLayer.anchorPoint = CGPointZero;
		contentLayer.position	 = CGPointZero;
		[label positionRelativeToViewPoint:viewPoint
							 forCoordinate:CPTCoordinateY
							   inDirection:CPTSignPositive];

		newPosition = roundPoint(CGPointMake(start, start + label.offset), contentSize, contentLayer.anchorPoint);

		STAssertEquals( contentLayer.position, newPosition, @"Should add positive offset, %@ != %@", NSStringFromPoint( NSPointFromCGPoint(contentLayer.position) ), NSStringFromPoint( NSPointFromCGPoint(newPosition) ) );
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)0.5, precision, @"Should anchor at (0.5,0)");
		STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)0.0, precision, @"Should anchor at (0.5,0)");
	}
	@finally {
		[label release];
	}
}

@end
