
#import "CPAnnotation.h"
#import "CPLayer.h"
#import "CPAnnotationHostLayer.h"

/** @brief An annotation positions a content layer relative to some anchor point
 *
 *  Annotations can be used to add text or images that are anchored to a feature
 *  of a graph. For example, the graph title is an annotation anchored to the 
 *  plot area frame.
 *
 * @todo More documentation needed 
 **/
 
@implementation CPAnnotation

@synthesize contentLayer;
@synthesize annotationHostLayer;
@synthesize displacement;

-(id)init
{
    if ( self = [super init] ) {
        displacement = CGPointZero;
    }
    return self;
}

-(void)dealloc
{
	self.contentLayer = nil;
    [annotationHostLayer release];
    [super dealloc];
}

-(void)setContentLayer:(CPLayer *)newLayer 
{
    if ( newLayer != contentLayer ) {
    	[contentLayer removeFromSuperlayer];
        [contentLayer release];
        contentLayer = [newLayer retain];
        [annotationHostLayer addSublayer:contentLayer];
        [self positionContentLayer];
    }
}

-(void)setAnnotationHostLayer:(CPAnnotationHostLayer *)newLayer 
{
    if ( newLayer != annotationHostLayer ) {
    	[contentLayer removeFromSuperlayer];
        [annotationHostLayer release];
        annotationHostLayer = [newLayer retain];
        [annotationHostLayer addSublayer:contentLayer];
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
