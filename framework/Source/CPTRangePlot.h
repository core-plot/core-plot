#import <Foundation/Foundation.h>
#import "CPTPlot.h"
#import "CPTDefinitions.h"

@class CPTLineStyle;
@class CPTFill;

///	@ingroup plotBindingsRangePlot
///	@{
extern NSString * const CPTRangePlotBindingXValues;
extern NSString * const CPTRangePlotBindingYValues;
extern NSString * const CPTRangePlotBindingHighValues;
extern NSString * const CPTRangePlotBindingLowValues;
extern NSString * const CPTRangePlotBindingLeftValues;
extern NSString * const CPTRangePlotBindingRightValues;
///	@}

/**	@brief Enumeration of range plot data source field types
 **/
typedef enum _CPTRangePlotField {
    CPTRangePlotFieldX,		///< X values.
    CPTRangePlotFieldY,		///< Y values.
	CPTRangePlotFieldHigh,	///< relative High values.
	CPTRangePlotFieldLow	,	///< relative Low values.
	CPTRangePlotFieldLeft,	///< relative Left values.
	CPTRangePlotFieldRight,	///< relative Right values.
} CPTRangePlotField;

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
