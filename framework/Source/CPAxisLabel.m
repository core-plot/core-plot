
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
	self.contentLayer = nil;
	self.tickLocation = nil;
	[super dealloc];
}

-(void)positionRelativeToViewPoint:(CGPoint)point inDirection:(CPDirection)direction
{
	CGPoint newPosition = point;
	CGPoint anchor = CGPointZero;
	switch ( direction ) {
		case CPDirectionLeft:
			newPosition.x -= self.offset;
			anchor = CGPointMake(1.0, 0.5);
			break;
		case CPDirectionRight:
			newPosition.x += self.offset;
			anchor = CGPointMake(0.0, 0.5);
			break;
		case CPDirectionUp:
			newPosition.y += self.offset;
			anchor = CGPointMake(0.5, 0.0);
			break;
		case CPDirectionDown:
			newPosition.y -= self.offset;
			anchor = CGPointMake(0.5, 1.0);
			break;
		default:
			[NSException raise:CPException format:@"Invalid direction in positionRelativeToViewPoint:inDirection:"];
			break;
	}
	self.anchorPoint = anchor;
	self.position = newPosition;
}

-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint inDirection:(CPDirection)direction
{
	// TODO: implement positionBetweenViewPoint:andViewPoint:inDirection:
	[NSException raise:CPException format:@"positionBetweenViewPoint:andViewPoint:inDirection: not implemented"];
}

@end
