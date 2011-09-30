#import "RotationView.h"
#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSArrayController<CPTPlotDataSource, CPTRotationDelegate, CPTPlotSpaceDelegate, CPTBarPlotDelegate>{
	IBOutlet CPTGraphHostingView *hostView;
	IBOutlet NSWindow *plotSymbolWindow;
	IBOutlet NSWindow *axisDemoWindow;
	IBOutlet NSWindow *selectionDemoWindow;
	CPTXYGraph *graph;
	RotationView *overlayRotationView;
	CPTLayerAnnotation *symbolTextAnnotation;
	CGFloat xShift;
	CGFloat yShift;
	CGFloat labelRotation;
}

@property (nonatomic) CGFloat xShift;
@property (nonatomic) CGFloat yShift;
@property (nonatomic) CGFloat labelRotation;

// Data loading
-(IBAction)reloadDataSourcePlot:(id)sender;
-(IBAction)removeData:(id)sender;
-(IBAction)insertData:(id)sender;

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
-(IBAction)selectionDemo:(id)sender;

@end
