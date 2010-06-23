
#import "CPBorderedLayer.h"

///	@file

@class CPAnnotation;

@interface CPAnnotationHostLayer : CPBorderedLayer {
	NSMutableArray *mutableAnnotations;
}

@property (readonly) NSArray *annotations;

-(void)addAnnotation:(CPAnnotation *)annotation;
-(void)removeAnnotation:(CPAnnotation *)annotation;

@end
