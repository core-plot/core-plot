
// Abstract class

#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPAxisSet;
@class CPFill;
@class CPPlotArea;
@class CPPlot;
@class CPPlotSpace;

@interface CPGraph : CPLayer {
    @protected
    CPAxisSet *axisSet;
    CPPlotArea *plotArea;
    NSMutableArray *plots;
    NSMutableArray *plotSpaces;
	CPFill *fill;
}

@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotArea *plotArea;
@property (nonatomic, readonly, retain) CPPlotSpace *defaultPlotSpace;
@property (nonatomic, readwrite, assign) CGRect plotAreaFrame;
@property (nonatomic, readwrite, retain) CPFill *fill;

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

// Retrieving plot spaces
-(NSArray *)allPlotSpaces;
-(CPPlotSpace *)plotSpaceAtIndex:(NSUInteger)index;
-(CPPlotSpace *)plotSpaceWithIdentifier:(id <NSCopying>)identifier;

// Adding and removing plot spaces
-(void)addPlotSpace:(CPPlotSpace *)space; 
-(void)removePlotSpace:(CPPlotSpace *)plotSpace;

@end

@interface CPGraph (AbstractFactoryMethods)

-(CPPlotSpace *)createPlotSpace;
-(CPAxisSet *)createAxisSet;

@end

