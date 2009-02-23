
#import <Foundation/Foundation.h>
#import "CPPlotRange.h"
#import "CPPlotSpace.h"
#import "CPDefinitions.h"


@interface CPCartesianPlotSpace : CPPlotSpace {
	CPPlotRange*	xRange;
	CPPlotRange*	yRange;
}

@property (readwrite, retain) CPPlotRange* xRange;
@property (readwrite, retain) CPPlotRange* yRange;

@end
