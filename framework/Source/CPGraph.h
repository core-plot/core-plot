
// Abstract class

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPAxisSet;
@class CPPlotArea;
@class CPPlot;

@interface CPGraph : CALayer {
    CPAxisSet *axisSet;
    CPPlotArea *plotArea;
    NSMutableArray *plots;
}

// Adding and removing plots
-(void)addPlot:(CPPlot *)plot;
-(NSArray *)allPlots;
-(void)removePlotAtIndex:(NSUInteger)index;
-(void)insertPlotAtIndex:(NSUInteger)index;
-(void)removePlotWithIdentifier:(id <NSCopying>)identifier;
-(CPPlot *)plotWithIdentifier:(id <NSCopying>)identifier;
-(void)replacePlotAtIndex:(NSUInteger)index withPlot:(CPPlot *)plot;

@end
