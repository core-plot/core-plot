#import "CPTAxisSet.h"

@class CPTXYAxis;

@interface CPTXYAxisSet : CPTAxisSet

@property (nonatomic, readonly) CPTXYAxis *xAxis;
@property (nonatomic, readonly) CPTXYAxis *yAxis;

@end
