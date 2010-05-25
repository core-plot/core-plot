
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

///	@file

@class CPLineStyle;
@class CPFill;
@class CPPlotRange;
@class CPColor;
@class CPBarPlot;

/// @name Binding Identifiers
/// @{
extern NSString * const CPBarPlotBindingBarLengths;
///	@}

/**	@brief Enumeration of bar plot data source field types
 **/
typedef enum _CPBarPlotField {
    CPBarPlotFieldBarLocation,  ///< Bar location on independent coordinate axis.
    CPBarPlotFieldBarLength		///< Bar length.
} CPBarPlotField;

/**	@brief A bar plot data source.
 **/
@protocol CPBarPlotDataSource <CPPlotDataSource> 
@optional 

/**	@brief Gets a bar fill for the given bar plot. This method is optional.
 *	@param barPlot The bar plot.
 *	@param index The data index of interest.
 *	@return The bar fill for the point with the given index.
 **/
-(CPFill *)barFillForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSUInteger)index; 

@end 

@interface CPBarPlot : CPPlot {
@private
    id observedObjectForBarLengthValues;
    NSString *keyPathForBarLengthValues;
    CPLineStyle *lineStyle;
    CPFill *fill;
    CGFloat barWidth;
    CGFloat barOffset;
    CGFloat cornerRadius;
    NSDecimal baseValue;	// TODO: NSDecimal instance variables in CALayers cause an unhandled property type encoding error
	double doublePrecisionBaseValue;
    NSArray *barLengths;
    BOOL barsAreHorizontal;
    CPPlotRange *plotRange;
} 

@property (nonatomic, readwrite, assign) CGFloat barWidth;
@property (nonatomic, readwrite, assign) CGFloat barOffset;     // In units of bar width
@property (nonatomic, readwrite, assign) CGFloat cornerRadius;
@property (nonatomic, readwrite, copy) CPLineStyle *lineStyle;
@property (nonatomic, readwrite, copy) CPFill *fill;
@property (nonatomic, readwrite, assign) BOOL barsAreHorizontal;
@property (nonatomic, readwrite) NSDecimal baseValue;
@property (nonatomic, readwrite) double doublePrecisionBaseValue;
@property (nonatomic, readwrite, copy) CPPlotRange *plotRange;

/// @name Factory Methods
/// @{
+(CPBarPlot *)tubularBarPlotWithColor:(CPColor *)color horizontalBars:(BOOL)horizontal;
///	@}

@end
