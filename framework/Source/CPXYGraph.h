
#import <Foundation/Foundation.h>
#import "CPGraph.h"
#import "CPDefinitions.h"

@class CPCartesianPlotSpace;

@interface CPXYGraph : CPGraph {
    CPScaleType xScaleType;
    CPScaleType yScaleType;
}

-(id)initWithXScaleType:(CPScaleType)xScaleType yScaleType:(CPScaleType)yScaleType;

@end
