//
// RealTimePlot.h
// CorePlotGallery
//

#import "PlotItem.h"

@interface RealTimePlot : PlotItem<CPTPlotDataSource>

-(void)newData:(nonnull NSTimer *)theTimer;

@end
