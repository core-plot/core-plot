#import "CPTDefinitions.h"
#import "CPTPlot.h"

@class CPTLineStyle;
@class CPTFill;
@class CPTRangePlot;

/// @ingroup plotBindingsRangePlot
/// @{
extern NSString *const CPTRangePlotBindingXValues;
extern NSString *const CPTRangePlotBindingYValues;
extern NSString *const CPTRangePlotBindingHighValues;
extern NSString *const CPTRangePlotBindingLowValues;
extern NSString *const CPTRangePlotBindingLeftValues;
extern NSString *const CPTRangePlotBindingRightValues;
extern NSString *const CPTRangePlotBindingBarLineStyles;
/// @}

/**
 *  @brief Enumeration of range plot data source field types
 **/
typedef NS_ENUM (NSInteger, CPTRangePlotField) {
    CPTRangePlotFieldX,     ///< X values.
    CPTRangePlotFieldY,     ///< Y values.
    CPTRangePlotFieldHigh,  ///< relative High values.
    CPTRangePlotFieldLow,   ///< relative Low values.
    CPTRangePlotFieldLeft,  ///< relative Left values.
    CPTRangePlotFieldRight, ///< relative Right values.
};

#pragma mark -

/**
 *  @brief A range plot data source.
 **/
@protocol CPTRangePlotDataSource<CPTPlotDataSource>
@optional

/// @name Bar Style
/// @{

/** @brief @optional Gets a range of bar line styles for the given range plot.
 *  @param plot The range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(NSArray *)barLineStylesForRangePlot:(CPTRangePlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a bar line style for the given range plot.
 *  This method will not be called if
 *  @link CPTRangePlotDataSource::barLineStylesForRangePlot:recordIndexRange: -barLineStylesForRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The range plot.
 *  @param idx The data index of interest.
 *  @return The bar line style for the bar with the given index. If the data source returns @nil, the default line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)barLineStyleForRangePlot:(CPTRangePlot *)plot recordIndex:(NSUInteger)idx;

/// @}

@end

#pragma mark -

/**
 *  @brief Range plot delegate.
 **/
@protocol CPTRangePlotDelegate<CPTPlotDelegate>

@optional

/// @name Point Selection
/// @{

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)rangePlot:(CPTRangePlot *)plot rangeWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)rangePlot:(CPTRangePlot *)plot rangeWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)rangePlot:(CPTRangePlot *)plot rangeTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)rangePlot:(CPTRangePlot *)plot rangeTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)rangePlot:(CPTRangePlot *)plot rangeTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a bar
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The range plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)rangePlot:(CPTRangePlot *)plot rangeTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTRangePlot : CPTPlot

/// @name Appearance
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *barLineStyle;
@property (nonatomic, readwrite) CGFloat barWidth;
@property (nonatomic, readwrite) CGFloat gapHeight;
@property (nonatomic, readwrite) CGFloat gapWidth;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, copy) CPTFill *areaFill;
@property (nonatomic, readwrite, copy) CPTLineStyle *areaBorderLineStyle;
/// @}

/// @name Bar Style
/// @{
-(void)reloadBarLineStyles;
-(void)reloadBarLineStylesInIndexRange:(NSRange)indexRange;
/// @}

@end
