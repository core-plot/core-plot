
#import "CPAnnotationLayer.h"
#import "CPAnnotation.h"

@implementation CPAnnotationLayer

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
    annotation.annotationLayer = self;
}

-(void)removeAnnotation:(CPAnnotation *)annotation
{
    annotation.annotationLayer = nil;
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

@end
