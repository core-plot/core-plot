
#import <Foundation/Foundation.h>
#import "CPAxisSet.h"

@class CPAxis;

@interface CPXYAxisSet : CPAxisSet {
}

@property (nonatomic, readonly, retain) CPAxis *xAxis;
@property (nonatomic, readonly, retain) CPAxis *yAxis;

@end
