
#import <Foundation/Foundation.h>
#import "CPPlotSpace.h"
#import "CPDefinitions.h"


@interface CPCartesianPlotSpace : CPPlotSpace {
	CPPlotRange XRange, YRange;
}

@property (nonatomic, readwrite, assign) CPPlotRange XRange, YRange;

@end
