#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CPPlotDocument : NSDocument <CPPlotDataSource>
{
	IBOutlet CPLayerHostingView *graphView;
    CPXYGraph *graph;
	
	double minimumValueForXAxis, maximumValueForXAxis, minimumValueForYAxis, maximumValueForYAxis;
	double majorIntervalLengthForX, majorIntervalLengthForY;
	NSMutableArray *dataPoints;
}

// PDF / image export
-(IBAction)exportToPDF:(id)sender;
-(IBAction)exportToPNG:(id)sender;

@end
