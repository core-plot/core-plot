

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>
#import "RotationView.h"

@interface Controller : NSArrayController <CPPlotDataSource, CPRotationDelegate> {
    IBOutlet CPLayerHostingView *hostView;
    CPXYGraph *graph;
	RotationView *overlayRotationView;
}

-(IBAction)reloadDataSourcePlot:(id)sender;

// PDF / image export
-(IBAction)exportToPDF:(id)sender;
-(IBAction)exportToPNG:(id)sender;

// Layer exploding for illustration
-(IBAction)explodeLayers:(id)sender;
+(void)recursivelySplitSublayersInZForLayer:(CALayer *)layer depthLevel:(unsigned int)depthLevel;
-(IBAction)reassembleLayers:(id)sender;
+(void)recursivelyAssembleSublayersInZForLayer:(CALayer *)layer;

@end

