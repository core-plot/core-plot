#import <Foundation/Foundation.h>
#import "CPGraph.h"
#import "CPDefinitions.h"

@interface CPXYGraph : CPGraph {
@private
    CPScaleType xScaleType;
    CPScaleType yScaleType;
}

/// @name Initialization
/// @{
-(id)initWithFrame:(CGRect)newFrame xScaleType:(CPScaleType)newXScaleType yScaleType:(CPScaleType)newYScaleType;
///	@}

@end
