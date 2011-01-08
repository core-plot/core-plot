#import "CPAnnotationHostLayer.h"
#import "CPAnnotation.h"
#import "CPExceptions.h"

///	@cond
@interface CPAnnotationHostLayer()

@property (nonatomic, readwrite, retain) NSMutableArray *mutableAnnotations;

@end
///	@endcond

#pragma mark -

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

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPAnnotationHostLayer *theLayer = (CPAnnotationHostLayer *)layer;
		
		mutableAnnotations = [theLayer->mutableAnnotations retain];
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
        [annotation positionContentLayer];
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

/**	@brief Removes all annotations from the receiver.
 **/
-(void)removeAllAnnotations
{
	NSMutableArray *allAnnotations = self.mutableAnnotations;
	for ( CPAnnotation *annotation in allAnnotations ) {
		annotation.annotationHostLayer = nil;
	}
	[allAnnotations removeAllObjects];
}

#pragma mark -
#pragma mark Layout

-(NSSet *)sublayersExcludedFromAutomaticLayout 
{
	NSMutableSet *layers = [NSMutableSet set];
    for ( CPAnnotation *annotation in self.mutableAnnotations ) {
		CALayer *content = annotation.contentLayer;
		if ( content ) {
			[layers addObject:content];
		}
    }
    return layers;
}

-(void)layoutSublayers
{
    [super layoutSublayers];
	[self.mutableAnnotations makeObjectsPerformSelector:@selector(positionContentLayer)];
}

@end
