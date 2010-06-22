
#import "CPBorderedLayer.h"

@class CPAnnotation;

@interface CPAnnotationLayer : CPBorderedLayer {
	NSMutableArray *mutableAnnotations;
}

@property (readonly) NSArray *annotations;

-(void)addAnnotation:(CPAnnotation *)annotation;
-(void)removeAnnotation:(CPAnnotation *)annotation;

@end
