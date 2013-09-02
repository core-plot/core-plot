#import "CPTAnnotation.h"

@class CPTPlotSpace;

@interface CPTPlotSpaceAnnotation : CPTAnnotation

@property (nonatomic, readwrite, copy) NSArray *anchorPlotPoint;
@property (nonatomic, readonly) CPTPlotSpace *plotSpace;

-(instancetype)initWithPlotSpace:(CPTPlotSpace *)space anchorPlotPoint:(NSArray *)plotPoint;

@end
