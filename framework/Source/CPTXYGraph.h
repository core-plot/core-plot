/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTDefinitions.h>
#import <CorePlot/CPTGraph.h>
#else
#import "CPTDefinitions.h"
#import "CPTGraph.h"
#endif

@interface CPTXYGraph : CPTGraph

/// @name Initialization
/// @{
-(nonnull instancetype)initWithFrame:(CGRect)newFrame xScaleType:(CPTScaleType)newXScaleType yScaleType:(CPTScaleType)newYScaleType;
/// @}

@end
