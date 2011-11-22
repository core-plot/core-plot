#import "PlotItem.h"

@interface ControlChart : PlotItem<CPTPlotDataSource>
{
	NSArray *plotData;
	double meanValue;
	double standardError;
}

@end
