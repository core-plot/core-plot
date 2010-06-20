#import <Foundation/Foundation.h>
#import "CPAxisSet.h"

@class CPXYAxis;

@interface CPXYAxisSet : CPAxisSet {
}

@property (nonatomic, readonly, retain) CPXYAxis *xAxis;
@property (nonatomic, readonly, retain) CPXYAxis *yAxis;

@end
