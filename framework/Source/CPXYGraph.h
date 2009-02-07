
#import <Foundation/Foundation.h>
#import "CPGraph.h"
#import "CPDefinitions.h"

@class CPCartesianPlotSpace;

@interface CPXYGraph : CPGraph {

}

-(id)initWithXScaleType:(CPScaleType)xScaleType yScaleType:(CPScaleType)yScaleType;

@end
