#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CPTPlotDocument : NSDocument<CPTPlotDataSource, CPTPlotSpaceDelegate>

-(IBAction)zoomIn;
-(IBAction)zoomOut;

// PDF / image export
-(IBAction)exportToPDF:(id)sender;
-(IBAction)exportToPNG:(id)sender;

@end
