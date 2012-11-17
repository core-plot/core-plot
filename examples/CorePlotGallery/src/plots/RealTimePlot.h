//
//  RealTimePlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface RealTimePlot : PlotItem<CPTPlotDataSource>
{
    @private
    NSMutableArray *plotData;
    NSUInteger currentIndex;
    NSTimer *dataTimer;
}

-(void)newData:(NSTimer *)theTimer;

@end
