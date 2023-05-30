/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTAnnotation.h>
#import <CorePlot/CPTLayer.h>
#else
#import "CPTAnnotation.h"
#import "CPTLayer.h"
#endif

@interface CPTAnnotationHostLayer : CPTLayer

@property (nonatomic, readonly, nonnull) CPTAnnotationArray *annotations;

/// @name Annotations
/// @{
-(void)addAnnotation:(nullable CPTAnnotation *)annotation;
-(void)removeAnnotation:(nullable CPTAnnotation *)annotation;
-(void)removeAllAnnotations;
/// @}

@end
