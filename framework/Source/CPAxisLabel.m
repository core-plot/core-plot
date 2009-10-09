
#import "CPAxisLabel.h"
#import "CPTextLayer.h"
#import "CPExceptions.h"
#import "CPLineStyle.h"

///	@cond
@interface CPAxisLabel()

@property (nonatomic, readwrite, copy) NSString *text;
@property (nonatomic, readwrite, retain) CPLayer *contentLayer;

@end
///	@endcond

/**	@brief An axis label.
 *
 *	The label can be text-based or can be the content of any CPLayer provided by the user.
 **/
@implementation CPAxisLabel

/**	@property text
 *	@brief The label text for a text-based label.
 **/
@synthesize text;

/**	@property textStyle
 *	@brief The text style for a text-based label.
 **/
@synthesize textStyle;

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

/** @brief Initializes a newly allocated text-based CPAxisLabel object with the provided text and style.
 *
 *	@param newText The label text.
 *	@param newStyle The text style for the label.
 *  @return The initialized CPAxisLabel object.
 **/
-(id)initWithText:(NSString *)newText textStyle:(CPTextStyle *)newStyle
{
	self.text = newText;
	CPTextLayer *newLayer = [[[CPTextLayer alloc] initWithText:newText] autorelease];
	newLayer.textStyle = newStyle;
	[newLayer sizeToFit];
	return [self initWithContentLayer:newLayer];
}

/** @brief Initializes a newly allocated CPAxisLabel object with the provided layer.
 *
 *	@param layer The label content.
 *  @return The initialized CPAxisLabel object.
 **/
-(id)initWithContentLayer:(CPLayer *)layer
{
    if ( self = [super initWithFrame:layer.bounds] ) {
        self.contentLayer = layer;
        CGRect newBounds = CGRectZero;
        newBounds.size = layer.frame.size;
        self.bounds = newBounds;
        layer.position = CGPointZero;
        self.offset = 20.0f;
        [self addSublayer:self.contentLayer];
    }
    return self;
}

-(void)dealloc
{
	self.text = nil;
	self.textStyle = nil;
	self.contentLayer = nil;
	[super dealloc];
}

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
	CGSize currentSize = self.bounds.size;
	newPosition.x = round(newPosition.x - (currentSize.width * anchor.x)) + floor(currentSize.width * anchor.x);
	newPosition.y = round(newPosition.y - (currentSize.height * anchor.y)) + floor(currentSize.height * anchor.y);
	
	self.anchorPoint = anchor;
	self.position = newPosition;
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

@end
