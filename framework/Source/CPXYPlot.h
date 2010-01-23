
#import <Foundation/Foundation.h>
#import "CPPlot.h"

///	@file

/**	@brief Enumeration of xy plot data source field types
 **/
typedef enum _CPXYPlotField {
    CPXYPlotLowerErrorBar = 0, 	///< Lower error bar.
    CPXYPlotUpperErrorBar = 1  	///< Upper error bar.
} CPXYPlotField;

/// @name Binding Identifiers
/// @{
extern NSString * const CPXYPlotBindingLowerErrorBarValues;
extern NSString * const CPXYPlotBindingUpperErrorBarValues;
///	@}

@interface CPXYPlot : CPPlot {
    id observedObjectForLowerErrorValues;
    id observedObjectForUpperErrorValues;
    NSString *keyPathForLowerErrorValues;
    NSString *keyPathForUpperErrorValues;
    NSValueTransformer *lowerErrorValuesTransformer;
    NSValueTransformer *upperErrorValuesTransformer;
}

@property (nonatomic, readonly) BOOL hasErrorBars;

@end
