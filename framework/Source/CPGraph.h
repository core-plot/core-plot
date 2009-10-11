
// Abstract class
#import "CPBorderedLayer.h"

@class CPAxisSet;
@class CPPlot;
@class CPPlotArea;
@class CPPlotSpace;
@class CPTheme;

@interface CPGraph : CPBorderedLayer {
@private
    CPPlotArea *plotArea;
    NSMutableArray *plots;
    NSMutableArray *plotSpaces;
}

@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotArea *plotArea;
@property (nonatomic, readonly, retain) CPPlotSpace *defaultPlotSpace;

/// @name Data Source
/// @{
-(void)reloadData;
///	@}

/// @name Retrieving Plots
/// @{
-(NSArray *)allPlots;
-(CPPlot *)plotAtIndex:(NSUInteger)index;
-(CPPlot *)plotWithIdentifier:(id <NSCopying>)identifier;
///	@}

/// @name Adding and Removing Plots
/// @{
-(void)addPlot:(CPPlot *)plot; 
-(void)addPlot:(CPPlot *)plot toPlotSpace:(CPPlotSpace *)space;
-(void)removePlot:(CPPlot *)plot;
-(void)insertPlot:(CPPlot *)plot atIndex:(NSUInteger)index;
-(void)insertPlot:(CPPlot *)plot atIndex:(NSUInteger)index intoPlotSpace:(CPPlotSpace *)space;
///	@}

/// @name Retrieving Plot Spaces
/// @{
-(NSArray *)allPlotSpaces;
-(CPPlotSpace *)plotSpaceAtIndex:(NSUInteger)index;
-(CPPlotSpace *)plotSpaceWithIdentifier:(id <NSCopying>)identifier;
///	@}

/// @name Adding and Removing Plot Spaces
/// @{
-(void)addPlotSpace:(CPPlotSpace *)space; 
-(void)removePlotSpace:(CPPlotSpace *)plotSpace;
///	@}

/// @name Themes
/// @{
-(void)applyTheme:(CPTheme *)theme;
/// @}

@end

@interface CPGraph (AbstractFactoryMethods)

-(CPPlotSpace *)newPlotSpace;
-(CPAxisSet *)newAxisSet;

@end
