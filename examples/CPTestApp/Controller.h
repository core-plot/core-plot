

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSArrayController <CPPlotDataSource> {
    IBOutlet NSView *hostView;
    CPXYGraph *graph;
}

-(IBAction)reloadDataSourcePlot:(id)sender;
-(NSUInteger)numberOfRecords;
-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;

// PDF / image export
-(IBAction)exportToPDF:(id)sender;
-(IBAction)exportToPNG:(id)sender;

@end
