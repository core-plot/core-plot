#import "CPTAxisSet.h"

@class CPTXYAxis;

@interface CPTXYAxisSet : CPTAxisSet {
}

@property (nonatomic, readonly, strong) CPTXYAxis *xAxis;
@property (nonatomic, readonly, strong) CPTXYAxis *yAxis;

@end
