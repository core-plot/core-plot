#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

@class CPLineStyle;
@class CPFill;

extern NSString * const CPRangePlotBindingXValues;
extern NSString * const CPRangePlotBindingYValues;
extern NSString * const CPRangePlotBindingHighValues;
extern NSString * const CPRangePlotBindingLowValues;
extern NSString * const CPRangePlotBindingLeftValues;
extern NSString * const CPRangePlotBindingRightValues;

/**	@brief Enumeration of range plot data source field types
 **/
typedef enum _CPRangePlotField {
    CPRangePlotFieldX,		///< X values.
    CPRangePlotFieldY,		///< Y values.
	CPRangePlotFieldHigh,	///< relative High values.
	CPRangePlotFieldLow	,	///< relative Low values.
	CPRangePlotFieldLeft,	///< relative Left values.
	CPRangePlotFieldRight,	///< relative Right values.
} CPRangePlotField;

@interface CPRangePlot : CPPlot {
	CPLineStyle *barLineStyle;
	CGFloat barWidth;
    CGFloat gapHeight;
    CGFloat gapWidth;
    CPFill *areaFill;
}

/// @name Bar Appearance
/// @{
@property (nonatomic, readwrite, copy) CPLineStyle *barLineStyle;
@property (nonatomic, readwrite) CGFloat barWidth, gapHeight, gapWidth;
///	@}

/// @name Area Fill
/// @{
@property (nonatomic, copy) CPFill *areaFill;
/// @}

@end
