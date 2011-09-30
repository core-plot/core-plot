#import "CPTAxisSet.h"
#import <Foundation/Foundation.h>

@class CPTXYAxis;

@interface CPTXYAxisSet : CPTAxisSet {
}

@property (nonatomic, readonly, retain) CPTXYAxis *xAxis;
@property (nonatomic, readonly, retain) CPTXYAxis *yAxis;

@end
