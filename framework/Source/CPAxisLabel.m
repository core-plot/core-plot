
#import "CPAxisLabel.h"
#import "CPTextLayer.h"
#import "CPExceptions.h"
#import "CPLineStyle.h"

@interface CPAxisLabel()

@property (nonatomic, readwrite, copy) NSString *text;
@property (nonatomic, readwrite, retain) CPLayer *contentLayer;

@end

@implementation CPAxisLabel

@synthesize text;
@synthesize textStyle;
@synthesize contentLayer;
@synthesize offset;
@synthesize tickLocation;

-(id)initWithText:(NSString *)newText textStyle:(CPTextStyle *)newStyle
{
	self.text = newText;
	CPTextLayer *newLayer = [[[CPTextLayer alloc] initWithText:newText] autorelease];
	newLayer.textStyle = newStyle;
	[newLayer sizeToFit];
	return [self initWithContentLayer:newLayer];
}

-(id)initWithContentLayer:(CPLayer *)layer
{
    if ( self = [super initWithFrame:layer.bounds] ) {
        self.contentLayer = layer;
        CGRect newBounds = CGRectZero;
        newBounds.size = layer.frame.size;
        self.bounds = newBounds;
        layer.position = CGPointZero;
        self.offset = 20.0f;
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self addSublayer:self.contentLayer];
		[CATransaction commit];
    }
    return self;
}

-(void)dealloc
{
	self.text = nil;
	self.textStyle = nil;
	self.contentLayer = nil;
	self.tickLocation = nil;
	[super dealloc];
}

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
	self.anchorPoint = anchor;
	self.position = newPosition;
}

-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPCoordinate)coordiante inDirection:(CPSign)direction
{
	// TODO: Write implementation for positioning label between ticks
	[NSException raise:CPException format:@"positionBetweenViewPoint:andViewPoint:forCoordinate:inDirection: not implemented"];
}

@end
