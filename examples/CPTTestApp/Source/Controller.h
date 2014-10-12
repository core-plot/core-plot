#import "RotationView.h"
#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSArrayController<CPTPlotDataSource, CPTRotationDelegate, CPTPlotAreaDelegate, CPTPlotSpaceDelegate, CPTBarPlotDelegate>

@property (nonatomic, readwrite, assign) CGFloat xShift;
@property (nonatomic, readwrite, assign) CGFloat yShift;
@property (nonatomic, readwrite, assign) CGFloat labelRotation;

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
