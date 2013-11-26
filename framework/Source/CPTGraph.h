// Abstract class
#import "CPTBorderedLayer.h"
#import "CPTDefinitions.h"

/// @file

@class CPTAxisSet;
@class CPTGraphHostingView;
@class CPTLegend;
@class CPTPlot;
@class CPTPlotAreaFrame;
@class CPTPlotSpace;
@class CPTTheme;
@class CPTTextStyle;
@class CPTLayerAnnotation;

/// @name Graph
/// @{

/** @brief Notification sent by various objects to tell the graph it should redraw itself.
 *  @ingroup notification
 **/
extern NSString *const CPTGraphNeedsRedrawNotification;

/** @brief Notification sent by a graph after adding a new plot space.
 *  @ingroup notification
 *
 *  The notification <code>userInfo</code> dictionary will include the new plot space under the
 *  CPTGraphPlotSpaceNotificationKey key.
 **/
extern NSString *const CPTGraphDidAddPlotSpaceNotification;

/** @brief Notification sent by a graph after removing a plot space.
 *  @ingroup notification
 *
 *  The notification <code>userInfo</code> dictionary will include the removed plot space under the
 *  CPTGraphPlotSpaceNotificationKey key.
 **/
extern NSString *const CPTGraphDidRemovePlotSpaceNotification;

/** @brief The <code>userInfo</code> dictionary key used by the CPTGraphDidAddPlotSpaceNotification
 *  and CPTGraphDidRemovePlotSpaceNotification notifications for the plot space.
 *  @ingroup notification
 **/
extern NSString *const CPTGraphPlotSpaceNotificationKey;

/// @}

/**
 *  @brief Enumeration of graph layers.
 **/
typedef NS_ENUM (NSInteger, CPTGraphLayerType) {
    CPTGraphLayerTypeMinorGridLines, ///< Minor grid lines.
    CPTGraphLayerTypeMajorGridLines, ///< Major grid lines.
    CPTGraphLayerTypeAxisLines,      ///< Axis lines.
    CPTGraphLayerTypePlots,          ///< Plots.
    CPTGraphLayerTypeAxisLabels,     ///< Axis labels.
    CPTGraphLayerTypeAxisTitles      ///< Axis titles.
};

#pragma mark -

@interface CPTGraph : CPTBorderedLayer

/// @name Hosting View
/// @{
@property (nonatomic, readwrite, cpt_weak_property) __cpt_weak CPTGraphHostingView *hostingView;
/// @}

/// @name Title
/// @{
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSAttributedString *attributedTitle;
@property (nonatomic, readwrite, copy) CPTTextStyle *titleTextStyle;
@property (nonatomic, readwrite, assign) CGPoint titleDisplacement;
@property (nonatomic, readwrite, assign) CPTRectAnchor titlePlotAreaFrameAnchor;
/// @}

/// @name Layers
/// @{
@property (nonatomic, readwrite, strong) CPTAxisSet *axisSet;
@property (nonatomic, readwrite, strong) CPTPlotAreaFrame *plotAreaFrame;
@property (nonatomic, readonly) CPTPlotSpace *defaultPlotSpace;
@property (nonatomic, readwrite, strong) NSArray *topDownLayerOrder;
/// @}

/// @name Legend
/// @{
@property (nonatomic, readwrite, strong) CPTLegend *legend;
@property (nonatomic, readwrite, assign) CPTRectAnchor legendAnchor;
@property (nonatomic, readwrite, assign) CGPoint legendDisplacement;
/// @}

/// @name Data Source
/// @{
-(void)reloadData;
-(void)reloadDataIfNeeded;
/// @}

/// @name Retrieving Plots
/// @{
-(NSArray *)allPlots;
-(CPTPlot *)plotAtIndex:(NSUInteger)idx;
-(CPTPlot *)plotWithIdentifier:(id<NSCopying>)identifier;
/// @}

/// @name Adding and Removing Plots
/// @{
-(void)addPlot:(CPTPlot *)plot;
-(void)addPlot:(CPTPlot *)plot toPlotSpace:(CPTPlotSpace *)space;
-(void)removePlot:(CPTPlot *)plot;
-(void)removePlotWithIdentifier:(id<NSCopying>)identifier;
-(void)insertPlot:(CPTPlot *)plot atIndex:(NSUInteger)idx;
-(void)insertPlot:(CPTPlot *)plot atIndex:(NSUInteger)idx intoPlotSpace:(CPTPlotSpace *)space;
/// @}

/// @name Retrieving Plot Spaces
/// @{
-(NSArray *)allPlotSpaces;
-(CPTPlotSpace *)plotSpaceAtIndex:(NSUInteger)idx;
-(CPTPlotSpace *)plotSpaceWithIdentifier:(id<NSCopying>)identifier;
/// @}

/// @name Adding and Removing Plot Spaces
/// @{
-(void)addPlotSpace:(CPTPlotSpace *)space;
-(void)removePlotSpace:(CPTPlotSpace *)plotSpace;
/// @}

/// @name Themes
/// @{
-(void)applyTheme:(CPTTheme *)theme;
/// @}

@end

#pragma mark -

/** @category CPTGraph(AbstractFactoryMethods)
 *  @brief CPTGraph abstract methods—must be overridden by subclasses
 **/
@interface CPTGraph(AbstractFactoryMethods)

/// @name Factory Methods
/// @{
-(CPTPlotSpace *)newPlotSpace;
-(CPTAxisSet *)newAxisSet;
/// @}

@end
