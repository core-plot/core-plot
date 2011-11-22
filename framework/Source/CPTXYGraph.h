#import "CPTDefinitions.h"
#import "CPTGraph.h"
#import <Foundation/Foundation.h>

@interface CPTXYGraph : CPTGraph {
	@private
	CPTScaleType xScaleType;
	CPTScaleType yScaleType;
}

/// @name Initialization
/// @{
-(id)initWithFrame:(CGRect)newFrame xScaleType:(CPTScaleType)newXScaleType yScaleType:(CPTScaleType)newYScaleType;
///	@}

@end
