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

///	@ingroup plotBindingsBarPlot
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
    CPTBarPlotFieldBarBase     = 4	///< Bar base (used only if barBasesVary is YES).
} CPTBarPlotField;

#pragma mark -

/**	@brief A bar plot data source.
 **/
@protocol CPTBarPlotDataSource <CPTPlotDataSource> 
@optional 

/**	@brief Gets a bar fill for the given bar plot. This method is optional.
 *	@param barPlot The bar plot.
 *	@param index The data index of interest.
 *	@return The bar fill for the bar with the given index. If the data source returns nil, the default fill is used.
 *	If the data source returns an NSNull object, no fill is drawn.
 **/
-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index; 

/**	@brief Gets a bar line style for the given bar plot. This method is optional.
 *	@param barPlot The bar plot.
 *	@param index The data index of interest.
 *	@return The bar line style for the bar with the given index. If the data source returns nil, the default line style is used.
 *	If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)barLineStyleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index; 

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
	CGFloat barWidthScale;
    NSDecimal barOffset;
    CGFloat barOffsetScale;
    CGFloat barCornerRadius;
    NSDecimal baseValue;	
    BOOL barsAreHorizontal;
    BOOL barBasesVary;
    BOOL barWidthsAreInViewCoordinates;
    CPTPlotRange *plotRange;
} 

@property (nonatomic, readwrite, assign) BOOL barWidthsAreInViewCoordinates;
@property (nonatomic, readwrite, assign) NSDecimal barWidth;
@property (nonatomic, readwrite, assign) CGFloat barWidthScale;
@property (nonatomic, readwrite, assign) NSDecimal barOffset;
@property (nonatomic, readwrite, assign) CGFloat barOffsetScale;
@property (nonatomic, readwrite, assign) CGFloat barCornerRadius;
@property (nonatomic, readwrite, copy) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;
@property (nonatomic, readwrite, assign) BOOL barsAreHorizontal;
@property (nonatomic, readwrite, assign) NSDecimal baseValue;
@property (nonatomic, readwrite, assign) BOOL barBasesVary;
@property (nonatomic, readwrite, copy) CPTPlotRange *plotRange;

/// @name Factory Methods
/// @{
+(CPTBarPlot *)tubularBarPlotWithColor:(CPTColor *)color horizontalBars:(BOOL)horizontal;
///	@}

@end
