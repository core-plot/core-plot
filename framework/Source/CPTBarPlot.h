#import "CPTDefinitions.h"
#import "CPTPlot.h"

/// @file

@class CPTLineStyle;
@class CPTMutableNumericData;
@class CPTNumericData;
@class CPTFill;
@class CPTPlotRange;
@class CPTColor;
@class CPTBarPlot;
@class CPTTextLayer;
@class CPTTextStyle;

/// @ingroup plotBindingsBarPlot
/// @{
extern NSString *const CPTBarPlotBindingBarLocations;
extern NSString *const CPTBarPlotBindingBarTips;
extern NSString *const CPTBarPlotBindingBarBases;
extern NSString *const CPTBarPlotBindingBarFills;
extern NSString *const CPTBarPlotBindingBarLineStyles;
/// @}

/**
 *  @brief Enumeration of bar plot data source field types
 **/
typedef NS_ENUM (NSInteger, CPTBarPlotField) {
    CPTBarPlotFieldBarLocation, ///< Bar location on independent coordinate axis.
    CPTBarPlotFieldBarTip,      ///< Bar tip value.
    CPTBarPlotFieldBarBase      ///< Bar base (used only if @link CPTBarPlot::barBasesVary barBasesVary @endlink is YES).
};

#pragma mark -

/**
 *  @brief A bar plot data source.
 **/
@protocol CPTBarPlotDataSource<CPTPlotDataSource>
@optional

/// @name Bar Style
/// @{

/** @brief @optional Gets an array of bar fills for the given bar plot.
 *  @param barPlot The bar plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of bar fills.
 **/
-(NSArray *)barFillsForBarPlot:(CPTBarPlot *)barPlot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a bar fill for the given bar plot.
 *  This method will not be called if
 *  @link CPTBarPlotDataSource::barFillsForBarPlot:recordIndexRange: -barFillsForBarPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param barPlot The bar plot.
 *  @param idx The data index of interest.
 *  @return The bar fill for the bar with the given index. If the data source returns @nil, the default fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx;

/** @brief @optional Gets an array of bar line styles for the given bar plot.
 *  @param barPlot The bar plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(NSArray *)barLineStylesForBarPlot:(CPTBarPlot *)barPlot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a bar line style for the given bar plot.
 *  This method will not be called if
 *  @link CPTBarPlotDataSource::barLineStylesForBarPlot:recordIndexRange: -barLineStylesForBarPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param barPlot The bar plot.
 *  @param idx The data index of interest.
 *  @return The bar line style for the bar with the given index. If the data source returns @nil, the default line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)barLineStyleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx;

/// @}

/// @name Legends
/// @{

/** @brief @optional Gets the legend title for the given bar plot bar.
 *  @param barPlot The bar plot.
 *  @param idx The data index of interest.
 *  @return The title text for the legend entry for the point with the given index.
 **/
-(NSString *)legendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx;

/** @brief @optional Gets the styled legend title for the given bar plot bar.
 *  @param barPlot The bar plot.
 *  @param idx The data index of interest.
 *  @return The styled title text for the legend entry for the point with the given index.
 **/
-(NSAttributedString *)attributedLegendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx;

/// @}
@end

#pragma mark -

/**
 *  @brief Bar plot delegate.
 **/
@protocol CPTBarPlotDelegate<CPTPlotDelegate>

@optional

/// @name Point Selection
/// @{

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The bar plot.
 *  @param idx The index of the
 *
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The bar plot.
 *  @param idx The index of the
 *
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The bar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)barPlot:(CPTBarPlot *)plot barTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The bar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)barPlot:(CPTBarPlot *)plot barTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The bar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)barPlot:(CPTBarPlot *)plot barTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The bar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)barPlot:(CPTBarPlot *)plot barTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTBarPlot : CPTPlot

/// @name Appearance
/// @{
@property (nonatomic, readwrite, assign) BOOL barWidthsAreInViewCoordinates;
@property (nonatomic, readwrite, assign) NSDecimal barWidth;
@property (nonatomic, readwrite, assign) CGFloat barWidthScale;
@property (nonatomic, readwrite, assign) NSDecimal barOffset;
@property (nonatomic, readwrite, assign) CGFloat barOffsetScale;
@property (nonatomic, readwrite, assign) CGFloat barCornerRadius;
@property (nonatomic, readwrite, assign) CGFloat barBaseCornerRadius;
@property (nonatomic, readwrite, assign) BOOL barsAreHorizontal;
@property (nonatomic, readwrite, assign) NSDecimal baseValue;
@property (nonatomic, readwrite, assign) BOOL barBasesVary;
@property (nonatomic, readwrite, copy) CPTPlotRange *plotRange;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;
/// @}

/// @name Factory Methods
/// @{
+(instancetype)tubularBarPlotWithColor:(CPTColor *)color horizontalBars:(BOOL)horizontal;
/// @}

/// @name Data Ranges
/// @{
-(CPTPlotRange *)plotRangeEnclosingBars;
/// @}

/// @name Bar Style
/// @{
-(void)reloadBarFills;
-(void)reloadBarFillsInIndexRange:(NSRange)indexRange;
-(void)reloadBarLineStyles;
-(void)reloadBarLineStylesInIndexRange:(NSRange)indexRange;
/// @}

@end
