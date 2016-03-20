#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CPTPlotDocument : NSDocument<CPTPlotDataSource, CPTPlotSpaceDelegate>

-(IBAction)zoomIn;
-(IBAction)zoomOut;

// PDF / image export
-(IBAction)exportToPDF:(nullable id)sender;
-(IBAction)exportToPNG:(nullable id)sender;

@end
