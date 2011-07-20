#import <Foundation/Foundation.h>
#import "CPTPlot.h"
#import "CPTDefinitions.h"

///	@file

@class CPTLineStyle;
@class CPTMutableNumericData;
@class CPTNumericData;
@class CPTTradingRangePlot;
@class CPTFill;

///	@ingroup plotBindingsTradingRangePlot
/// @{
extern NSString * const CPTTradingRangePlotBindingXValues;
extern NSString * const CPTTradingRangePlotBindingOpenValues;
extern NSString * const CPTTradingRangePlotBindingHighValues;
extern NSString * const CPTTradingRangePlotBindingLowValues;
extern NSString * const CPTTradingRangePlotBindingCloseValues;
///	@}

/**	@brief Enumeration of Quote plot render style types
 **/
typedef enum _CPTTradingRangePlotStyle {
    CPTTradingRangePlotStyleOHLC,		///< OHLC
	CPTTradingRangePlotStyleCandleStick	///< Candle
} CPTTradingRangePlotStyle;

/**	@brief Enumeration of Quote plot data source field types
 **/
typedef enum _CPTTradingRangePlotField {
    CPTTradingRangePlotFieldX,			///< X values.
    CPTTradingRangePlotFieldOpen,		///< Open values.
	CPTTradingRangePlotFieldHigh,		///< High values.
	CPTTradingRangePlotFieldLow	,		///< Low values.
	CPTTradingRangePlotFieldClose		///< Close values.
} CPTTradingRangePlotField;

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

@property (nonatomic, readwrite, copy) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, copy) CPTLineStyle *increaseLineStyle;
@property (nonatomic, readwrite, copy) CPTLineStyle *decreaseLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *increaseFill;
@property (nonatomic, readwrite, copy) CPTFill *decreaseFill;
@property (nonatomic, readwrite, assign) CPTTradingRangePlotStyle plotStyle;
@property (nonatomic, readwrite, assign) CGFloat barWidth;	 // In view coordinates
@property (nonatomic, readwrite, assign) CGFloat stickLength; // In view coordinates
@property (nonatomic, readwrite, assign) CGFloat barCornerRadius;

@end
