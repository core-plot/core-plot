#import "CPTLayer.h"

@class CPTAnnotation;

@interface CPTAnnotationHostLayer : CPTLayer

@property (nonatomic, readonly) NSArray *annotations;

/// @name Annotations
/// @{
-(void)addAnnotation:(CPTAnnotation *)annotation;
-(void)removeAnnotation:(CPTAnnotation *)annotation;
-(void)removeAllAnnotations;
/// @}

@end
