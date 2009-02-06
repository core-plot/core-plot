
#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CPGraphView : NSView {
	CPGraph *graphLayer;
	IBOutlet NSArrayController *dataSource;
}

@end
