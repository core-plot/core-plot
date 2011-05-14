#import <Foundation/Foundation.h>
#import "CPTPlot.h"
#import "CPTDefinitions.h"

///	@file

@class CPTLineStyle;
@class CPTMutableNumericData;
@class CPTNumericData;
@class CPTFill;
@class CPTPlotRange;
@class CPTColor;
@class CPTBarPlot;
@class CPTTextLayer;
@class CPTTextStyle;

/// @name Binding Identifiers
/// @{
extern NSString * const CPTBarPlotBindingBarLocations;
extern NSString * const CPTBarPlotBindingBarTips;
extern NSString * const CPTBarPlotBindingBarBases;
///	@}

/**	@brief Enumeration of bar plot data source field types
 **/
typedef enum _CPTBarPlotField {
    CPTBarPlotFieldBarLocation = 2,  ///< Bar location on independent coordinate axis.
    CPTBarPlotFieldBarTip   	  = 3,	///< Bar tip value.
    CPTBarPlotFieldBarBase     = 4	///< Bar base (if baseValue is nil.)
} CPTBarPlotField;

#pragma mark -

/**	@brief A bar plot data source.
 **/
@protocol CPTBarPlotDataSource <CPTPlotDataSource> 
@optional 

/**	@brief Gets a bar fill for the given bar plot. This method is optional.
 *	@param barPlot The bar plot.
 *	@param index The data index of interest.
 *	@return The bar fill for the point with the given index.
 **/
-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index; 

/** @brief Gets a bar label for the given bar plot. This method is no longer used.
 *	@param barPlot The bar plot.
 *	@param index The data index of interest.
 *	@return The bar label for the point with the given index.
 *  If you return nil, the default bar label will be used. If you return an instance of NSNull,
 *  no label will be shown for the index in question.
 *	@deprecated This method has been replaced by the CPTPlotDataSource::dataLabelForPlot:recordIndex: method and is no longer used.
 **/
-(CPTTextLayer *)barLabelForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index;

@end 

#pragma mark -

/**	@brief Bar plot delegate.
 **/
@protocol CPTBarPlotDelegate <NSObject>

@optional

// @name Point selection
/// @{

/**	@brief Informs delegate that a point was touched.
 *	@param plot The scatter plot.
 *	@param index Index of touched point
 **/
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index;

///	@}

@end

#pragma mark -

@interface CPTBarPlot : CPTPlot {
	@private
    CPTLineStyle *lineStyle;
    CPTFill *fill;
    NSDecimal barWidth;
    NSDecimal barOffset;
    CGFloat barCornerRadius;
    NSDecimal baseValue;	
    BOOL barsAreHorizontal;
    BOOL barBasesVary;
    BOOL barWidthsAreInViewCoordinates;
    CPTPlotRange *plotRange;
} 

@property (nonatomic, readwrite, assign) BOOL barWidthsAreInViewCoordinates;
@property (nonatomic, readwrite, assign) NSDecimal barWidth;
@property (nonatomic, readwrite, assign) NSDecimal barOffset;
@property (nonatomic, readwrite, assign) CGFloat barCornerRadius;
@property (nonatomic, readwrite, copy) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;
@property (nonatomic, readwrite, assign) BOOL barsAreHorizontal;
@property (nonatomic, readwrite, assign) NSDecimal baseValue;
@property (nonatomic, readwrite, assign) BOOL barBasesVary;
@property (nonatomic, readwrite, copy) CPTPlotRange *plotRange;
@property (nonatomic, readwrite, assign) CGFloat barLabelOffset;
@property (nonatomic, readwrite, copy) CPTTextStyle *barLabelTextStyle;

/// @name Factory Methods
/// @{
+(CPTBarPlot *)tubularBarPlotWithColor:(CPTColor *)color horizontalBars:(BOOL)horizontal;
///	@}

@end
