#import "CPBorderedLayer.h"

@class CPAnnotation;

@interface CPAnnotationHostLayer : CPBorderedLayer {
@private
	NSMutableArray *mutableAnnotations;
}

@property (nonatomic, readonly, retain) NSArray *annotations;

-(void)addAnnotation:(CPAnnotation *)annotation;
-(void)removeAnnotation:(CPAnnotation *)annotation;

@end
