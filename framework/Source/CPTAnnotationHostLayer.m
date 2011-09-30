#import "CPTAnnotation.h"
#import "CPTAnnotationHostLayer.h"
#import "CPTExceptions.h"

/**	@cond */
@interface CPTAnnotationHostLayer()

@property (nonatomic, readwrite, retain) NSMutableArray *mutableAnnotations;

@end

/**	@endcond */

#pragma mark -

/**	@brief An annotation host layer is a container layer for annotations.
 *
 *	Annotations can be added to and removed from an annotation layer.
 *
 *	@todo More documentation needed.
 **/
@implementation CPTAnnotationHostLayer

/**	@property annotations
 *	@brief An array of annotations attached to this layer.
 **/
@dynamic annotations;

@synthesize mutableAnnotations;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		mutableAnnotations = [[NSMutableArray alloc] init];
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTAnnotationHostLayer *theLayer = (CPTAnnotationHostLayer *)layer;

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
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.mutableAnnotations forKey:@"CPTAnnotationHostLayer.mutableAnnotations"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		mutableAnnotations = [[coder decodeObjectForKey:@"CPTAnnotationHostLayer.mutableAnnotations"] mutableCopy];
	}
	return self;
}

#pragma mark -
#pragma mark Annotations

-(NSArray *)annotations
{
	return [[self.mutableAnnotations copy] autorelease];
}

/**	@brief Adds an annotation to the receiver.
 **/
-(void)addAnnotation:(CPTAnnotation *)annotation
{
	if ( annotation ) {
		[self.mutableAnnotations addObject:annotation];
		annotation.annotationHostLayer = self;
		[annotation positionContentLayer];
	}
}

/**	@brief Removes an annotation from the receiver.
 **/
-(void)removeAnnotation:(CPTAnnotation *)annotation
{
	if ( [self.mutableAnnotations containsObject:annotation] ) {
		annotation.annotationHostLayer = nil;
		[self.mutableAnnotations removeObject:annotation];
	}
	else {
		[NSException raise:CPTException format:@"Tried to remove CPTAnnotation from %@. Host layer was %@.", self, annotation.annotationHostLayer];
	}
}

/**	@brief Removes all annotations from the receiver.
 **/
-(void)removeAllAnnotations
{
	NSMutableArray *allAnnotations = self.mutableAnnotations;

	for ( CPTAnnotation *annotation in allAnnotations ) {
		annotation.annotationHostLayer = nil;
	}
	[allAnnotations removeAllObjects];
}

#pragma mark -
#pragma mark Layout

-(NSSet *)sublayersExcludedFromAutomaticLayout
{
	NSMutableSet *layers = [NSMutableSet set];

	for ( CPTAnnotation *annotation in self.mutableAnnotations ) {
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
