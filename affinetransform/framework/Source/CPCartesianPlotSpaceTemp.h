
#import <Foundation/Foundation.h>
#import "CPPlotSpace.h"
#import "CPDefinitions.h"


@interface CPCartesianPlotSpaceTemp : CPPlotSpace {
  CPPlotRange XRange, YRange;
}

@property (nonatomic, readwrite, assign) CPPlotRange XRange, YRange;

@end
