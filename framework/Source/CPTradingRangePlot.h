
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

///	@file

@class CPLineStyle;
@class CPMutableNumericData;
@class CPNumericData;
@class CPTradingRangePlot;
@class CPFill;

/// @name Binding Identifiers
/// @{
extern NSString * const CPTradingRangePlotBindingXValues;
extern NSString * const CPTradingRangePlotBindingOpenValues;
extern NSString * const CPTradingRangePlotBindingHighValues;
extern NSString * const CPTradingRangePlotBindingLowValues;
extern NSString * const CPTradingRangePlotBindingCloseValues;
///	@}

/**	@brief Enumeration of Quote plot render style types
 **/
typedef enum _CPTradingRangePlotStyle {
    CPTradingRangePlotStyleOHLC,		///< OHLC
	CPTradingRangePlotStyleCandleStick	///< Candle
} CPTradingRangePlotStyle;

/**	@brief Enumeration of Quote plot data source field types
 **/
typedef enum _CPTradingRangePlotField {
    CPTradingRangePlotFieldX,			///< X values.
    CPTradingRangePlotFieldOpen,		///< Open values.
	CPTradingRangePlotFieldHigh,		///< High values.
	CPTradingRangePlotFieldLow	,		///< Low values.
	CPTradingRangePlotFieldClose		///< Close values.
} CPTradingRangePlotField;

#pragma mark -

@interface CPTradingRangePlot : CPPlot {
	@private
    CPLineStyle *lineStyle;
    CPFill *increaseFill;
    CPFill *decreaseFill;

	CPTradingRangePlotStyle plotStyle;
	
	CGFloat barWidth;
    CGFloat stickLength;
    CGFloat barCornerRadius;
} 

@property (nonatomic, readwrite, copy) CPLineStyle *lineStyle;
@property (nonatomic, readwrite, copy) CPFill *increaseFill;
@property (nonatomic, readwrite, copy) CPFill *decreaseFill;
@property (nonatomic, readwrite, assign) CPTradingRangePlotStyle plotStyle;
@property (nonatomic, readwrite, assign) CGFloat barWidth;	 // In view coordinates
@property (nonatomic, readwrite, assign) CGFloat stickLength; // In view coordinates
@property (nonatomic, readwrite, assign) CGFloat barCornerRadius;

@end
