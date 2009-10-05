
// Abstract class
#import "CPLayer.h"

@class CPAxisSet;
@class CPFill;
@class CPPlotArea;
@class CPPlot;
@class CPPlotSpace;
@class CPTheme;

@interface CPGraph : CPLayer {
@private
    CPAxisSet *axisSet;
    CPPlotArea *plotArea;
    NSMutableArray *plots;
    NSMutableArray *plotSpaces;
	CPFill *fill;
}

@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotArea *plotArea;
@property (nonatomic, readonly, retain) CPPlotSpace *defaultPlotSpace;
@property (nonatomic, readwrite, retain) CPFill *fill;

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
