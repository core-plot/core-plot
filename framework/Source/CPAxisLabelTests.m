#import "CPAxisLabelTests.h"
#import "CPAxisLabel.h"
#import "CPTextStyle.h"
#import "CPFill.h"
#import "CPBorderedLayer.h"
#import "CPColor.h"
#import "CPExceptions.h"

static const double precision = 1.0e-6;

@implementation CPAxisLabelTests

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
    CPAxisLabel *label;
    
    @try {
        label = [[CPAxisLabel alloc] initWithText:@"CPAxisLabelTests-testPositionRelativeToViewPointRaisesForInvalidDirection" textStyle:[CPTextStyle textStyle]];
        
        STAssertThrowsSpecificNamed([label positionRelativeToViewPoint:CGPointZero forCoordinate:CPCoordinateX inDirection:INT_MAX], NSException, NSInvalidArgumentException, @"Should raise NSInvalidArgumentException for invalid direction (type CPSign)");
        
    }
    @finally {
        [label release];
    }
}

-(void)testPositionRelativeToViewPointPositionsForXCoordinate
{
    CPAxisLabel *label;
    CGFloat start = 100.0;
    
    @try {
        label = [[CPAxisLabel alloc] initWithText:@"CPAxisLabelTests-testPositionRelativeToViewPointPositionsForXCoordinate" textStyle:[CPTextStyle textStyle]];
		CPLayer *contentLayer = label.contentLayer;
		CGSize contentSize = contentLayer.bounds.size;
        label.offset = 20.0;
        
        CGPoint viewPoint = CGPointMake(start, start);
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateX
                               inDirection:CPSignNone];
        
		CGPoint newPosition = roundPoint(CGPointMake(start-label.offset, start), contentSize, contentLayer.anchorPoint);

        STAssertEquals(contentLayer.position, newPosition, @"Should add negative offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSPointFromCGPoint(newPosition)));
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)1.0, precision, @"Should anchor at (1.0,0.5)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)0.5, precision, @"Should anchor at (1.0,0.5)");
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateX
                               inDirection:CPSignNegative];
        
		newPosition = roundPoint(CGPointMake(start-label.offset, start), contentSize, contentLayer.anchorPoint);

        STAssertEquals(contentLayer.position, newPosition, @"Should add negative offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSPointFromCGPoint(newPosition)));
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)1.0, precision, @"Should anchor at (1.0,0.5)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)0.5, precision, @"Should anchor at (1.0,0.5)");
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateX
                               inDirection:CPSignPositive];
        
		newPosition = roundPoint(CGPointMake(start+label.offset, start), contentSize, contentLayer.anchorPoint);

        STAssertEquals(contentLayer.position, newPosition, @"Should add positive offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSPointFromCGPoint(newPosition)));
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)0.0, precision, @"Should anchor at (0.0,0.5)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)0.5, precision, @"Should anchor at (0.0,0.5)");
    }
    @finally {
        [label release];
    }
}

-(void)testPositionRelativeToViewPointPositionsForYCoordinate
{
    CPAxisLabel *label;
    CGFloat start = 100.0;
    
    @try {
        label = [[CPAxisLabel alloc] initWithText:@"CPAxisLabelTests-testPositionRelativeToViewPointPositionsForYCoordinate" textStyle:[CPTextStyle textStyle]];
		CPLayer *contentLayer = label.contentLayer;
		CGSize contentSize = contentLayer.bounds.size;
		label.offset = 20.0;
        
        CGPoint viewPoint = CGPointMake(start,start);
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateY
                               inDirection:CPSignNone];
		
		CGPoint newPosition = roundPoint(CGPointMake(start, start-label.offset), contentSize, contentLayer.anchorPoint);

        STAssertEquals(contentLayer.position, newPosition, @"Should add negative offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSPointFromCGPoint(newPosition)));
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)0.5, precision, @"Should anchor at (0.5,1.0)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)1.0, precision, @"Should anchor at (0.5,1.0)");
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateY
                               inDirection:CPSignNegative];
        
		newPosition = roundPoint(CGPointMake(start, start-label.offset), contentSize, contentLayer.anchorPoint);

        STAssertEquals(contentLayer.position, newPosition, @"Should add negative offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSPointFromCGPoint(newPosition)));
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)0.5, precision, @"Should anchor at (0.5,1.0)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)1.0, precision, @"Should anchor at (0.5,1.0)");
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateY
                               inDirection:CPSignPositive];
        
		newPosition = roundPoint(CGPointMake(start, start+label.offset), contentSize, contentLayer.anchorPoint);

        STAssertEquals(contentLayer.position, newPosition, @"Should add positive offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSPointFromCGPoint(newPosition)));
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.x, (CGFloat)0.5, precision, @"Should anchor at (0.5,0)");
        STAssertEqualsWithAccuracy(contentLayer.anchorPoint.y, (CGFloat)0.0, precision, @"Should anchor at (0.5,0)");
    }
    @finally {
        [label release];
    }
}
@end
