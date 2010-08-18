#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>
#import "RotationView.h"

@interface Controller : NSArrayController <CPPlotDataSource, CPRotationDelegate, CPPlotSpaceDelegate, CPBarPlotDelegate> {
    IBOutlet CPLayerHostingView *hostView;
    IBOutlet NSWindow *plotSymbolWindow;
    IBOutlet NSWindow *axisDemoWindow;
    CPXYGraph *graph;
	RotationView *overlayRotationView;
    CPLayerAnnotation *symbolTextAnnotation;
    CGFloat xShift;
    CGFloat yShift;
    CGFloat labelRotation;
}

@property CGFloat xShift;
@property CGFloat yShift;
@property CGFloat labelRotation;

-(IBAction)reloadDataSourcePlot:(id)sender;

// PDF / image export
-(IBAction)exportToPDF:(id)sender;
-(IBAction)exportToPNG:(id)sender;

// Layer exploding for illustration
-(IBAction)explodeLayers:(id)sender;
+(void)recursivelySplitSublayersInZForLayer:(CALayer *)layer depthLevel:(NSUInteger)depthLevel;
-(IBAction)reassembleLayers:(id)sender;
+(void)recursivelyAssembleSublayersInZForLayer:(CALayer *)layer;

// Demo windows
-(IBAction)plotSymbolDemo:(id)sender;
-(IBAction)axisDemo:(id)sender;

@end

