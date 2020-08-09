#import "CPTDefinitions.h"
#import "CPTGraph.h"

@interface CPTXYGraph : CPTGraph

/// @name Initialization
/// @{
-(nonnull instancetype)initWithFrame:(CGRect)newFrame xScaleType:(CPTScaleType)newXScaleType yScaleType:(CPTScaleType)newYScaleType;
/// @}

@end
