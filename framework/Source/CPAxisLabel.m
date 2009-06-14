
#import "CPAxisLabel.h"
#import "CPTextLayer.h"
#import "CPExceptions.h"

@interface CPAxisLabel()

@property (nonatomic, readwrite, copy) NSString *text;
@property (nonatomic, readwrite, retain) CPLayer *contentLayer;

@end

@implementation CPAxisLabel

@synthesize text;
@synthesize contentLayer;
@synthesize offset;
@synthesize tickLocation;

-(id)initWithText:(NSString *)newText
{
	self.text = newText;
	CPTextLayer *newLayer = [[[CPTextLayer alloc] initWithString:newText fontSize:12.f] autorelease];
	[newLayer sizeToFit];
	return [self initWithContentLayer:newLayer];
}

-(id)initWithContentLayer:(CPLayer *)layer
{
    if ( self = [super initWithFrame:layer.bounds] ) {
        self.contentLayer = layer;
        CGRect newBounds = CGRectZero;
        newBounds.size = layer.bounds.size;
        self.bounds = newBounds;
        layer.position = CGPointZero;
        self.offset = 20.0f;
        [self addSublayer:self.contentLayer];
		self.layerAutoresizingMask = kCPLayerNotSizable;
    }
    return self;
}

-(void)dealloc
{
	self.text = nil;
	self.contentLayer = nil;
	self.tickLocation = nil;
	[super dealloc];
}

-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction
{
	CGPoint newPosition = point;
	CGFloat *value = (coordinate == CPCoordinateX ? &(newPosition.x) : &(newPosition.y));
	switch ( direction ) {
		case CPSignNegative:
		case CPSignNone:
			*value -= offset;
			break;
		case CPSignPositive:
			*value += offset;
			break;
		default:
			[NSException raise:CPException format:@"Invalid sign in positionRelativeToViewPoint:inDirection:"];
			break;
	}
	self.anchorPoint = CGPointZero;
	self.position = newPosition;
}

-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPCoordinate)coordiante inDirection:(CPSign)direction
{
	// TODO: Write implementation for positioning label between ticks
}

@end
