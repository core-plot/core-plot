
#import "CPAxisLabel.h"
#import "CPLayer.h"
#import "CPTextLayer.h"
#import "CPTextStyle.h"
#import "CPExceptions.h"
#import "CPUtilities.h"

///	@cond
@interface CPAxisLabel()

@property (nonatomic, readwrite, retain) CPLayer *contentLayer;

@end
///	@endcond

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
	CPTextLayer *newLayer = [[[CPTextLayer alloc] initWithText:newText] autorelease];
	newLayer.textStyle = newStyle;
	[newLayer sizeToFit];
	return [self initWithContentLayer:newLayer];
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
			offset = 20.0f;
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
 *	@param point The view point.
 *	@param coordinate The axis coordinate.
 *	@param direction The offset direction.
 **/
-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction
{
	CGPoint newPosition = point;
	CGFloat *value = (coordinate == CPCoordinateX ? &(newPosition.x) : &(newPosition.y));
	CGPoint anchor = CGPointZero;

	switch ( direction ) {
		case CPSignNone:
		case CPSignNegative:
			*value -= offset;
			anchor = (coordinate == CPCoordinateX ? CGPointMake(1.0, 0.5) : CGPointMake(0.5, 1.0));
			break;
		case CPSignPositive:
			*value += offset;
			anchor = (coordinate == CPCoordinateX ? CGPointMake(0.0, 0.5) : CGPointMake(0.5, 0.0));
			break;
		default:
			[NSException raise:CPException format:@"Invalid sign in positionRelativeToViewPoint:inDirection:"];
			break;
	}
	
	// Pixel-align the label layer to prevent blurriness
	CGSize currentSize = self.contentLayer.bounds.size;
	newPosition.x = round(newPosition.x - (currentSize.width * anchor.x)) + floor(currentSize.width * anchor.x);
	newPosition.y = round(newPosition.y - (currentSize.height * anchor.y)) + floor(currentSize.height * anchor.y);
	
	self.contentLayer.anchorPoint = anchor;
	self.contentLayer.position = newPosition;
	[self.contentLayer setNeedsDisplay];
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
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	// nothing to draw
}

@end
