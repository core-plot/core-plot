#import "CPTAnnotation.h"

@class CPTPlotSpace;

@interface CPTPlotSpaceAnnotation : CPTAnnotation

@property (nonatomic, readwrite, copy) NSArray *anchorPlotPoint;
@property (nonatomic, readonly, strong) CPTPlotSpace *plotSpace;

-(id)initWithPlotSpace:(CPTPlotSpace *)space anchorPlotPoint:(NSArray *)plotPoint;

@end
