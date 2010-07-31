
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

///	@file

@class CPLineStyle;
@class CPFill;
@class CPPlotRange;
@class CPColor;
@class CPBarPlot;
@class CPTextLayer;
@class CPTextStyle;

/// @name Binding Identifiers
/// @{
extern NSString * const CPBarPlotBindingBarLocations;
extern NSString * const CPBarPlotBindingBarLengths;
///	@}

/**	@brief Enumeration of bar plot data source field types
 **/
typedef enum _CPBarPlotField {
    CPBarPlotFieldBarLocation = 2,  ///< Bar location on independent coordinate axis.
    CPBarPlotFieldBarLength   = 3	///< Bar length.
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

/** @brief Gets a bar label for the given bar plot. This method is optional.
 *	@param barPlot The bar plot.
 *	@param index The data index of interest.
 *	@return The bar label for the point with the given index.
 *  If you return nil, the default bar label will be used. If you return an NSNull,
 *  no label will be shown for the index in question.
 **/
-(CPTextLayer *)barLabelForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSUInteger)index;

@end 


/**	@brief Bar plot delegate.
 **/
@protocol CPBarPlotDelegate <NSObject>

@optional

// @name Point selection
/// @{

/**	@brief Informs delegate that a point was touched.
 *	@param plot The scatter plot.
 *	@param index Index of touched point
 **/
-(void)barPlot:(CPBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index;

///	@}

@end

@interface CPBarPlot : CPPlot {
	@private
    id observedObjectForBarLocationValues;
    id observedObjectForBarLengthValues;
    NSString *keyPathForBarLocationValues;
    NSString *keyPathForBarLengthValues;
    CPLineStyle *lineStyle;
    CPFill *fill;
    CGFloat barWidth;
    CGFloat barOffset;
    CGFloat cornerRadius;
    NSDecimal baseValue;	
    NSArray *barLocations;
    NSArray *barLengths;
    BOOL barsAreHorizontal;
    CPPlotRange *plotRange;
	CGFloat barLabelOffset;
	CPTextStyle *barLabelTextStyle;
    NSMutableArray *barLabelTextLayers;
	__weak id <CPBarPlotDelegate> delegate;
} 

@property (nonatomic, readwrite, assign) CGFloat barWidth;
@property (nonatomic, readwrite, assign) CGFloat barOffset;     // In units of bar width
@property (nonatomic, readwrite, assign) CGFloat cornerRadius;
@property (nonatomic, readwrite, copy) CPLineStyle *lineStyle;
@property (nonatomic, readwrite, copy) CPFill *fill;
@property (nonatomic, readwrite, assign) BOOL barsAreHorizontal;
@property (nonatomic, readwrite) NSDecimal baseValue;
@property (nonatomic, readwrite, copy) CPPlotRange *plotRange;
@property (nonatomic, readwrite, assign) CGFloat barLabelOffset;
@property (nonatomic, readwrite, copy) CPTextStyle *barLabelTextStyle;
@property (nonatomic, readwrite, assign) __weak id <CPBarPlotDelegate> delegate;

/// @name Factory Methods
/// @{
+(CPBarPlot *)tubularBarPlotWithColor:(CPColor *)color horizontalBars:(BOOL)horizontal;
///	@}

@end
