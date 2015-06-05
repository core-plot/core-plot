#import "CPTLayer.h"

@class CPTAnnotation;

@interface CPTAnnotationHostLayer : CPTLayer

@property (nonatomic, readonly, nonnull) NSArray *annotations;

/// @name Annotations
/// @{
-(void)addAnnotation:(nullable CPTAnnotation *)annotation;
-(void)removeAnnotation:(nullable CPTAnnotation *)annotation;
-(void)removeAllAnnotations;
/// @}

@end
