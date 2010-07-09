#import "CPAxisTitle.h"
#import "CPExceptions.h"
#import "CPLayer.h"

/**	@brief An axis title.
 *
 *	The title can be text-based or can be the content of any CPLayer provided by the user.
 **/
@implementation CPAxisTitle

-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction
{
	CGPoint newPosition = point;
	CGFloat *value = (coordinate == CPCoordinateX ? &(newPosition.x) : &(newPosition.y));
	self.rotation = (coordinate == CPCoordinateX ? M_PI_2 : 0.0);
	CGPoint anchor = CGPointZero;
    
    // Position the anchor point along the closest edge.
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
	
	// Pixel-align the title layer to prevent blurriness
	CPLayer *content = self.contentLayer;
	CGSize currentSize = content.bounds.size;
	
	content.anchorPoint = anchor;

	if ( self.rotation == 0.0 ) {
		newPosition.x = round(newPosition.x) - round(currentSize.width * anchor.x) + (currentSize.width * anchor.x);
		newPosition.y = round(newPosition.y) - round(currentSize.height * anchor.y) + (currentSize.height * anchor.y);
	}
	else {
		newPosition.x = round(newPosition.x);
		newPosition.y = round(newPosition.y);
	}
	content.position = newPosition;
    content.transform = CATransform3DMakeRotation(self.rotation, 0.0, 0.0, 1.0);
    
    [self.contentLayer setNeedsDisplay];
}

@end
