#import "CPTDefinitions.h"
#import "CPTGraph.h"

@interface CPTXYGraph : CPTGraph

/// @name Initialization
/// @{
-(instancetype)initWithFrame:(CGRect)newFrame xScaleType:(CPTScaleType)newXScaleType yScaleType:(CPTScaleType)newYScaleType;
/// @}

@end
