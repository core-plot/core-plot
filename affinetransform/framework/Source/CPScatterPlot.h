
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"


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
} 

@property (nonatomic, readwrite, assign) CPNumericType numericType;
@property (nonatomic, readwrite, assign) BOOL hasErrorBars;

@end
