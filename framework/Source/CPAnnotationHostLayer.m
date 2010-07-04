#import "CPAnnotationHostLayer.h"
#import "CPAnnotation.h"
#import "CPExceptions.h"

///	@cond
@interface CPAnnotationHostLayer()

@property (nonatomic, readwrite, retain) NSMutableArray *mutableAnnotations;

@end
///	@endcond

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

@synthesize mutableAnnotations;

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
    return [[self.mutableAnnotations copy] autorelease];
}

/**	@brief Adds an annotation to the receiver.
 **/
-(void)addAnnotation:(CPAnnotation *)annotation 
{
	if ( annotation ) {
		[self.mutableAnnotations addObject:annotation];
		annotation.annotationHostLayer = self;
	}
}

/**	@brief Removes an annotation from the receiver.
 **/
-(void)removeAnnotation:(CPAnnotation *)annotation
{
    if ( [self.mutableAnnotations containsObject:annotation] ) {
		annotation.annotationHostLayer = nil;
		[self.mutableAnnotations removeObject:annotation];
    }
    else {
        [NSException raise:CPException format:@"Tried to remove CPAnnotation from %@. Host layer was %@.", self, annotation.annotationHostLayer];
    }
}

#pragma mark -
#pragma mark Layout

-(NSSet *)sublayersExcludedFromAutomaticLayout 
{
	NSMutableSet *layers = [NSMutableSet set];
    for ( CPAnnotation *annotation in self.mutableAnnotations ) {
        [layers addObject:annotation.contentLayer];
    }
    return layers;
}

-(void)layoutSublayers
{
    [super layoutSublayers];
    for ( CPAnnotation *annotation in self.mutableAnnotations ) {
    	[annotation positionContentLayer];
	}
}

@end
