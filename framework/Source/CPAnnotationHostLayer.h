#import "CPLayer.h"

@class CPAnnotation;

@interface CPAnnotationHostLayer : CPLayer {
	@private
	NSMutableArray *mutableAnnotations;
}

@property (nonatomic, readonly, retain) NSArray *annotations;

-(void)addAnnotation:(CPAnnotation *)annotation;
-(void)removeAnnotation:(CPAnnotation *)annotation;
-(void)removeAllAnnotations;

@end
