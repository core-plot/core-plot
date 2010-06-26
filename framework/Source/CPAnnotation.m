#import "CPAnnotation.h"
#import "CPLayer.h"
#import "CPAnnotationHostLayer.h"

/**	@brief An annotation positions a content layer relative to some anchor point.
 *
 *	Annotations can be used to add text or images that are anchored to a feature
 *	of a graph. For example, the graph title is an annotation anchored to the 
 *	plot area frame.
 *
 *	@todo More documentation needed 
 **/
@implementation CPAnnotation

/**	@property contentLayer
 *	@brief The annotation content.
 **/
@synthesize contentLayer;

/**	@property annotationHostLayer
 *	@brief The host layer for the annotation content.
 **/
@synthesize annotationHostLayer;

/**	@property displacement
 *	@brief The displacement from the layer anchor point.
 **/
@synthesize displacement;

#pragma mark -
#pragma mark Init/Dealloc

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

#pragma mark -
#pragma mark Accessors

-(void)setContentLayer:(CPLayer *)newLayer 
{
    if ( newLayer != contentLayer ) {
    	[contentLayer removeFromSuperlayer];
        [contentLayer release];
        contentLayer = [newLayer retain];
		if ( contentLayer ) {
			[annotationHostLayer addSublayer:contentLayer];
			[self positionContentLayer];
		}
    }
}

-(void)setAnnotationHostLayer:(CPAnnotationHostLayer *)newLayer 
{
    if ( newLayer != annotationHostLayer ) {
    	[contentLayer removeFromSuperlayer];
        [annotationHostLayer release];
        annotationHostLayer = [newLayer retain];
		if ( contentLayer ) {
			[annotationHostLayer addSublayer:contentLayer];
			[self positionContentLayer];
		}
    }
}

-(void)setDisplacement:(CGPoint)newDisplacement
{
    if ( !CGPointEqualToPoint(newDisplacement, displacement) ) {
        displacement = newDisplacement;
        [self positionContentLayer];
    }
}

@end

#pragma mark -
#pragma mark Layout

@implementation CPAnnotation(AbstractMethods)

/**	@brief Positions the content layer relative to its reference anchor.
 *
 *	This method must be overridden by subclasses. The default implementation
 *	does nothing.
 **/
-(void)positionContentLayer
{
	// Do nothing--implementation provided by subclasses
}

@end
