#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTAxisSet.h>
#else
#import "CPTAxisSet.h"
#endif

@class CPTXYAxis;

@interface CPTXYAxisSet : CPTAxisSet

@property (nonatomic, readonly, nullable) CPTXYAxis *xAxis;
@property (nonatomic, readonly, nullable) CPTXYAxis *yAxis;

@end
