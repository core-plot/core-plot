
#import "CPAxisLabel.h"
#import "CPTextLayer.h"
#import "CPExceptions.h"

@implementation CPAxisLabel

@synthesize text;
@synthesize contentLayer;
@synthesize offset;
@synthesize tickLocation;

-(id)initWithText:(NSString *)newText
{
    text = [newText copy];
    CPTextLayer *newLayer = [[[CPTextLayer alloc] initWithString:newText fontSize:12.f] autorelease];
    [newLayer sizeToFit];
    return [self initWithContentLayer:newLayer];
}

-(id)initWithContentLayer:(CPLayer *)layer
{
    if ( self = [super initWithFrame:layer.bounds] ) {
        contentLayer = [layer retain];
        CGRect newBounds = CGRectZero;
        newBounds.size = layer.bounds.size;
        self.bounds = newBounds;
        layer.position = CGPointZero;
        self.offset = 20.0f;
        [self addSublayer:contentLayer];
		self.layerAutoresizingMask = kCPLayerNotSizable;
    }
    return self;
}

-(void)dealloc
{
    [text release];
    [contentLayer release];
    [tickLocation release];
    [super dealloc];
}

-(void)positionRelativeToViewPoint:(CGPoint)point inDirection:(CPDirection)direction
{
    CGPoint newPosition = point;
    switch ( direction ) {
        case CPDirectionLeft:
            newPosition.x -= offset;
            break;
        case CPDirectionRight:
            newPosition.x += offset;
            break;
        case CPDirectionUp:
            newPosition.y += offset;
            break;
        case CPDirectionDown:
            newPosition.y -= offset;
            break;
        default:
            [NSException raise:CPException format:@"Invalid direction in positionRelativeToViewPoint:inDirection:"];
            break;
    }
    self.anchorPoint = CGPointZero;
    self.position = newPosition;
}

-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint inDirection:(CPDirection)direction
{
    
}

@end
