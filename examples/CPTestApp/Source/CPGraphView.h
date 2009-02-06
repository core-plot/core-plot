
#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CPGraphView : NSView {
	CPGraph *graphLayer;
	IBOutlet NSArrayController *dataSource;
	IBOutlet NSArrayController* xData, *yData;
}

@property (retain) CPGraph* graphLayer;
@property (retain) IBOutlet NSArrayController* xData, *yData;

@end
