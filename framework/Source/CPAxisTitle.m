#import "CPAxisTitle.h"
#import "CPTextLayer.h"
#import "CPExceptions.h"

@implementation CPAxisTitle

-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction
{
	CGPoint newPosition = point;
	CGFloat *value = (coordinate == CPCoordinateX ? &(newPosition.x) : &(newPosition.y));
	self.rotation = (coordinate == CPCoordinateX ? (M_PI / 2.0) : 0.0);
	CGPoint anchor = CGPointZero;
    
    // If there is no rotation, position the anchor point along the closest edge.
    // If there is rotation, leave the anchor in the center.
    switch ( direction ) {
        case CPSignNone:
        case CPSignNegative:
            *value -= self.offset;
			anchor = (coordinate == CPCoordinateX ? CGPointMake(0.5, 0.0) : CGPointMake(0.5, 1.0));
            break;
        case CPSignPositive:
            *value += self.offset;
			anchor = (coordinate == CPCoordinateX ? CGPointMake(0.0, 0.5) : CGPointMake(0.5, 0.0));
            break;
        default:
            [NSException raise:CPException format:@"Invalid sign in positionRelativeToViewPoint:inDirection:"];
            break;
    }
	
	// Pixel-align the label layer to prevent blurriness
	CGSize currentSize = self.contentLayer.bounds.size;
	newPosition.x = round(newPosition.x - (currentSize.width * anchor.x)) + currentSize.width * anchor.x;
	newPosition.y = round(newPosition.y - (currentSize.height * anchor.y)) + currentSize.height * anchor.y;
	
    self.contentLayer.anchorPoint = anchor;
	self.contentLayer.position = newPosition;
    self.contentLayer.transform = CATransform3DMakeRotation(self.rotation, 0.0f, 0.0f, 1.0f);
	[self.contentLayer setNeedsDisplay];
}

@end
