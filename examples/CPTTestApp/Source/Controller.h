#import "RotationView.h"
#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSArrayController<CPTPlotDataSource, CPTRotationDelegate, CPTPlotAreaDelegate, CPTPlotSpaceDelegate, CPTBarPlotDelegate> {
    IBOutlet CPTGraphHostingView *hostView;
    IBOutlet __unsafe_unretained NSWindow *plotSymbolWindow;
    IBOutlet __unsafe_unretained NSWindow *axisDemoWindow;
    IBOutlet __unsafe_unretained NSWindow *selectionDemoWindow;
    CPTXYGraph *graph;
    RotationView *overlayRotationView;
    CPTPlotSpaceAnnotation *symbolTextAnnotation;
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

// Printing
-(IBAction)printDocument:(id)sender;
-(void)printOperationDidRun:(NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(void *)contextInfo;

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
