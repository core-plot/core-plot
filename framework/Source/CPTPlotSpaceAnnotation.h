#import "CPTAnnotation.h"
#import <Foundation/Foundation.h>

@class CPTPlotSpace;

@interface CPTPlotSpaceAnnotation : CPTAnnotation {
    NSArray *anchorPlotPoint;
    CPTPlotSpace *plotSpace;
}

@property (nonatomic, readwrite, copy) NSArray *anchorPlotPoint;
@property (nonatomic, readonly, retain) CPTPlotSpace *plotSpace;

-(id)initWithPlotSpace:(CPTPlotSpace *)space anchorPlotPoint:(NSArray *)plotPoint;

@end
