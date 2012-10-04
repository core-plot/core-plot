#import "CPTBorderedLayer.h"
#import <Foundation/Foundation.h>

/// @file

@class CPTLegend;
@class CPTPlot;
@class CPTTextStyle;

/// @name Legend
/// @{

/** @brief Notification sent by plots to tell the legend it should redraw itself.
 *  @ingroup notification
 **/
extern NSString *const CPTLegendNeedsRedrawForPlotNotification;

/** @brief Notification sent by plots to tell the legend it should update its layout and redraw itself.
 *  @ingroup notification
 **/
extern NSString *const CPTLegendNeedsLayoutForPlotNotification;

/** @brief Notification sent by plots to tell the legend it should reload all legend entries.
 *  @ingroup notification
 **/
extern NSString *const CPTLegendNeedsReloadEntriesForPlotNotification;

/// @}

/**
 *  @brief Axis labeling delegate.
 **/
@protocol CPTLegendDelegate<NSObject>

/// @name Drawing
/// @{

/** @brief @required This method gives the delegate a chance to draw custom swatches for each legend entry.
 *
 *  The "swatch" is the graphical part of the legend entry, usually accompanied by a text title
 *  that will be drawn by the legend. Returning @NO will cause the legend to not draw the default
 *  legend graphics. It is then the delegate&rsquo;s responsiblity to do this.
 *  @param legend The legend.
 *  @param idx The zero-based index of the legend entry for the given plot.
 *  @param plot The plot.
 *  @param rect The bounding rectangle to use when drawing the swatch.
 *  @param context The graphics context to draw into.
 *  @return @YES if the legend should draw the default swatch or @NO if the delegate handled the drawing.
 **/
-(BOOL)legend:(CPTLegend *)legend shouldDrawSwatchAtIndex:(NSUInteger)idx forPlot:(CPTPlot *)plot inRect:(CGRect)rect inContext:(CGContextRef)context;

/// @}

@end

#pragma mark -

@interface CPTLegend : CPTBorderedLayer {
    @private
    NSMutableArray *plots;
    NSMutableArray *legendEntries;
    BOOL layoutChanged;
    CPTTextStyle *textStyle;
    CGSize swatchSize;
    CPTLineStyle *swatchBorderLineStyle;
    CGFloat swatchCornerRadius;
    CPTFill *swatchFill;
    NSUInteger numberOfRows;
    NSUInteger numberOfColumns;
    BOOL equalRows;
    BOOL equalColumns;
    NSArray *rowHeights;
    NSArray *rowHeightsThatFit;
    NSArray *columnWidths;
    NSArray *columnWidthsThatFit;
    CGFloat columnMargin;
    CGFloat rowMargin;
    CGFloat titleOffset;
}

/// @name Formatting
/// @{
@property (nonatomic, readwrite, copy) CPTTextStyle *textStyle;
@property (nonatomic, readwrite, assign) CGSize swatchSize;
@property (nonatomic, readwrite, copy) CPTLineStyle *swatchBorderLineStyle;
@property (nonatomic, readwrite, assign) CGFloat swatchCornerRadius;
@property (nonatomic, readwrite, copy) CPTFill *swatchFill;
/// @}

/// @name Layout
/// @{
@property (nonatomic, readonly, assign) BOOL layoutChanged;
@property (nonatomic, readwrite, assign) NSUInteger numberOfRows;
@property (nonatomic, readwrite, assign) NSUInteger numberOfColumns;
@property (nonatomic, readwrite, assign) BOOL equalRows;
@property (nonatomic, readwrite, assign) BOOL equalColumns;
@property (nonatomic, readwrite, copy) NSArray *rowHeights;
@property (nonatomic, readonly, retain) NSArray *rowHeightsThatFit;
@property (nonatomic, readwrite, copy) NSArray *columnWidths;
@property (nonatomic, readonly, retain) NSArray *columnWidthsThatFit;
@property (nonatomic, readwrite, assign) CGFloat columnMargin;
@property (nonatomic, readwrite, assign) CGFloat rowMargin;
@property (nonatomic, readwrite, assign) CGFloat titleOffset;
/// @}

/// @name Factory Methods
/// @{
+(id)legendWithPlots:(NSArray *)newPlots;
+(id)legendWithGraph:(CPTGraph *)graph;
/// @}

/// @name Initialization
/// @{
-(id)initWithPlots:(NSArray *)newPlots;
-(id)initWithGraph:(CPTGraph *)graph;
/// @}

/// @name Plots
/// @{
-(NSArray *)allPlots;
-(CPTPlot *)plotAtIndex:(NSUInteger)idx;
-(CPTPlot *)plotWithIdentifier:(id<NSCopying>)identifier;

-(void)addPlot:(CPTPlot *)plot;
-(void)insertPlot:(CPTPlot *)plot atIndex:(NSUInteger)idx;
-(void)removePlot:(CPTPlot *)plot;
-(void)removePlotWithIdentifier:(id<NSCopying>)identifier;
/// @}

/// @name Layout
/// @{
-(void)setLayoutChanged;
/// @}

@end
