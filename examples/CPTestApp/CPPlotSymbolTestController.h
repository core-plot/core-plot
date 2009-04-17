#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>


@interface CPPlotSymbolTestController : NSObject <CPPlotDataSource> {
    IBOutlet NSView *hostView;
	CPXYGraph *graph;
}

-(NSUInteger)numberOfRecords;
-(NSDecimalNumber *)decimalNumberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;

@end
