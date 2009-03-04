

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSArrayController <CPPlotDataSource> {
    IBOutlet NSView *hostView;
    CPXYGraph *graph;
}

-(IBAction)reloadDataSourcePlot:(id)sender;

@end
