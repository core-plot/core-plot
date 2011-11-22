// Abstract class
#import "CPTBorderedLayer.h"
#import "CPTDefinitions.h"

/// @file

@class CPTAxisSet;
@class CPTLegend;
@class CPTPlot;
@class CPTPlotAreaFrame;
@class CPTPlotSpace;
@class CPTTheme;
@class CPTTextStyle;
@class CPTLayerAnnotation;

/// @name Graph
/// @{

/**	@brief Notification sent by various objects to tell the graph it should redraw itself.
 *	@ingroup notification
 **/
extern NSString *const CPTGraphNeedsRedrawNotification;

///	@}

/**
 *	@brief Enumeration of graph layers.
 **/
typedef enum _CPTGraphLayerType {
	CPTGraphLayerTypeMinorGridLines, ///< Minor grid lines.
	CPTGraphLayerTypeMajorGridLines, ///< Major grid lines.
	CPTGraphLayerTypeAxisLines,      ///< Axis lines.
	CPTGraphLayerTypePlots,          ///< Plots.
	CPTGraphLayerTypeAxisLabels,     ///< Axis labels.
	CPTGraphLayerTypeAxisTitles      ///< Axis titles.
}
CPTGraphLayerType;

#pragma mark -

@interface CPTGraph : CPTBorderedLayer {
	@private
	CPTPlotAreaFrame *plotAreaFrame;
	NSMutableArray *plots;
	NSMutableArray *plotSpaces;
	NSString *title;
	CPTTextStyle *titleTextStyle;
	CPTRectAnchor titlePlotAreaFrameAnchor;
	CGPoint titleDisplacement;
	CPTLayerAnnotation *titleAnnotation;
	CPTLegend *legend;
	CPTLayerAnnotation *legendAnnotation;
	CPTRectAnchor legendAnchor;
	CGPoint legendDisplacement;
}

/// @name Title
/// @{
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) CPTTextStyle *titleTextStyle;
@property (nonatomic, readwrite, assign) CGPoint titleDisplacement;
@property (nonatomic, readwrite, assign) CPTRectAnchor titlePlotAreaFrameAnchor;
///	@}

/// @name Layers
/// @{
@property (nonatomic, readwrite, retain) CPTAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPTPlotAreaFrame *plotAreaFrame;
@property (nonatomic, readonly, retain) CPTPlotSpace *defaultPlotSpace;
@property (nonatomic, readwrite, retain) NSArray *topDownLayerOrder;
///	@}

/// @name Legend
/// @{
@property (nonatomic, readwrite, retain) CPTLegend *legend;
@property (nonatomic, readwrite, assign) CPTRectAnchor legendAnchor;
@property (nonatomic, readwrite, assign) CGPoint legendDisplacement;
///	@}

/// @name Data Source
/// @{
-(void)reloadData;
-(void)reloadDataIfNeeded;
///	@}

/// @name Retrieving Plots
/// @{
-(NSArray *)allPlots;
-(CPTPlot *)plotAtIndex:(NSUInteger)index;
-(CPTPlot *)plotWithIdentifier:(id<NSCopying>)identifier;
///	@}

/// @name Adding and Removing Plots
/// @{
-(void)addPlot:(CPTPlot *)plot;
-(void)addPlot:(CPTPlot *)plot toPlotSpace:(CPTPlotSpace *)space;
-(void)removePlot:(CPTPlot *)plot;
-(void)removePlotWithIdentifier:(id<NSCopying>)identifier;
-(void)insertPlot:(CPTPlot *)plot atIndex:(NSUInteger)index;
-(void)insertPlot:(CPTPlot *)plot atIndex:(NSUInteger)index intoPlotSpace:(CPTPlotSpace *)space;
///	@}

/// @name Retrieving Plot Spaces
/// @{
-(NSArray *)allPlotSpaces;
-(CPTPlotSpace *)plotSpaceAtIndex:(NSUInteger)index;
-(CPTPlotSpace *)plotSpaceWithIdentifier:(id<NSCopying>)identifier;
///	@}

/// @name Adding and Removing Plot Spaces
/// @{
-(void)addPlotSpace:(CPTPlotSpace *)space;
-(void)removePlotSpace:(CPTPlotSpace *)plotSpace;
///	@}

/// @name Themes
/// @{
-(void)applyTheme:(CPTTheme *)theme;
/// @}

@end

#pragma mark -

/**	@category CPTGraph(AbstractFactoryMethods)
 *	@brief CPTGraph abstract methods—must be overridden by subclasses
 **/
@interface CPTGraph(AbstractFactoryMethods)

/// @name Factory Methods
/// @{
-(CPTPlotSpace *)newPlotSpace;
-(CPTAxisSet *)newAxisSet;
/// @}

@end
