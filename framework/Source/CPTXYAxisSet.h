#import "CPTAxisSet.h"

@class CPTXYAxis;

@interface CPTXYAxisSet : CPTAxisSet {
}

@property (nonatomic, readonly, retain) CPTXYAxis *xAxis;
@property (nonatomic, readonly, retain) CPTXYAxis *yAxis;

@end
