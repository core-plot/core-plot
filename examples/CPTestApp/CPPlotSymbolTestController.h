#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>


@interface CPPlotSymbolTestController : NSObject <CPPlotDataSource> {
    IBOutlet NSView *hostView;
	CPXYGraph *graph;
}

-(NSUInteger)numberOfRecords;
-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;

@end
