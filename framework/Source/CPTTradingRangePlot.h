#import "CPTDefinitions.h"
#import "CPTPlot.h"
#import <Foundation/Foundation.h>

/// @file

@class CPTLineStyle;
@class CPTMutableNumericData;
@class CPTNumericData;
@class CPTTradingRangePlot;
@class CPTFill;

/// @ingroup plotBindingsTradingRangePlot
/// @{
extern NSString *const CPTTradingRangePlotBindingXValues;
extern NSString *const CPTTradingRangePlotBindingOpenValues;
extern NSString *const CPTTradingRangePlotBindingHighValues;
extern NSString *const CPTTradingRangePlotBindingLowValues;
extern NSString *const CPTTradingRangePlotBindingCloseValues;
extern NSString *const CPTTradingRangePlotBindingIncreaseFills;
extern NSString *const CPTTradingRangePlotBindingDecreaseFills;
extern NSString *const CPTTradingRangePlotBindingLineStyles;
extern NSString *const CPTTradingRangePlotBindingIncreaseLineStyles;
extern NSString *const CPTTradingRangePlotBindingDecreaseLineStyles;
/// @}

/**
 *  @brief Enumeration of Quote plot render style types.
 **/
typedef enum _CPTTradingRangePlotStyle {
    CPTTradingRangePlotStyleOHLC,       ///< Open-High-Low-Close (OHLC) plot.
    CPTTradingRangePlotStyleCandleStick ///< Candlestick plot.
}
CPTTradingRangePlotStyle;

/**
 *  @brief Enumeration of Quote plot data source field types.
 **/
typedef enum _CPTTradingRangePlotField {
    CPTTradingRangePlotFieldX,    ///< X values.
    CPTTradingRangePlotFieldOpen, ///< Open values.
    CPTTradingRangePlotFieldHigh, ///< High values.
    CPTTradingRangePlotFieldLow,  ///< Low values.
    CPTTradingRangePlotFieldClose ///< Close values.
}
CPTTradingRangePlotField;

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
-(NSArray *)increaseFillsForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the fill used with a candlestick plot when close >= open for the given plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::increaseFillsForTradingRangePlot:recordIndexRange: -increaseFillsForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The bar fill for the bar with the given index. If the data source returns @nil, the default increase fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(CPTFill *)increaseFillForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of fills used with a candlestick plot when close < open for the given plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @param indexRange The range of the data indexes of interest.
 **/
-(NSArray *)decreaseFillsForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the fill used with a candlestick plot when close < open for the given plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::decreaseFillsForTradingRangePlot:recordIndexRange: -decreaseFillsForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The bar fill for the bar with the given index. If the data source returns @nil, the default decrease fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(CPTFill *)decreaseFillForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/// @}

/// @name Bar Line Styles
/// @{

/** @brief @optional Gets a range of line styles used to draw candlestick or OHLC symbols for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(NSArray *)lineStylesForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the line style used to draw candlestick or OHLC symbols for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::lineStylesForTradingRangePlot:recordIndexRange: -lineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line style for the symbol with the given index. If the data source returns @nil, the default line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)lineStyleForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of line styles used to outline candlestick symbols when close >= open for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(NSArray *)increaseLineStylesForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the line style used to outline candlestick symbols when close >= open for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::increaseLineStylesForTradingRangePlot:recordIndexRange: -increaseLineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line line style for the symbol with the given index. If the data source returns @nil, the default increase line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)increaseLineStyleForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of line styles used to outline candlestick symbols when close < open for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(NSArray *)decreaseLineStylesForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets the line style used to outline candlestick symbols when close < open for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::decreaseLineStylesForTradingRangePlot:recordIndexRange: -decreaseLineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line line style for the symbol with the given index. If the data source returns @nil, the default decrease line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)decreaseLineStyleForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx;

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

/** @brief @optional Informs the delegate that a bar was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plot The trading range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)tradingRangePlot:(CPTTradingRangePlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plot The trading range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)tradingRangePlot:(CPTTradingRangePlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTTradingRangePlot : CPTPlot {
    @private
    CPTLineStyle *lineStyle;
    CPTLineStyle *increaseLineStyle;
    CPTLineStyle *decreaseLineStyle;
    CPTFill *increaseFill;
    CPTFill *decreaseFill;

    CPTTradingRangePlotStyle plotStyle;

    CGFloat barWidth;
    CGFloat stickLength;
    CGFloat barCornerRadius;
}

/// @name Appearance
/// @{
@property (nonatomic, readwrite, assign) CPTTradingRangePlotStyle plotStyle;
@property (nonatomic, readwrite, assign) CGFloat barWidth;    // In view coordinates
@property (nonatomic, readwrite, assign) CGFloat stickLength; // In view coordinates
@property (nonatomic, readwrite, assign) CGFloat barCornerRadius;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, copy) CPTLineStyle *increaseLineStyle;
@property (nonatomic, readwrite, copy) CPTLineStyle *decreaseLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *increaseFill;
@property (nonatomic, readwrite, copy) CPTFill *decreaseFill;
/// @}

@end
