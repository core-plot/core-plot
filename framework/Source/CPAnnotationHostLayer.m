
#import "CPAnnotationHostLayer.h"
#import "CPAnnotation.h"

/** @brief An annotation host layer is a container layer for annotations
 *
 *  Annotations can be added to and removed from an annotation layer.
 *
 * @todo More documentation needed 
 **/

@implementation CPAnnotationHostLayer

-(id)initWithFrame:(CGRect)newFrame
{
    if ( self = [super initWithFrame:newFrame] ) {
        mutableAnnotations = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [mutableAnnotations release];
    [super dealloc];
}

-(NSArray *)annotations
{
    return [[mutableAnnotations copy] autorelease];
}

-(void)addAnnotation:(CPAnnotation *)annotation 
{
    [mutableAnnotations addObject:annotation];
    annotation.annotationHostLayer = self;
}

-(void)removeAnnotation:(CPAnnotation *)annotation
{
    annotation.annotationHostLayer = nil;
    [mutableAnnotations removeObject:annotation];
}

-(NSSet *)sublayersExcludedFromAutomaticLayout 
{
	NSMutableSet *layers = [NSMutableSet set];
    for ( CPAnnotation *annotation in mutableAnnotations ) {
        [layers addObject:annotation.contentLayer];
    }
    return layers;
}

-(void)layoutSublayers
{
    [super layoutSublayers];
    for ( CPAnnotation *annotation in mutableAnnotations ) {
    	[annotation positionContentLayer];
	}
}

@end
