
#import "CPAnnotation.h"
#import "CPLayer.h"
#import "CPAnnotationLayer.h"


@implementation CPAnnotation

@synthesize contentLayer;
@synthesize annotationLayer;
@synthesize displacement;

-(id)initWithAnnotationLayer:(CPLayer *)newAnnotationLayer
{
    if ( self = [super init] ) {
    	annotationLayer = [newAnnotationLayer retain];
        displacement = CGPointZero;
    }
    return self;
}

-(void)dealloc
{
	self.contentLayer = nil;
    [annotationLayer release];
    [super dealloc];
}

-(void)setContentLayer:(CPLayer *)newLayer 
{
    if ( newLayer != contentLayer ) {
    	[contentLayer removeFromSuperlayer];
        [contentLayer release];
        contentLayer = [newLayer retain];
        [annotationLayer addSublayer:contentLayer];
        [self positionContentLayer];
    }
}

-(void)setAnnotationLayer:(CPAnnotationLayer *)newLayer 
{
    if ( newLayer != annotationLayer ) {
    	[contentLayer removeFromSuperlayer];
        [annotationLayer release];
        annotationLayer = [newLayer retain];
        [annotationLayer addSublayer:contentLayer];
        [self positionContentLayer];
    }
}

-(void)setDisplacement:(CGPoint)newDisplacement
{
    if ( !CGPointEqualToPoint(newDisplacement, displacement) ) {
        displacement = newDisplacement;
        [self positionContentLayer];
    }
}

-(void)positionContentLayer
{
}

@end
