#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSObject<CPTPlotDataSource, CPTPlotSpaceDelegate> {
	IBOutlet CPTGraphHostingView *hostView;
	CPTXYGraph *graph;
	NSArray *plotData;
	CPTFill *areaFill;
	CPTLineStyle *barLineStyle;
}

@end
