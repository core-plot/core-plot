
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

@class CPLineStyle;

extern NSString *CPScatterPlotBindingXValues;
extern NSString *CPScatterPlotBindingYValues;

typedef enum _CPScatterPlotField {
    CPScatterPlotFieldX,
    CPScatterPlotFieldY,
    CPScatterPlotFieldErrorMinimum,
    CPScatterPlotFieldErrorMaximum
} CPScatterPlotField;


@interface CPScatterPlot : CPPlot {
    CPNumericType numericType;
    id observedObjectForXValues;
    id observedObjectForYValues;
    NSString *keyPathForXValues;
    NSString *keyPathForYValues;
    BOOL hasErrorBars;
	CPLineStyle *dataLineStyle;
    NSArray *xValues;
    NSArray *yValues;
} 

@property (nonatomic, readwrite, assign) CPNumericType numericType;
@property (nonatomic, readwrite, assign) BOOL hasErrorBars;
@property (nonatomic, readwrite, retain) CPLineStyle *dataLineStyle;

@end
