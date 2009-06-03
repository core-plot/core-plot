
#import <Foundation/Foundation.h>
#import "CPGraph.h"
#import "CPDefinitions.h"

@class CPXYPlotSpace;

@interface CPXYGraph : CPGraph {
    CPScaleType xScaleType;
    CPScaleType yScaleType;
}

-(id)initWithFrame:(CGRect)newFrame xScaleType:(CPScaleType)newXScaleType yScaleType:(CPScaleType)newYScaleType;

@end
