#import "RotationView.h"
@import Cocoa;
@import CorePlot;

@interface Controller : NSArrayController<CPTPlotDataSource, CPTRotationDelegate, CPTPlotAreaDelegate, CPTPlotSpaceDelegate, CPTBarPlotDelegate>

@property (nonatomic, readwrite, assign) CGFloat xShift;
@property (nonatomic, readwrite, assign) CGFloat yShift;
@property (nonatomic, readwrite, assign) CGFloat labelRotation;

// Data loading
-(IBAction)reloadDataSourcePlot:(nullable id)sender;
-(IBAction)removeData:(nullable id)sender;
-(IBAction)insertData:(nullable id)sender;

// PDF / image export
-(IBAction)exportToPDF:(nullable id)sender;
-(IBAction)exportToPNG:(nullable id)sender;

// Printing
-(IBAction)printDocument:(nullable id)sender;
-(void)printOperationDidRun:(nonnull NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(nullable void *)contextInfo;

// Layer exploding for illustration
-(IBAction)explodeLayers:(nullable id)sender;
+(void)recursivelySplitSublayersInZForLayer:(nonnull CALayer *)layer depthLevel:(NSUInteger)depthLevel;
-(IBAction)reassembleLayers:(nullable id)sender;
+(void)recursivelyAssembleSublayersInZForLayer:(nonnull CALayer *)layer;

// Demo windows
-(IBAction)plotSymbolDemo:(nullable id)sender;
-(IBAction)axisDemo:(nullable id)sender;
-(IBAction)selectionDemo:(nullable id)sender;

@end
