#import "CPAnnotationHostLayer.h"
#import "CPAnnotation.h"

/**	@brief An annotation host layer is a container layer for annotations.
 *
 *	Annotations can be added to and removed from an annotation layer.
 *
 *	@todo More documentation needed 
 **/
@implementation CPAnnotationHostLayer

/**	@property annotations
 *	@brief An array of annotations attached to this layer.
 **/
@dynamic annotations;

#pragma mark -
#pragma mark Init/Dealloc

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

#pragma mark -
#pragma mark Annotations

-(NSArray *)annotations
{
    return [[mutableAnnotations copy] autorelease];
}

/**	@brief Adds an annotation to the receiver.
 **/
-(void)addAnnotation:(CPAnnotation *)annotation 
{
	if ( annotation ) {
		[mutableAnnotations addObject:annotation];
		annotation.annotationHostLayer = self;
	}
}

/**	@brief Removes an annotation from the receiver.
 **/
-(void)removeAnnotation:(CPAnnotation *)annotation
{
	if ( annotation ) {
		annotation.annotationHostLayer = nil;
		[mutableAnnotations removeObject:annotation];
	}
}

#pragma mark -
#pragma mark Layout

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
