//
//  RealTimePlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface RealTimePlot : PlotItem<CPTPlotDataSource>
{
	NSMutableArray *plotData;
	NSUInteger currentIndex;
	NSTimer *dataTimer;
}

-(void)newData:(NSTimer *)theTimer;

@end
