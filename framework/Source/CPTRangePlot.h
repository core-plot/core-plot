#import "CPTDefinitions.h"
#import "CPTPlot.h"
#import <Foundation/Foundation.h>

@class CPTLineStyle;
@class CPTFill;
@class CPTRangePlot;

///	@ingroup plotBindingsRangePlot
///	@{
extern NSString *const CPTRangePlotBindingXValues;
extern NSString *const CPTRangePlotBindingYValues;
extern NSString *const CPTRangePlotBindingHighValues;
extern NSString *const CPTRangePlotBindingLowValues;
extern NSString *const CPTRangePlotBindingLeftValues;
extern NSString *const CPTRangePlotBindingRightValues;
extern NSString *const CPTRangePlotBindingBarLineStyles;
///	@}

/**
 *	@brief Enumeration of range plot data source field types
 **/
typedef enum _CPTRangePlotField {
    CPTRangePlotFieldX,     ///< X values.
    CPTRangePlotFieldY,     ///< Y values.
    CPTRangePlotFieldHigh,  ///< relative High values.
    CPTRangePlotFieldLow,   ///< relative Low values.
    CPTRangePlotFieldLeft,  ///< relative Left values.
    CPTRangePlotFieldRight, ///< relative Right values.
}
CPTRangePlotField;

#pragma mark -

/**
 *	@brief A range plot data source.
 **/
@protocol CPTRangePlotDataSource<CPTPlotDataSource>
@optional

///	@name Bar Style
/// @{

/**	@brief (Optional) Gets a bar line style for the given range plot.
 *	@param plot The range plot.
 *	@param index The data index of interest.
 *	@return The bar line style for the bar with the given index. If the data source returns <code>nil</code>, the default line style is used.
 *	If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)barLineStyleForRangePlot:(CPTRangePlot *)plot recordIndex:(NSUInteger)index;

///	@}

@end

#pragma mark -

/**
 *	@brief Range plot delegate.
 **/
@protocol CPTRangePlotDelegate<CPTPlotDelegate>

@optional

///	@name Point Selection
/// @{

/**	@brief (Optional) Informs the delegate that a bar was
 *	@if MacOnly clicked. @endif
 *	@if iOSOnly touched. @endif
 *	@param plot The range plot.
 *	@param index The index of the
 *	@if MacOnly clicked bar. @endif
 *	@if iOSOnly touched bar. @endif
 **/
-(void)rangePlot:(CPTRangePlot *)plot rangeWasSelectedAtRecordIndex:(NSUInteger)index;

/**	@brief (Optional) Informs the delegate that a bar was
 *	@if MacOnly clicked. @endif
 *	@if iOSOnly touched. @endif
 *	@param plot The range plot.
 *	@param index The index of the
 *	@if MacOnly clicked bar. @endif
 *	@if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)rangePlot:(CPTRangePlot *)plot rangeWasSelectedAtRecordIndex:(NSUInteger)index withEvent:(CPTNativeEvent *)event;

///	@}

@end

#pragma mark -

@interface CPTRangePlot : CPTPlot {
    CPTLineStyle *barLineStyle;
    CGFloat barWidth;
    CGFloat gapHeight;
    CGFloat gapWidth;
    CPTFill *areaFill;
}

/// @name Bar Appearance
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *barLineStyle;
@property (nonatomic, readwrite) CGFloat barWidth, gapHeight, gapWidth;
///	@}

/// @name Area Fill
/// @{
@property (nonatomic, copy) CPTFill *areaFill;
/// @}

@end
