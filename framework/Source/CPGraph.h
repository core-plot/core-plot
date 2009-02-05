
// Abstract class

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPAxisSet;
@class CPPlotArea;
@class CPPlot;
@class CPPlotSpace;

@interface CPGraph : CALayer {
    CPAxisSet *axisSet;
    CPPlotArea *plotArea;
    NSMutableArray *plots;
    NSMutableArray *plotSpaces;
}

@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotArea *plotArea;
@property (nonatomic, readonly, retain) CPPlotSpace *defaultPlotSpace;

// Retrieving plots
-(NSArray *)allPlots;
-(CPPlot *)plotAtIndex:(NSUInteger)index;
-(CPPlot *)plotWithIdentifier:(id <NSCopying>)identifier;

// Organizing plots
-(void)addPlot:(CPPlot *)plot; 
-(void)addPlot:(CPPlot *)plot toPlotSpace:(CPPlotSpace *)space;
-(void)removePlot:(CPPlot *)plot;
-(void)insertPlot:(CPPlot*)plot atIndex:(NSUInteger)index;
-(void)insertPlot:(CPPlot*)plot atIndex:(NSUInteger)index intoPlotSpace:(CPPlotSpace *)space;
-(void)replacePlotAtIndex:(NSUInteger)index withPlot:(CPPlot *)plot inPlotSpace:(CPPlotSpace *)space;

// Retrieving plot spaces
-(NSArray *)allPlotSpaces;
-(CPPlotSpace *)plotSpaceAtIndex:(NSUInteger)index;
-(CPPlotSpace *)plotSpaceWithIdentifier:(id <NSCopying>)identifier;

// Adding and removing plot spaces
-(void)addPlotSpace:(CPPlotSpace *)space; 
-(void)removePlotSpace:(CPPlotSpace *)plotSpace;

// Plot Area
-(CGRect)plotAreaFrame;
-(void)setPlotAreaFrame:(CGRect)frame;

@end
