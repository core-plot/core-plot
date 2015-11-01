#import "CPTDefinitions.h"
#import "CPTFill.h"
#import "CPTLineStyle.h"
#import "CPTPlot.h"

/// @file

@class CPTTradingRangePlot;

/// @ingroup plotBindingsTradingRangePlot
/// @{
extern NSString *__nonnull const CPTTradingRangePlotBindingXValues;
extern NSString *__nonnull const CPTTradingRangePlotBindingOpenValues;
extern NSString *__nonnull const CPTTradingRangePlotBindingHighValues;
extern NSString *__nonnull const CPTTradingRangePlotBindingLowValues;
extern NSString *__nonnull const CPTTradingRangePlotBindingCloseValues;
extern NSString *__nonnull const CPTTradingRangePlotBindingIncreaseFills;
extern NSString *__nonnull const CPTTradingRangePlotBindingDecreaseFills;
extern NSString *__nonnull const CPTTradingRangePlotBindingLineStyles;
extern NSString *__nonnull const CPTTradingRangePlotBindingIncreaseLineStyles;
extern NSString *__nonnull const CPTTradingRangePlotBindingDecreaseLineStyles;
/// @}

/**
 *  @brief Enumeration of Quote plot render style types.
 **/
typedef NS_ENUM (NSInteger, CPTTradingRangePlotStyle) {
    CPTTradingRangePlotStyleOHLC,       ///< Open-High-Low-Close (OHLC) plot.
    CPTTradingRangePlotStyleCandleStick ///< Candlestick plot.
};

/**
 *  @brief Enumeration of Quote plot data source field types.
 **/
typedef NS_ENUM (NSInteger, CPTTradingRangePlotField) {
    CPTTradingRangePlotFieldX,    ///< X values.
    CPTTradingRangePlotFieldOpen, ///< Open values.
    CPTTradingRangePlotFieldHigh, ///< High values.
    CPTTradingRangePlotFieldLow,  ///< Low values.
    CPTTradingRangePlotFieldClose ///< Close values.
};

#pragma mark -

/**
 *  @brief A trading range plot data source.
 **/
@protocol CPTTradingRangePlotDataSource<CPTPlotDataSource>
@optional

/// @name Bar Fills
/// @{

/** @brief @optional Gets a range of fills used with a candlestick plot when close >= open for the given plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of fills.
 **/
-(nullable CPTFillArray *)increaseFillsForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the fill used with a candlestick plot when close >= open for the given plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::increaseFillsForTradingRangePlot:recordIndexRange: -increaseFillsForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The bar fill for the bar with the given index. If the data source returns @nil, the default increase fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(nullable CPTFill *)increaseFillForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of fills used with a candlestick plot when close < open for the given plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 **/
-(nullable CPTFillArray *)decreaseFillsForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the fill used with a candlestick plot when close < open for the given plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::decreaseFillsForTradingRangePlot:recordIndexRange: -decreaseFillsForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The bar fill for the bar with the given index. If the data source returns @nil, the default decrease fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(nullable CPTFill *)decreaseFillForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/// @}

/// @name Bar Line Styles
/// @{

/** @brief @optional Gets a range of line styles used to draw candlestick or OHLC symbols for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(nullable CPTLineStyleArray *)lineStylesForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the line style used to draw candlestick or OHLC symbols for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::lineStylesForTradingRangePlot:recordIndexRange: -lineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line style for the symbol with the given index. If the data source returns @nil, the default line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(nullable CPTLineStyle *)lineStyleForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of line styles used to outline candlestick symbols when close >= open for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(nullable CPTLineStyleArray *)increaseLineStylesForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the line style used to outline candlestick symbols when close >= open for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::increaseLineStylesForTradingRangePlot:recordIndexRange: -increaseLineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line line style for the symbol with the given index. If the data source returns @nil, the default increase line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(nullable CPTLineStyle *)increaseLineStyleForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of line styles used to outline candlestick symbols when close < open for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(nullable CPTLineStyleArray *)decreaseLineStylesForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the line style used to outline candlestick symbols when close < open for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::decreaseLineStylesForTradingRangePlot:recordIndexRange: -decreaseLineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line line style for the symbol with the given index. If the data source returns @nil, the default decrease line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(nullable CPTLineStyle *)decreaseLineStyleForTradingRangePlot:(nonnull CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/// @}

@end

#pragma mark -

/**
 *  @brief Trading range plot delegate.
 **/
@protocol CPTTradingRangePlotDelegate<CPTPlotDelegate>

@optional

/// @name Point Selection
/// @{

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The trading range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)tradingRangePlot:(nonnull CPTTradingRangePlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The trading range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)tradingRangePlot:(nonnull CPTTradingRangePlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The trading range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)tradingRangePlot:(nonnull CPTTradingRangePlot *)plot barTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The trading range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)tradingRangePlot:(nonnull CPTTradingRangePlot *)plot barTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The trading range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)tradingRangePlot:(nonnull CPTTradingRangePlot *)plot barTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The trading range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)tradingRangePlot:(nonnull CPTTradingRangePlot *)plot barTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTTradingRangePlot : CPTPlot

/// @name Appearance
/// @{
@property (nonatomic, readwrite, assign) CPTTradingRangePlotStyle plotStyle;
@property (nonatomic, readwrite, assign) CGFloat barWidth;    // In view coordinates
@property (nonatomic, readwrite, assign) CGFloat stickLength; // In view coordinates
@property (nonatomic, readwrite, assign) CGFloat barCornerRadius;
@property (nonatomic, readwrite, assign) BOOL showBarBorder;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy, nullable) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, copy, nullable) CPTLineStyle *increaseLineStyle;
@property (nonatomic, readwrite, copy, nullable) CPTLineStyle *decreaseLineStyle;
@property (nonatomic, readwrite, copy, nullable) CPTFill *increaseFill;
@property (nonatomic, readwrite, copy, nullable) CPTFill *decreaseFill;
/// @}

/// @name Bar Style
/// @{
-(void)reloadBarFills;
-(void)reloadBarFillsInIndexRange:(NSRange)indexRange;
-(void)reloadBarLineStyles;
-(void)reloadBarLineStylesInIndexRange:(NSRange)indexRange;
/// @}

@end
