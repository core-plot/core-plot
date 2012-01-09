#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CPTPlotDocument : NSDocument<CPTPlotDataSource, CPTPlotSpaceDelegate>
{
	IBOutlet CPTGraphHostingView *graphView;
	CPTXYGraph *graph;

	double minimumValueForXAxis, maximumValueForXAxis, minimumValueForYAxis, maximumValueForYAxis;
	double majorIntervalLengthForX, majorIntervalLengthForY;
	NSMutableArray *dataPoints;

	CPTPlotSpaceAnnotation *zoomAnnotation;
	CGPoint dragStart, dragEnd;
}

-(IBAction)zoomIn;
-(IBAction)zoomOut;

// PDF / image export
-(IBAction)exportToPDF:(id)sender;
-(IBAction)exportToPNG:(id)sender;

@end
