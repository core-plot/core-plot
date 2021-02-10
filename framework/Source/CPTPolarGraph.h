#import "CPTDefinitions.h"
#import "CPTGraph.h"

@interface CPTPolarGraph : CPTGraph

/// @name Initialization
/// @{
-(nonnull instancetype)initWithFrame:(CGRect)newFrame majorScaleType:(CPTScaleType)newMajorScaleType minorScaleType:(CPTScaleType)newMinorScaleType; // NS_DESIGNATED_INITIALIZER;
/// @}

@end
