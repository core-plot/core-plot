// Abstract class
#import "CPAnnotationLayer.h"
#import "CPDefinitions.h"

/// @file

@class CPAxisSet;
@class CPPlot;
@class CPPlotAreaFrame;
@class CPPlotSpace;
@class CPTheme;
@class CPTextStyle;
@class CPLayerAnnotation;

/**
 *	@brief Enumeration of graph layers.
 **/
typedef enum _CPGraphLayerType {
	CPGraphLayerTypeMinorGridLines,		///< Minor grid lines.
	CPGraphLayerTypeMajorGridLines,		///< Major grid lines.
	CPGraphLayerTypeAxisLines,			///< Axis lines.
	CPGraphLayerTypePlots,				///< Plots.
	CPGraphLayerTypeAxisLabels,			///< Axis labels.
	CPGraphLayerTypeAxisTitles			///< Axis titles.
} CPGraphLayerType;

@interface CPGraph : CPAnnotationLayer {
	@private
    CPPlotAreaFrame *plotAreaFrame;
    NSMutableArray *plots;
    NSMutableArray *plotSpaces;
    NSString *title;
    CPTextStyle *titleTextStyle;
    CPRectAnchor titlePlotAreaFrameAnchor;
    CGPoint titleDisplacement;
    CPLayerAnnotation *titleAnnotation;
}

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) CPTextStyle *titleTextStyle;
@property (nonatomic, readwrite, assign) CGPoint titleDisplacement;
@property (nonatomic, readwrite, assign) CPRectAnchor titlePlotAreaFrameAnchor;
@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotAreaFrame *plotAreaFrame;
@property (nonatomic, readonly, retain) CPPlotSpace *defaultPlotSpace;
@property (nonatomic, readwrite, retain) NSArray *topDownLayerOrder;

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

/**	@category CPGraph(AbstractFactoryMethods)
 *	@brief CPGraph abstract methods—must be overridden by subclasses
 **/
@interface CPGraph(AbstractFactoryMethods)

/// @name Factory Methods
/// @{
-(CPPlotSpace *)newPlotSpace;
-(CPAxisSet *)newAxisSet;
/// @}

@end
