
#import "CPAxisLabel.h"
#import "CPLayer.h"
#import "CPTextLayer.h"
#import "CPTextStyle.h"
#import "CPExceptions.h"
#import "CPUtilities.h"

/**	@brief An axis label.
 *
 *	The label can be text-based or can be the content of any CPLayer provided by the user.
 **/
@implementation CPAxisLabel

/**	@property contentLayer
 *	@brief The label content.
 **/
@synthesize contentLayer;

/**	@property offset
 *	@brief The offset distance between the axis and label.
 **/
@synthesize offset;

/**	@property rotation
 *	@brief The rotation of the label in radians.
 **/
@synthesize rotation;

/**	@property tickLocation
 *	@brief The data coordinate of the ticklocation.
 **/
@synthesize tickLocation;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated text-based CPAxisLabel object with the provided text and style.
 *
 *	@param newText The label text.
 *	@param newStyle The text style for the label.
 *  @return The initialized CPAxisLabel object.
 **/
-(id)initWithText:(NSString *)newText textStyle:(CPTextStyle *)newStyle
{
	CPTextLayer *newLayer = [[CPTextLayer alloc] initWithText:newText];
	newLayer.textStyle = newStyle;
	[newLayer sizeToFit];
	self = [self initWithContentLayer:newLayer];
	[newLayer release];
	
	return self;
}

/** @brief Initializes a newly allocated CPAxisLabel object with the provided layer. This is the designated initializer.
 *
 *	@param layer The label content.
 *  @return The initialized CPAxisLabel object.
 **/
-(id)initWithContentLayer:(CPLayer *)layer
{
	if ( layer ) {
		if ( self = [super init] ) {
			contentLayer = [layer retain];
			offset = 20.0;
            rotation = 0.0;
			tickLocation = CPDecimalFromInt(0);
		}
	}
	else {
		[self release];
		self = nil;
	}
    return self;
}

-(void)dealloc
{
	[contentLayer release];
	[super dealloc];
}

#pragma mark -
#pragma mark Layout

/**	@brief Positions the axis label relative to the given point.
 *  The algorithm for positioning is different when the rotation property is non-zero.
 *  When zero, the anchor point is positioned along the closest side of the label.
 *  When non-zero, the anchor point is left at the center. This has consequences for 
 *  the value taken by the offset.
 *	@param point The view point.
 *	@param coordinate The coordinate in which the label is being position. Orthogonal to axis coordinate.
 *	@param direction The offset direction.
 **/
-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction
{
	CGPoint newPosition = point;
	CGFloat *value = (coordinate == CPCoordinateX ? &(newPosition.x) : &(newPosition.y));
	CGPoint anchor = CGPointZero;
    
    // If there is no rotation, position the anchor point along the closest edge.
    // If there is rotation, leave the anchor in the center.
    switch ( direction ) {
        case CPSignNone:
        case CPSignNegative:
            *value -= self.offset;
			if ( self.rotation == 0.0 ) {
				anchor = (coordinate == CPCoordinateX ? CGPointMake(1.0, 0.5) : CGPointMake(0.5, 1.0));
			}
			else {
				anchor = (coordinate == CPCoordinateX ? CGPointMake(1.0, 0.5) : CGPointMake(1.0, 0.5));
			}
            break;
        case CPSignPositive:
            *value += offset;
			if ( self.rotation == 0.0 ) {
				anchor = (coordinate == CPCoordinateX ? CGPointMake(0.0, 0.5) : CGPointMake(0.5, 0.0));
			}
			else {
				anchor = (coordinate == CPCoordinateX ? CGPointMake(0.0, 0.5) : CGPointMake(0.0, 0.5));
			}
            break;
        default:
            [NSException raise:CPException format:@"Invalid sign in positionRelativeToViewPoint:inDirection:"];
            break;
    }
	
	// Pixel-align the label layer to prevent blurriness
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
	[content setNeedsDisplay];
}

/**	@brief Positions the axis label between two given points.
 *	@param firstPoint The first view point.
 *	@param secondPoint The second view point.
 *	@param coordinate The axis coordinate.
 *	@param direction The offset direction.
 *	@note Not implemented.
 *	@todo Write implementation for positioning label between ticks.
 **/
-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction
{
	// TODO: Write implementation for positioning label between ticks
	[NSException raise:CPException format:@"positionBetweenViewPoint:andViewPoint:forCoordinate:inDirection: not implemented"];
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@ {%@}>", [super description], self.contentLayer];
};

#pragma mark -
#pragma mark Label comparison

// Axis labels are equal if they have the same location
-(BOOL)isEqual:(id)object
{
	if ( self == object ) {
		return YES;
	}
	else if ( [object isKindOfClass:[self class]] ) {
		return CPDecimalEquals(self.tickLocation, ((CPAxisLabel *)object).tickLocation);
	}
	else {
		return NO;
	}
}

-(NSUInteger)hash
{
	NSUInteger hashValue = 0;
	
	// Equal objects must hash the same.
	double tickLocationAsDouble = CPDecimalDoubleValue(self.tickLocation);
	if ( !isnan(tickLocationAsDouble) ) {
		hashValue = (NSUInteger)fmod(ABS(tickLocationAsDouble), (double)NSUIntegerMax);
	}
	
	return hashValue;
}

@end
